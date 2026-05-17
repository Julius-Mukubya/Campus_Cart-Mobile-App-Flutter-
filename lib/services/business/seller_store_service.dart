import 'package:cloud_firestore/cloud_firestore.dart';

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

class SellerStoreService {
  static final SellerStoreService _instance = SellerStoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory SellerStoreService() {
    return _instance;
  }

  SellerStoreService._internal();

  /// Create a new store for a seller (only if seller is approved and hasn't exceeded store limit)
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
      print('Error creating store: $e');
      rethrow;
    }
  }

  /// Get all stores for an approved seller
  Future<List<SellerStore>> getStoresBySellerIfApproved(String sellerId) async {
    try {
      // Verify seller is approved
      final sellerDoc = await _firestore.collection('users').doc(sellerId).get();
      if (!sellerDoc.exists) {
        return [];
      }

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
      print('Error fetching seller stores: $e');
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
      print('Error fetching store: $e');
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
      print('Error updating store: $e');
      return false;
    }
  }

  /// Deactivate a store (soft delete)
  Future<bool> deactivateStore(String storeId) async {
    try {
      // Get store to find seller
      final storeDoc = await _firestore.collection('seller_stores').doc(storeId).get();
      if (!storeDoc.exists) return false;

      final storeData = storeDoc.data() as Map<String, dynamic>;
      final sellerId = storeData['sellerId'];

      // Deactivate store
      await _firestore.collection('seller_stores').doc(storeId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });

      // Decrement seller's store count
      await _firestore.collection('users').doc(sellerId).update({
        'storeCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error deactivating store: $e');
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
      print('Error fetching all stores: $e');
      return [];
    }
  }

  /// Get max allowed stores per seller
  Future<int> getMaxStoresPerSeller() async {
    try {
      final doc = await _firestore.collection('admin_settings').doc('seller_config').get();
      if (!doc.exists) {
        // Default to 1 if settings don't exist
        return 1;
      }

      final data = doc.data() as Map<String, dynamic>;
      return data['maxStoresPerSeller'] ?? 1;
    } catch (e) {
      print('Error fetching max stores config: $e');
      return 1; // Default fallback
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
      print('Error updating store rating: $e');
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
      print('Error fetching stores by location: $e');
      return [];
    }
  }
}
