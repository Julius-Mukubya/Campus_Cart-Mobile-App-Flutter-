import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

/// AdminSettings model class
class AdminSettings {
  final int maxStoresPerSeller;
  final bool sellerApprovalRequired;
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;

  AdminSettings({
    this.maxStoresPerSeller = 1,
    this.sellerApprovalRequired = true,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      maxStoresPerSeller: json['maxStoresPerSeller'] ?? 1,
      sellerApprovalRequired: json['sellerApprovalRequired'] ?? true,
      lastUpdatedAt: (json['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedBy: json['lastUpdatedBy'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() => {
        'maxStoresPerSeller': maxStoresPerSeller,
        'sellerApprovalRequired': sellerApprovalRequired,
        'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
        'lastUpdatedBy': lastUpdatedBy,
      };
}

/// Merged AdminService combining admin_service and admin_settings_service
class AdminService {
  final FirebaseFirestore _firestore;

  AdminService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ======================================================================
  // SELLER APPROVAL METHODS (from admin_service.dart)
  // ======================================================================

  // Get all pending seller approval requests
  // Uses simple query without orderBy to avoid needing a composite index
  Future<List<Map<String, dynamic>>> getPendingSellerRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      final results = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();

      return results;
    } catch (e) {
      AppLogger.error('Error fetching pending seller requests', error: e);
      return [];
    }
  }

  // Get all seller approval requests (for admin dashboard)
  // Uses no orderBy to avoid needing a composite index
  Future<List<Map<String, dynamic>>> getAllSellerRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('seller_approval_requests')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching seller requests', error: e);
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
      WriteBatch batch = _firestore.batch();

      DocumentReference requestRef = _firestore
          .collection('seller_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
      });

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'isActive': true,
        'sellerStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

      batch.update(userRef, {
        'storeId': storeRef.id,
      });

      await batch.commit();

      return {
        'success': true,
        'message': 'Seller request approved successfully!',
        'storeId': storeRef.id,
      };
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
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
      WriteBatch batch = _firestore.batch();

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

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'sellerStatus': 'rejected',
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return {
        'success': true,
        'message': 'Seller request rejected successfully!',
      };
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
      return {
        'success': false,
        'message': 'Failed to reject seller request. Please try again.',
      };
    }
  }

  // ======================================================================
  // STORE APPROVAL METHODS (from admin_service.dart)
  // ======================================================================

  // Get store approval requests
  Future<List<Map<String, dynamic>>> getPendingStoreRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('store_approval_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      final results = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['requestId'] = doc.id;
        return data;
      }).toList();

      results.sort((a, b) {
        final aTime = a['requestedAt'];
        final bTime = b['requestedAt'];
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return results;
    } catch (e) {
      AppLogger.error('Error fetching pending store requests', error: e);
      return [];
    }
  }

  // Create store approval request
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
        'status': 'pending',
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
      AppLogger.error('Error creating store approval request', error: e);
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
      WriteBatch batch = _firestore.batch();

      DocumentReference requestRef = _firestore
          .collection('store_approval_requests')
          .doc(requestId);
      
      batch.update(requestRef, {
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'adminNotes': adminNotes,
      });

      DocumentReference storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return {
        'success': true,
        'message': 'Store approved successfully!',
      };
    } catch (e) {
      AppLogger.error('Error approving store request', error: e);
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
      WriteBatch batch = _firestore.batch();

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

      await batch.commit();

      return {
        'success': true,
        'message': 'Store request rejected successfully!',
      };
    } catch (e) {
      AppLogger.error('Error rejecting store request', error: e);
      return {
        'success': false,
        'message': 'Failed to reject store request. Please try again.',
      };
    }
  }

  // ======================================================================
  // PLATFORM STATS (from admin_service.dart)
  // ======================================================================

  // Get platform statistics for admin dashboard
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      int totalUsers = usersSnapshot.docs.length;

      // Fetch all users, filter active sellers in Dart to avoid composite index
      QuerySnapshot sellersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'seller')
          .get();
      final int activeSellersCount = sellersSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final isActive = data?['isActive'];
        return isActive == true || isActive == null;
      }).length;
      
      // Use sellerRequests collection for pending count instead of seller_approval_requests
      QuerySnapshot pendingSellerSnapshot = await _firestore
          .collection('sellerRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingSellerRequests = pendingSellerSnapshot.docs.length;

      QuerySnapshot ordersSnapshot = await _firestore.collection('orders').get();
      int totalOrders = ordersSnapshot.docs.length;

      return {
        'totalUsers': totalUsers,
        'activeSellers': activeSellersCount,
        'pendingSellerRequests': pendingSellerRequests,
        'pendingStoreRequests': 0, // store approval not needed for current flow
        'totalOrders': totalOrders,
      };
    } catch (e) {
      AppLogger.error('Error fetching platform stats', error: e);
      return {
        'totalUsers': 0,
        'activeSellers': 0,
        'pendingSellerRequests': 0,
        'pendingStoreRequests': 0,
        'totalOrders': 0,
      };
    }
  }

  // ======================================================================
  // SETTINGS METHODS (from admin_settings_service.dart)
  // ======================================================================

  /// Get current admin settings
  Future<AdminSettings> getSettings() async {
    try {
      final doc = await _firestore.collection('admin_settings').doc('seller_config').get();

      if (!doc.exists) {
        final defaultSettings = AdminSettings(
          maxStoresPerSeller: 1,
          sellerApprovalRequired: true,
          lastUpdatedAt: DateTime.now(),
          lastUpdatedBy: 'system',
        );
        await _firestore
            .collection('admin_settings')
            .doc('seller_config')
            .set(defaultSettings.toJson());
        return defaultSettings;
      }

      return AdminSettings.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error fetching admin settings', error: e);
      return AdminSettings(
        maxStoresPerSeller: 1,
        sellerApprovalRequired: true,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: 'system',
      );
    }
  }

  /// Set maximum stores allowed per seller
  Future<bool> setMaxStoresPerSeller(int maxStores, String adminId) async {
    try {
      if (maxStores < 1) {
        throw Exception('Max stores must be at least 1');
      }

      await _firestore.collection('admin_settings').doc('seller_config').set({
        'maxStoresPerSeller': maxStores,
        'lastUpdatedAt': Timestamp.now(),
        'lastUpdatedBy': adminId,
        'sellerApprovalRequired': true,
      }, SetOptions(merge: true));

      await _logSettingChange('maxStoresPerSeller', maxStores.toString(), adminId);
      return true;
    } catch (e) {
      AppLogger.error('Error setting max stores', error: e);
      return false;
    }
  }

  /// Set whether seller approval is required
  Future<bool> setSellerApprovalRequired(bool required, String adminId) async {
    try {
      await _firestore.collection('admin_settings').doc('seller_config').set({
        'sellerApprovalRequired': required,
        'lastUpdatedAt': Timestamp.now(),
        'lastUpdatedBy': adminId,
      }, SetOptions(merge: true));

      await _logSettingChange('sellerApprovalRequired', required.toString(), adminId);
      return true;
    } catch (e) {
      AppLogger.error('Error setting seller approval required', error: e);
      return false;
    }
  }

  /// Get max stores allowed per seller
  Future<int> getMaxStoresPerSeller() async {
    try {
      final settings = await getSettings();
      return settings.maxStoresPerSeller;
    } catch (e) {
      AppLogger.error('Error getting max stores', error: e);
      return 1;
    }
  }

  /// Get seller approval requirement setting
  Future<bool> isSellerApprovalRequired() async {
    try {
      final settings = await getSettings();
      return settings.sellerApprovalRequired;
    } catch (e) {
      AppLogger.error('Error getting seller approval requirement', error: e);
      return true;
    }
  }

  /// Reset settings to defaults
  Future<bool> resetToDefaults(String adminId) async {
    try {
      final defaultSettings = AdminSettings(
        maxStoresPerSeller: 1,
        sellerApprovalRequired: true,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: adminId,
      );

      await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .set(defaultSettings.toJson());

      await _logSettingChange('all_settings', 'reset_to_defaults', adminId);
      return true;
    } catch (e) {
      AppLogger.error('Error resetting settings', error: e);
      return false;
    }
  }

  /// Get settings change log (admin audit trail)
  Future<List<Map<String, dynamic>>> getSettingsAuditLog({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .collection('audit_log')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error('Error fetching audit log', error: e);
      return [];
    }
  }

  /// Internal: Log setting changes for audit trail
  Future<void> _logSettingChange(String setting, String newValue, String adminId) async {
    try {
      await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .collection('audit_log')
          .add({
        'setting': setting,
        'newValue': newValue,
        'changedBy': adminId,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      AppLogger.error('Error logging setting change', error: e);
    }
  }

  /// Stream settings for real-time updates
  /// Approve a seller request and update user role
  Future<bool> approveSeller(String requestId, String adminId) async {
    try {
      // Get the request to find userId
      final requestDoc =
          await _firestore.collection('sellerRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        AppLogger.warning('Seller request not found: $requestId');
        return false;
      }

      final userId = requestDoc['userId'] as String?;
      if (userId == null) {
        AppLogger.warning('User ID not found in seller request');
        return false;
      }

      // Update seller request status
      await _firestore.collection('sellerRequests').doc(requestId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      // Update user role to seller
      await _firestore.collection('users').doc(userId).update({
        'role': 'seller',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Seller request approved: $requestId for user: $userId');

      // Notify user they're now a seller
      NotificationService().sendNotification(
        userId: userId,
        title: 'Welcome, Seller!',
        message: 'Your seller application has been approved. You can now start selling on Campus Cart!',
        type: 'success',
      );
      return true;
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
      return false;
    }
  }

  /// Reject a seller request with a reason
  Future<bool> rejectSeller(
      String requestId, String adminId, String reason) async {
    try {
      // Get the request to find userId
      final requestDoc =
          await _firestore.collection('sellerRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        AppLogger.warning('Seller request not found: $requestId');
        return false;
      }

      final userId = requestDoc['userId'] as String?;
      if (userId == null) {
        AppLogger.warning('User ID not found in seller request');
        return false;
      }

      // Update seller request status
      await _firestore.collection('sellerRequests').doc(requestId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      // User role stays as customer

      AppLogger.info('Seller request rejected: $requestId for user: $userId');

      // Notify user about rejection
      NotificationService().sendNotification(
        userId: userId,
        title: 'Seller Request Rejected',
        message: reason,
        type: 'error',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
      return false;
    }
  }




  /// Submit a contact message from users
  Future<void> submitContactMessage(String name, String email, String message) async {
    try {
      await _firestore.collection('contact_messages').add({
        'name': name,
        'email': email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'unread',
      });
    } catch (e) {
      AppLogger.error('Error submitting contact message', error: e);
      rethrow;
    }
  }

  /// Toggle a user's active status
  Future<void> toggleUserStatus(String userId, bool currentActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('User $userId ${currentActive ? 'suspended' : 'activated'}');
    } catch (e) {
      AppLogger.error('Error toggling user status', error: e);
      rethrow;
    }
  }


  /// Stream all users for admin view
  Stream<QuerySnapshot> usersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream all orders for admin view
  Stream<QuerySnapshot> ordersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<AdminSettings> getAdminSettings() {
    return _firestore
        .collection('admin')
        .doc('seller_config')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return AdminSettings(
          maxStoresPerSeller: 1,
          sellerApprovalRequired: true,
          lastUpdatedAt: DateTime.now(),
          lastUpdatedBy: 'system',
        );
      }
      return AdminSettings.fromJson(doc.data() as Map<String, dynamic>);
    });
  }
}