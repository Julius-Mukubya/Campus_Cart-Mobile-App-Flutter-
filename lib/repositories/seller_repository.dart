import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/models/product.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/utils/exceptions.dart';

/// Repository for seller / store data operations.
/// Wraps Firestore calls for store and seller-specific product/order access.
class SellerRepository {
  final FirebaseFirestore _firestore;

  SellerRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch a seller's store document by seller user ID.
  Future<Map<String, dynamic>> getSeller(String sellerId) async {
    try {
      // Try querying stores by sellerId field
      final snapshot = await _firestore
          .collection('stores')
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['storeId'] = snapshot.docs.first.id;
        return data;
      }

      // Fallback: check user doc for a storeId reference
      final userDoc = await _firestore.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final storeId = userData['storeId'] as String?;
        if (storeId != null && storeId.isNotEmpty) {
          final storeDoc = await _firestore.collection('stores').doc(storeId).get();
          if (storeDoc.exists) {
            final data = storeDoc.data()!;
            data['storeId'] = storeDoc.id;
            return data;
          }
        }
      }

      throw RepositoryException('Seller not found', operation: 'getSeller');
    } on RepositoryException {
      rethrow;
    } catch (e) {
      AppLogger.error('SellerRepository.getSeller failed', error: e);
      throw RepositoryException(
        'Failed to fetch seller',
        operation: 'getSeller',
        originalError: e,
      );
    }
  }

  /// Update a seller's store document.
  Future<void> updateSeller(String sellerId, Map<String, dynamic> data) async {
    try {
      // Find the store doc first
      final seller = await getSeller(sellerId);
      final storeId = seller['storeId'] as String?;
      if (storeId == null || storeId.isEmpty) {
        throw RepositoryException('Store ID not found', operation: 'updateSeller');
      }
      await _firestore.collection('stores').doc(storeId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on RepositoryException {
      rethrow;
    } catch (e) {
      AppLogger.error('SellerRepository.updateSeller failed', error: e);
      throw RepositoryException(
        'Failed to update seller',
        operation: 'updateSeller',
        originalError: e,
      );
    }
  }

  /// Fetch all products belonging to a seller.
  Future<List<Product>> getSellerProducts(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('SellerRepository.getSellerProducts failed', error: e);
      throw RepositoryException(
        'Failed to fetch seller products',
        operation: 'getSellerProducts',
        originalError: e,
      );
    }
  }

  /// Fetch all orders for a seller.
  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('SellerRepository.getSellerOrders failed', error: e);
      throw RepositoryException(
        'Failed to fetch seller orders',
        operation: 'getSellerOrders',
        originalError: e,
      );
    }
  }

  /// Stream seller orders in real-time.
  Stream<List<Map<String, dynamic>>> watchSellerOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['orderId'] = doc.id;
              return data;
            }).toList());
  }
}