import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';
import 'admin_service.dart';
import 'package:madpractical/repositories/seller_repository.dart';

/// SellerStore model class
class SellerStore {
  final String id;
  final String sellerId;
  final String storeName;
  final String storeDescription;
  final String storeImage;
  final String location;
  final String phone;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerStore({
    required this.id,
    required this.sellerId,
    required this.storeName,
    required this.storeDescription,
    required this.storeImage,
    required this.location,
    required this.phone,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerStore.fromJson(Map<String, dynamic> json, String docId) {
    return SellerStore(
      id: docId,
      sellerId: json['sellerId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeDescription: json['storeDescription'] ?? '',
      storeImage: json['storeImage'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sellerId': sellerId,
        'storeName': storeName,
        'storeDescription': storeDescription,
        'storeImage': storeImage,
        'location': location,
        'phone': phone,
        'rating': rating,
        'reviewCount': reviewCount,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

/// Merged SellerService combining seller_service, seller_store_service, and seller_request_service
class SellerService {
  // ignore: unused_field
  final SellerRepository? _sellerRepository;
  final FirebaseFirestore _firestore;
  final AdminService _adminService;

  SellerService({
    SellerRepository? sellerRepository,
    FirebaseFirestore? firestore,
    AdminService? adminService,
  })  : _sellerRepository = sellerRepository,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _adminService = adminService ?? AdminService();

  final List<Map<String, dynamic>> _sellerRequests = [];

  List<Map<String, dynamic>> get sellerRequests =>
      List.unmodifiable(_sellerRequests);

  int get pendingRequestCount =>
      _sellerRequests.where((r) => r['status'] == 'pending').length;

  // ======================================================================
  // SELLER STORE METHODS (from seller_store_service.dart)
  // ======================================================================

  /// Create a new store for a seller
  Future<SellerStore?> createStore({
    required String sellerId,
    required String storeName,
    required String storeDescription,
    required String storeImage,
    required String location,
    required String phone,
  }) async {
    try {
      // Check if seller is approved
      final sellerDoc = await _firestore.collection('users').doc(sellerId).get();
      if (!sellerDoc.exists) {
        throw Exception('Seller not found');
      }

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      if (sellerData['role'] != 'seller' || sellerData['sellerApproved'] != true) {
        throw Exception('Seller is not approved');
      }

      // Check store count against limit
      final maxStores = await getMaxStoresPerSeller();
      final existingStores = await getStoresBySellerIfApproved(sellerId);

      if (existingStores.length >= maxStores) {
        throw Exception('Store limit reached. Maximum $maxStores store(s) allowed per seller.');
      }

      // Create new store
      final storeRef = _firestore.collection('seller_stores').doc();
      final now = DateTime.now();

      final newStore = SellerStore(
        id: storeRef.id,
        sellerId: sellerId,
        storeName: storeName,
        storeDescription: storeDescription,
        storeImage: storeImage,
        location: location,
        phone: phone,
        createdAt: now,
        updatedAt: now,
      );

      await storeRef.set(newStore.toJson());

      // Update seller's store count in their profile
      await _firestore.collection('users').doc(sellerId).update({
        'storeCount': FieldValue.increment(1),
      });

      return newStore;
    } catch (e) {
      AppLogger.error('Error creating store', error: e);
      rethrow;
    }
  }

  /// Get all stores for an approved seller
  Future<List<SellerStore>> getStoresBySellerIfApproved(String sellerId) async {
    try {
      final sellerDoc = await _firestore.collection('users').doc(sellerId).get();
      if (!sellerDoc.exists) return [];

      final sellerData = sellerDoc.data() as Map<String, dynamic>;
      if (sellerData['role'] != 'seller' || sellerData['sellerApproved'] != true) {
        return [];
      }

      final snapshot = await _firestore
          .collection('seller_stores')
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerStore.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching seller stores', error: e);
      return [];
    }
  }

  /// Get a specific store by ID
  Future<SellerStore?> getStoreById(String storeId) async {
    try {
      final doc = await _firestore.collection('seller_stores').doc(storeId).get();
      if (!doc.exists) return null;
      return SellerStore.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      AppLogger.error('Error fetching store', error: e);
      return null;
    }
  }

  /// Update store information
  Future<bool> updateStore(String storeId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('seller_stores').doc(storeId).update(updates);
      return true;
    } catch (e) {
      AppLogger.error('Error updating store', error: e);
      return false;
    }
  }

  /// Deactivate a store (soft delete)
  Future<bool> deactivateStore(String storeId) async {
    try {
      final storeDoc = await _firestore.collection('seller_stores').doc(storeId).get();
      if (!storeDoc.exists) return false;

      final storeData = storeDoc.data() as Map<String, dynamic>;
      final sellerId = storeData['sellerId'];

      await _firestore.collection('seller_stores').doc(storeId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(sellerId).update({
        'storeCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      AppLogger.error('Error deactivating store', error: e);
      return false;
    }
  }

  /// Get all stores (admin view)
  Future<List<SellerStore>> getAllStores() async {
    try {
      final snapshot = await _firestore
          .collection('seller_stores')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerStore.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching all stores', error: e);
      return [];
    }
  }

  /// Get max allowed stores per seller
  Future<int> getMaxStoresPerSeller() async {
    try {
      final doc = await _firestore.collection('admin_settings').doc('seller_config').get();
      if (!doc.exists) return 1;
      final data = doc.data() as Map<String, dynamic>;
      return data['maxStoresPerSeller'] ?? 1;
    } catch (e) {
      AppLogger.error('Error fetching max stores config', error: e);
      return 1;
    }
  }

  /// Increment store rating count (called after review)
  Future<void> updateStoreRating(String storeId, double newRating, int newReviewCount) async {
    try {
      await _firestore.collection('seller_stores').doc(storeId).update({
        'rating': newRating,
        'reviewCount': newReviewCount,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      AppLogger.error('Error updating store rating', error: e);
    }
  }

  /// Get stores by location (for discovery/search)
  Future<List<SellerStore>> getStoresByLocation(String location) async {
    try {
      final snapshot = await _firestore
          .collection('seller_stores')
          .where('location', isEqualTo: location)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerStore.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching stores by location', error: e);
      return [];
    }
  }

  /// Get seller's store information
  Future<Map<String, dynamic>?> getSellerStore(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stores')
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        data['storeId'] = snapshot.docs.first.id;
        return data;
      }

      // Fallback: check if user document has a storeId and fetch directly
      final userDoc = await _firestore.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        final storeId = (userDoc.data() as Map<String, dynamic>)['storeId'];
        if (storeId != null && storeId.toString().isNotEmpty) {
          final storeDoc = await _firestore.collection('stores').doc(storeId).get();
          if (storeDoc.exists) {
            Map<String, dynamic> data = storeDoc.data() as Map<String, dynamic>;
            data['storeId'] = storeDoc.id;
            return data;
          }
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error fetching seller store', error: e);
      return null;
    }
  }

  /// Update store information (triggers approval request)
  Future<Map<String, dynamic>> updateStoreInfo({
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
      await _firestore.collection('stores').doc(storeId).update({
        'storeName': storeName,
        'storeDescription': storeDescription,
        'storeCategory': storeCategory,
        'storePhone': storePhone,
        'storeEmail': storeEmail,
        'storeAddress': storeAddress,
        'storeImage': storeImage,
        'isVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final result = await _adminService.createStoreApprovalRequest(
        storeId: storeId,
        sellerId: sellerId,
        storeName: storeName,
        storeDescription: storeDescription,
        storeCategory: storeCategory,
        storePhone: storePhone,
        storeEmail: storeEmail,
        storeAddress: storeAddress,
        storeImage: storeImage,
      );

      return result;
    } catch (e) {
      AppLogger.error('Error updating store info', error: e);
      return {
        'success': false,
        'message': 'Failed to update store information. Please try again.',
      };
    }
  }

  // ======================================================================
  // SELLER PRODUCT METHODS (from seller_service.dart)
  // ======================================================================

  /// Get seller's products
  Future<List<Map<String, dynamic>>> getSellerProducts(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching seller products', error: e);
      return [];
    }
  }

  /// Add new product
  Future<Map<String, dynamic>> addProduct({
    required String sellerId,
    required String storeId,
    required String productName,
    required String productDescription,
    required String category,
    required double price,
    required int stockQuantity,
    String productImage = '',
    double discount = 0,
    List<String> tags = const [],
  }) async {
    try {
      DocumentReference productRef = await _firestore.collection('products').add({
        'sellerId': sellerId,
        'storeId': storeId,
        'productName': productName,
        'productDescription': productDescription,
        'category': category,
        'price': price,
        'originalPrice': price,
        'discount': discount,
        'stockQuantity': stockQuantity,
        'productImage': productImage,
        'tags': tags,
        'isActive': true,
        'isApproved': true,
        'rating': 0,
        'totalReviews': 0,
        'totalSales': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('stores').doc(storeId).update({
        'totalProducts': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product added successfully!',
        'productId': productRef.id,
      };
    } catch (e) {
      AppLogger.error('Error adding product', error: e);
      return {
        'success': false,
        'message': 'Failed to add product. Please try again.',
      };
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String productName,
    required String productDescription,
    required String category,
    required double price,
    required int stockQuantity,
    String productImage = '',
    double discount = 0,
    List<String> tags = const [],
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'productName': productName,
        'productDescription': productDescription,
        'category': category,
        'price': price,
        'originalPrice': price,
        'discount': discount,
        'stockQuantity': stockQuantity,
        'productImage': productImage,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product updated successfully!',
      };
    } catch (e) {
      AppLogger.error('Error updating product', error: e);
      return {
        'success': false,
        'message': 'Failed to update product. Please try again.',
      };
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct({
    required String productId,
    required String storeId,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).delete();

      await _firestore.collection('stores').doc(storeId).update({
        'totalProducts': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product deleted successfully!',
      };
    } catch (e) {
      AppLogger.error('Error deleting product', error: e);
      return {
        'success': false,
        'message': 'Failed to delete product. Please try again.',
      };
    }
  }

  // ======================================================================
  // SELLER ORDER METHODS (from seller_service.dart)
  // ======================================================================

  /// Get seller's orders
  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      // Fetch all orders sorted by creation date, then filter by sellerId in items array
      // (sellerId is nested inside the items array, not a top-level field)
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>? ?? [];
            return items.any((item) =>
                (item is Map<String, dynamic>) && item['sellerId'] == sellerId);
          })
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['orderId'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching seller orders', error: e);
      return [];
    }
  }

  /// Get seller dashboard statistics
  Future<Map<String, dynamic>> getSellerStats(String sellerId) async {
    try {
      Map<String, dynamic>? store = await getSellerStore(sellerId);
      
      if (store == null) {
        return {
          'totalSales': 0,
          'totalOrders': 0,
          'totalProducts': 0,
          'storeRating': 0,
          'isStoreVerified': false,
        };
      }

      return {
        'totalSales': store['totalSales'] ?? 0,
        'totalOrders': store['totalOrders'] ?? 0,
        'totalProducts': store['totalProducts'] ?? 0,
        'storeRating': store['rating'] ?? 0,
        'isStoreVerified': store['isVerified'] ?? false,
      };
    } catch (e) {
      AppLogger.error('Error fetching seller stats', error: e);
      return {
        'totalSales': 0,
        'totalOrders': 0,
        'totalProducts': 0,
        'storeRating': 0,
        'isStoreVerified': false,
      };
    }
  }

  /// Get seller earnings summary and payout history
  Future<Map<String, dynamic>> getSellerEarnings(String sellerId) async {
    try {
      // Fetch all orders, then filter by sellerId in items array
      final ordersSnap = await _firestore
          .collection('orders')
          .get();
      
      // Filter orders that contain this seller's items
      final orderDocs = ordersSnap.docs.where((doc) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        return items.any((item) =>
            (item is Map<String, dynamic>) && item['sellerId'] == sellerId);
      });
      
      // Now use the filtered list instead of ordersSnap.docs
      final filteredOrders = orderDocs.toList();
      
      double totalEarnings = 0;
      double availableBalance = 0;
      final List<Map<String, dynamic>> recentOrders = [];

      for (final doc in filteredOrders) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final amount = (data['totalAmount'] ?? data['total'] ?? 0).toDouble();
        totalEarnings += amount;
        if (status == 'delivered') availableBalance += amount;
        recentOrders.add({...data, 'orderId': doc.id});
      }
      
      // Use a setter instead of redeclaring
      final ordersCount = filteredOrders.length;
      
      /// Inline the rest and use ordersCount
      return _buildEarningsResponse(
        sellerId: sellerId,
        totalEarnings: totalEarnings,
        availableBalance: availableBalance,
        recentOrders: recentOrders,
        ordersCount: ordersCount,
      );
    } catch (e) {
      AppLogger.error('Error fetching seller earnings', error: e);
      return {
        'totalEarnings': 0.0,
        'totalPayouts': 0.0,
        'availableBalance': 0.0,
        'payouts': <Map<String, dynamic>>[],
        'orderCount': 0,
      };
    }
  }

  /// Helper to build earnings response (fetches payouts from Firestore)
  Future<Map<String, dynamic>> _buildEarningsResponse({
    required String sellerId,
    required double totalEarnings,
    required double availableBalance,
    required List<Map<String, dynamic>> recentOrders,
    required int ordersCount,
  }) async {
    try {
      final payoutsSnap = await _firestore
          .collection('payouts')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      double totalPayouts = 0;
      final List<Map<String, dynamic>> payouts = payoutsSnap.docs.map((doc) {
        final data = doc.data();
        totalPayouts += (data['amount'] ?? 0).toDouble();
        return {...data, 'payoutId': doc.id};
      }).toList();

      return {
        'totalEarnings': totalEarnings,
        'totalPayouts': totalPayouts,
        'availableBalance': availableBalance - totalPayouts,
        'payouts': payouts,
        'orderCount': ordersCount,
      };
    } catch (e) {
      AppLogger.error('Error fetching seller earnings', error: e);
      return {
        'totalEarnings': totalEarnings,
        'totalPayouts': 0.0,
        'availableBalance': availableBalance,
        'payouts': <Map<String, dynamic>>[],
        'orderCount': ordersCount,
      };
    }
  }

  /// Submit a payout request
  Future<Map<String, dynamic>> requestPayout({
    required String sellerId,
    required double amount,
    required String method,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      await _firestore.collection('payouts').add({
        'sellerId': sellerId,
        'amount': amount,
        'method': method,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'message': 'Payout request submitted!'};
    } catch (e) {
      AppLogger.error('Error requesting payout', error: e);
      return {'success': false, 'message': 'Failed to submit payout request.'};
    }
  }

  // ======================================================================
  // SELLER REQUEST METHODS (from seller_request_service.dart)
  // ======================================================================

  /// Get all seller requests
  List<Map<String, dynamic>> getAllRequests() {
    return List.unmodifiable(_sellerRequests);
  }

  /// Get pending seller requests
  List<Map<String, dynamic>> getPendingRequests() {
    return _sellerRequests.where((r) => r['status'] == 'pending').toList();
  }

  /// Get approved seller requests
  List<Map<String, dynamic>> getApprovedRequests() {
    return _sellerRequests.where((r) => r['status'] == 'approved').toList();
  }

  /// Get rejected seller requests
  List<Map<String, dynamic>> getRejectedRequests() {
    return _sellerRequests.where((r) => r['status'] == 'rejected').toList();
  }

  /// Get request by ID
  Map<String, dynamic>? getRequestById(String requestId) {
    try {
      return _sellerRequests.firstWhere((r) => r['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  /// Submit a seller upgrade request
  Future<void> submitSellerRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    List<String>? categories,
  }) async {
    try {
      final requestId = 'seller_req_${DateTime.now().millisecondsSinceEpoch}';

      final existingRequest = _sellerRequests.firstWhere(
        (r) => r['userId'] == userId && r['status'] == 'pending',
        orElse: () => <String, dynamic>{},
      );

      if (existingRequest.isNotEmpty) {
        AppLogger.warning('User already has a pending seller request');
        return;
      }

      final request = {
        'id': requestId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userPhone': userPhone,
        'status': 'pending',
        'adminNotes': '',
        'createdAt': DateTime.now().toIso8601String(),
        'reviewedAt': null,
        'reviewedBy': null,
      };

      _sellerRequests.insert(0, request);

      AppLogger.info('Seller request submitted: $requestId');
    } catch (e) {
      AppLogger.error('Error submitting seller request', error: e);
    }
  }

  /// Approve seller request (Admin action)
  Future<void> approveSellerRequest({
    required String requestId,
    required String adminId,
    String adminNotes = '',
  }) async {
    try {
      final index = _sellerRequests.indexWhere((r) => r['id'] == requestId);

      if (index != -1) {
        _sellerRequests[index]['status'] = 'approved';
        _sellerRequests[index]['adminNotes'] = adminNotes;
        _sellerRequests[index]['reviewedAt'] = DateTime.now().toIso8601String();
        _sellerRequests[index]['reviewedBy'] = adminId;

        AppLogger.info('Seller request approved: $requestId');
      }
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
    }
  }

  /// Reject seller request (Admin action)
  Future<void> rejectSellerRequest({
    required String requestId,
    required String adminId,
    required String rejectionReason,
  }) async {
    try {
      final index = _sellerRequests.indexWhere((r) => r['id'] == requestId);

      if (index != -1) {
        _sellerRequests[index]['status'] = 'rejected';
        _sellerRequests[index]['adminNotes'] = rejectionReason;
        _sellerRequests[index]['reviewedAt'] = DateTime.now().toIso8601String();
        _sellerRequests[index]['reviewedBy'] = adminId;

        AppLogger.info('Seller request rejected: $requestId');
      }
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
    }
  }

  /// Get request status
  String getRequestStatus(String requestId) {
    final request = getRequestById(requestId);
    return request?['status'] ?? 'unknown';
  }

  /// Check if user has approved seller request
  bool hasApprovedSellerRequest(String userId) {
    return _sellerRequests.any((r) =>
        r['userId'] == userId && r['status'] == 'approved');
  }

  /// Check if user has pending seller request
  bool hasPendingSellerRequest(String userId) {
    return _sellerRequests.any((r) =>
        r['userId'] == userId && r['status'] == 'pending');
  }

  // ======================================================================
  // UTILITY METHODS
  // ======================================================================

  List<String> getProductCategories() {
    return [
      'Electronics',
      'Fashion',
      'Books',
      'Sports',
      'Food & Beverages',
      'Health & Beauty',
      'Home & Garden',
      'Automotive',
      'Toys & Games',
      'Music & Movies',
      'Office Supplies',
      'Other',
    ];
  }

  List<String> getStoreCategories() {
    return [
      'Electronics Store',
      'Fashion Boutique',
      'Bookstore',
      'Sports Equipment',
      'Food & Beverages',
      'Beauty & Cosmetics',
      'Home & Garden',
      'Automotive Parts',
      'Toy Store',
      'Entertainment',
      'Office Supplies',
      'General Store',
    ];
  }
}