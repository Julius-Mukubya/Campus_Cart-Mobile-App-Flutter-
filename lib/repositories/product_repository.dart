import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/models/product.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/utils/exceptions.dart';

/// Repository for product data operations.
/// Wraps Firestore calls for product access.
class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch all products from Firestore.
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('ProductRepository.getProducts failed', error: e);
      throw RepositoryException(
        'Failed to fetch products',
        operation: 'getProducts',
        originalError: e,
      );
    }
  }

  /// Fetch a single product by its document ID.
  Future<Product> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (!doc.exists) {
        throw RepositoryException('Product not found', operation: 'getProductById');
      }
      return Product.fromJson(doc.data()!, doc.id);
    } on RepositoryException {
      rethrow;
    } catch (e) {
      AppLogger.error('ProductRepository.getProductById failed', error: e);
      throw RepositoryException(
        'Failed to fetch product',
        operation: 'getProductById',
        originalError: e,
      );
    }
  }

  /// Fetch products filtered by a category ID or name.
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      AppLogger.error('ProductRepository.getProductsByCategory failed', error: e);
      throw RepositoryException(
        'Failed to fetch products by category',
        operation: 'getProductsByCategory',
        originalError: e,
      );
    }
  }

  /// Add a new product to Firestore.
  Future<void> addProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toJson());
    } catch (e) {
      AppLogger.error('ProductRepository.addProduct failed', error: e);
      throw RepositoryException(
        'Failed to add product',
        operation: 'addProduct',
        originalError: e,
      );
    }
  }

  /// Update an existing product in Firestore.
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      AppLogger.error('ProductRepository.updateProduct failed', error: e);
      throw RepositoryException(
        'Failed to update product',
        operation: 'updateProduct',
        originalError: e,
      );
    }
  }

  /// Delete a product from Firestore by its document ID.
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      AppLogger.error('ProductRepository.deleteProduct failed', error: e);
      throw RepositoryException(
        'Failed to delete product',
        operation: 'deleteProduct',
        originalError: e,
      );
    }
  }

  /// Search products by name (client-side filter).
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return getProducts();
      final all = await getProducts();
      final lowerQuery = query.toLowerCase();
      return all.where((p) =>
        p.name.toLowerCase().contains(lowerQuery) ||
        p.description.toLowerCase().contains(lowerQuery) ||
        p.category.toLowerCase().contains(lowerQuery),
      ).toList();
    } catch (e) {
      AppLogger.error('ProductRepository.searchProducts failed', error: e);
      throw RepositoryException(
        'Failed to search products',
        operation: 'searchProducts',
        originalError: e,
      );
    }
  }

  // ── SQLite caching (TASK 9) ──────────────────────────────────────────────
  // These methods will be reimplemented in TASK 9 - Offline Caching.
  // For now, they return empty lists as placeholders.

  /// Retrieve cached products from the local SQLite database.
  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    // TODO: Reimplement in TASK 9
    return [];
  }

  /// Store a list of products in the local SQLite cache.
  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    // TODO: Reimplement in TASK 9
  }
}