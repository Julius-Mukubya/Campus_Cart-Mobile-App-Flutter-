import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/utils/exceptions.dart';

/// Repository for cart data operations.
/// Manages cart persistence via Firestore (per-user).
class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save the user's cart items to Firestore.
  /// Replaces the entire cart document for the given user.
  Future<void> saveCart(String userId, List<Map<String, dynamic>> items) async {
    try {
      await _firestore.collection('carts').doc(userId).set({
        'userId': userId,
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('CartRepository.saveCart failed', error: e);
      throw RepositoryException(
        'Failed to save cart',
        operation: 'saveCart',
        originalError: e,
      );
    }
  }

  /// Load the user's cart items from Firestore.
  /// Returns an empty list if no cart document exists.
  Future<List<Map<String, dynamic>>> loadCart(String userId) async {
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('CartRepository.loadCart failed', error: e);
      throw RepositoryException(
        'Failed to load cart',
        operation: 'loadCart',
        originalError: e,
      );
    }
  }

  /// Clear the user's cart document from Firestore.
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).delete();
    } catch (e) {
      AppLogger.error('CartRepository.clearCart failed', error: e);
      throw RepositoryException(
        'Failed to clear cart',
        operation: 'clearCart',
        originalError: e,
      );
    }
  }
}