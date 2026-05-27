import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/models/seller_request_model.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/services/notification_service.dart';

class SellerRequestRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  SellerRequestRepository({FirebaseFirestore? firestore, NotificationService? notificationService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ?? NotificationService();

  /// Submit a new seller request
  Future<bool> submitSellerRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    try {
      // Check if user already has a pending/approved request
      // Use single field query to avoid needing a composite index
      final existing = await _firestore
          .collection('sellerRequests')
          .where('userId', isEqualTo: userId)
          .get();

      final hasActive = existing.docs.any((doc) {
        final status = doc.data()['status'] as String?;
        return status == 'pending' || status == 'approved';
      });

      if (hasActive) {
        AppLogger.warning('User already has pending or approved seller request');
        return false;
      }

      await _firestore.collection('sellerRequests').add({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userPhone': userPhone,
        'status': 'pending',
        'rejectionReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
      });

      AppLogger.info('Seller request submitted for user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error submitting seller request', error: e);
      return false;
    }
  }

  /// Get all pending seller requests (for admin)
  /// Uses simple filter without orderBy to avoid needing a composite index
  Future<List<SellerRequestModel>> getPendingRequests() async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => SellerRequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching pending requests', error: e);
      return [];
    }
  }

  /// Get all seller requests (for admin)
  /// Uses no orderBy to avoid needing a composite index
  Future<List<SellerRequestModel>> getAllRequests() async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .get();

      return snapshot.docs
          .map((doc) => SellerRequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching all requests', error: e);
      return [];
    }
  }

  /// Get user's seller request status
  /// Uses simple query without orderBy to avoid needing a composite index
  Future<SellerRequestModel?> getUserRequest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Sort by createdAt descending in Dart
      final sorted = snapshot.docs.toList()
        ..sort((a, b) {
          final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate();
          final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate();
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

      return SellerRequestModel.fromFirestore(
          sorted.first.data(), sorted.first.id);
    } catch (e) {
      AppLogger.error('Error fetching user request', error: e);
      return null;
    }
  }

  /// Approve a seller request — also updates the user's role to 'seller'
  Future<bool> approveSeller(String requestId, String adminId) async {
    try {
      // Get the request to find the userId
      final requestDoc =
          await _firestore.collection('sellerRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        AppLogger.warning('Seller request not found: $requestId');
        return false;
      }

      final userId = requestDoc.data()?['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        AppLogger.warning('User ID not found in seller request');
        return false;
      }

      // Create a new store document for the seller
      final storeRef = _firestore.collection('stores').doc();
      final storeId = storeRef.id;

      final batch = _firestore.batch();

      // Update seller request status
      batch.update(
          _firestore.collection('sellerRequests').doc(requestId), {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      // Update user role to seller and set sellerStatus to approved
      batch.update(_firestore.collection('users').doc(userId), {
        'role': 'seller',
        'sellerStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
        'isActive': true,
        'storeId': storeId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create default store document
      batch.set(storeRef, {
        'storeId': storeId,
        'sellerId': userId,
        'storeName': '',
        'storeDescription': '',
        'storePhone': '',
        'storeEmail': '',
        'showContact': true,
        'isActive': true,
        'isVerified': false,
        'rating': 0.0,
        'totalProducts': 0,
        'totalOrders': 0,
        'totalSales': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Notify the user they've been approved
      _notificationService.sendNotification(
        userId: userId,
        title: 'Seller Request Approved!',
        message: 'Congratulations! You are now a seller. Set up your store in Store Settings.',
        type: 'success',
        data: {'storeId': storeId},
      );

      AppLogger.info('Seller request approved: $requestId for user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
      return false;
    }
  }

  /// Reject a seller request — also updates the user's sellerStatus to 'rejected'
  Future<bool> rejectSeller(
      String requestId, String adminId, String reason) async {
    try {
      // Get the request to find the userId
      final requestDoc =
          await _firestore.collection('sellerRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        AppLogger.warning('Seller request not found: $requestId');
        return false;
      }

      final userId = requestDoc.data()?['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        AppLogger.warning('User ID not found in seller request');
        return false;
      }

      final batch = _firestore.batch();

      // Update seller request status
      batch.update(
          _firestore.collection('sellerRequests').doc(requestId), {
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      // Update user's seller status (role stays as customer)
      batch.update(_firestore.collection('users').doc(userId), {
        'sellerStatus': 'rejected',
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Notify the user their request was rejected
      _notificationService.sendNotification(
        userId: userId,
        title: 'Seller Request Rejected',
        message: 'Your seller application was rejected. Reason: $reason',
        type: 'error',
        data: {'rejectionReason': reason},
      );

      AppLogger.info('Seller request rejected: $requestId for user: $userId');
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
      return false;
    }
  }

  /// Get approval stats (for admin dashboard)
  /// Uses simple queries without orderBy to avoid needing composite indexes
  Future<Map<String, int>> getStats() async {
    try {
      final pending = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      final approved = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'approved')
          .count()
          .get();

      final rejected = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'rejected')
          .count()
          .get();

      return {
        'pending': pending.count ?? 0,
        'approved': approved.count ?? 0,
        'rejected': rejected.count ?? 0,
      };
    } catch (e) {
      AppLogger.error('Error fetching stats', error: e);
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }
}
