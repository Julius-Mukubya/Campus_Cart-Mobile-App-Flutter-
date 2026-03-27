import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all pending seller approval requests
  Future<List<Map<String, dynamic>>> getPendingSellerRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('seller_approval_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching pending seller requests: $e');
      return [];
    }
  }

  // Get all seller approval requests (for admin dashboard)
  Future<List<Map<String, dynamic>>> getAllSellerRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('seller_approval_requests')
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching seller requests: $e');
      return [];
    }
  }

  // Approve seller request
  Future<Map<String, dynamic>> approveSellerRequest({
    required String requestId,
    required String userId,
    required String adminId,
    String adminNotes = '',
  }) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update the approval request
      DocumentReference requestRef = _firestore
          .collection('seller_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
      });

      // Update the user document to activate the seller
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'isActive': true,
        'sellerStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create initial store document for the seller
      DocumentReference storeRef = _firestore.collection('stores').doc();
      batch.set(storeRef, {
        'storeId': storeRef.id,
        'sellerId': userId,
        'storeName': '',
        'storeDescription': '',
        'storeCategory': '',
        'storePhone': '',
        'storeEmail': '',
        'storeAddress': '',
        'storeImage': '',
        'isActive': true,
        'isVerified': false,
        'rating': 0,
        'totalProducts': 0,
        'totalOrders': 0,
        'totalSales': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user document with store ID
      batch.update(userRef, {
        'storeId': storeRef.id,
      });

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Seller request approved successfully!',
        'storeId': storeRef.id,
      };
    } catch (e) {
      print('Error approving seller request: $e');
      return {
        'success': false,
        'message': 'Failed to approve seller request. Please try again.',
      };
    }
  }

  // Reject seller request
  Future<Map<String, dynamic>> rejectSellerRequest({
    required String requestId,
    required String userId,
    required String adminId,
    required String rejectionReason,
    String adminNotes = '',
  }) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update the approval request
      DocumentReference requestRef = _firestore
          .collection('seller_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
        'rejectionReason': rejectionReason,
      });

      // Update the user document
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'sellerStatus': 'rejected',
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Seller request rejected successfully!',
      };
    } catch (e) {
      print('Error rejecting seller request: $e');
      return {
        'success': false,
        'message': 'Failed to reject seller request. Please try again.',
      };
    }
  }

  // Get store approval requests (when sellers create/update stores)
  Future<List<Map<String, dynamic>>> getPendingStoreRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('store_approval_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching pending store requests: $e');
      return [];
    }
  }

  // Create store approval request (called when seller creates/updates store)
  Future<Map<String, dynamic>> createStoreApprovalRequest({
    required String storeId,
    required String sellerId,
    required String storeName,
    required String storeDescription,
    required String storeCategory,
    required String storePhone,
    required String storeEmail,
    required String storeAddress,
    String storeImage = '',
  }) async {
    try {
      await _firestore.collection('store_approval_requests').add({
        'storeId': storeId,
        'sellerId': sellerId,
        'storeName': storeName,
        'storeDescription': storeDescription,
        'storeCategory': storeCategory,
        'storePhone': storePhone,
        'storeEmail': storeEmail,
        'storeAddress': storeAddress,
        'storeImage': storeImage,
        'status': 'pending', // pending, approved, rejected
        'requestedAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'processedBy': null,
        'adminNotes': '',
        'rejectionReason': '',
      });

      return {
        'success': true,
        'message': 'Store information submitted for admin approval!',
      };
    } catch (e) {
      print('Error creating store approval request: $e');
      return {
        'success': false,
        'message': 'Failed to submit store for approval. Please try again.',
      };
    }
  }

  // Approve store request
  Future<Map<String, dynamic>> approveStoreRequest({
    required String requestId,
    required String storeId,
    required String adminId,
    String adminNotes = '',
  }) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update the approval request
      DocumentReference requestRef = _firestore
          .collection('store_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
      });

      // Update the store document
      DocumentReference storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Store approved successfully!',
      };
    } catch (e) {
      print('Error approving store request: $e');
      return {
        'success': false,
        'message': 'Failed to approve store. Please try again.',
      };
    }
  }

  // Reject store request
  Future<Map<String, dynamic>> rejectStoreRequest({
    required String requestId,
    required String storeId,
    required String adminId,
    required String rejectionReason,
    String adminNotes = '',
  }) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update the approval request
      DocumentReference requestRef = _firestore
          .collection('store_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
        'rejectionReason': rejectionReason,
      });

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Store request rejected successfully!',
      };
    } catch (e) {
      print('Error rejecting store request: $e');
      return {
        'success': false,
        'message': 'Failed to reject store request. Please try again.',
      };
    }
  }

  // Get platform statistics for admin dashboard
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      // Get total users count
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      int totalUsers = usersSnapshot.docs.length;

      // Get active sellers count
      QuerySnapshot sellersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'seller')
          .where('isActive', isEqualTo: true)
          .get();
      int activeSellers = sellersSnapshot.docs.length;

      // Get pending seller requests count
      QuerySnapshot pendingSellerSnapshot = await _firestore
          .collection('seller_approval_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      int pendingSellerRequests = pendingSellerSnapshot.docs.length;

      // Get pending store requests count
      QuerySnapshot pendingStoreSnapshot = await _firestore
          .collection('store_approval_requests')
          .where('status', isEqualTo: 'pending')
          .get();
      int pendingStoreRequests = pendingStoreSnapshot.docs.length;

      // Get total orders count (if orders collection exists)
      QuerySnapshot ordersSnapshot = await _firestore.collection('orders').get();
      int totalOrders = ordersSnapshot.docs.length;

      return {
        'totalUsers': totalUsers,
        'activeSellers': activeSellers,
        'pendingSellerRequests': pendingSellerRequests,
        'pendingStoreRequests': pendingStoreRequests,
        'totalOrders': totalOrders,
      };
    } catch (e) {
      print('Error fetching platform stats: $e');
      return {
        'totalUsers': 0,
        'activeSellers': 0,
        'pendingSellerRequests': 0,
        'pendingStoreRequests': 0,
        'totalOrders': 0,
      };
    }
  }
}