import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/models/seller_request_model.dart';
import 'package:madpractical/utils/app_logger.dart';

class SellerRequestRepository {
  final FirebaseFirestore _firestore;

  SellerRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Submit a new seller request
  Future<bool> submitSellerRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    try {
      // Check if user already has a pending/approved request
      final existing = await _firestore
          .collection('sellerRequests')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'approved'])
          .get();

      if (existing.docs.isNotEmpty) {
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
  Future<List<SellerRequestModel>> getPendingRequests() async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
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
  Future<List<SellerRequestModel>> getAllRequests() async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .orderBy('createdAt', descending: true)
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
  Future<SellerRequestModel?> getUserRequest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('sellerRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return SellerRequestModel.fromFirestore(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      AppLogger.error('Error fetching user request', error: e);
      return null;
    }
  }

  /// Approve a seller request
  Future<bool> approveSeller(String requestId, String adminId) async {
    try {
      await _firestore.collection('sellerRequests').doc(requestId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      AppLogger.info('Seller request approved: $requestId');
      return true;
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
      return false;
    }
  }

  /// Reject a seller request
  Future<bool> rejectSeller(
      String requestId, String adminId, String reason) async {
    try {
      await _firestore.collection('sellerRequests').doc(requestId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      AppLogger.info('Seller request rejected: $requestId');
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
      return false;
    }
  }

  /// Get approval stats (for admin dashboard)
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
