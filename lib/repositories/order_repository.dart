import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/utils/exceptions.dart';

/// Repository for order data operations.
/// Wraps Firestore calls for order CRUD and real-time observation.
class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new order document in Firestore.
  /// Returns the generated document ID.
  Future<String> createOrder(Map<String, dynamic> order) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        ...order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      AppLogger.error('OrderRepository.createOrder failed', error: e);
      throw RepositoryException(
        'Failed to create order',
        operation: 'createOrder',
        originalError: e,
      );
    }
  }

  /// Fetch all orders for a specific user (customer).
  Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('OrderRepository.getOrdersByUser failed', error: e);
      throw RepositoryException(
        'Failed to fetch orders for user',
        operation: 'getOrdersByUser',
        originalError: e,
      );
    }
  }

  /// Fetch all orders for a specific seller.
  Future<List<Map<String, dynamic>>> getOrdersBySeller(String sellerId) async {
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
      AppLogger.error('OrderRepository.getOrdersBySeller failed', error: e);
      throw RepositoryException(
        'Failed to fetch orders for seller',
        operation: 'getOrdersBySeller',
        originalError: e,
      );
    }
  }

  /// Update the status of an order.
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('OrderRepository.updateOrderStatus failed', error: e);
      throw RepositoryException(
        'Failed to update order status',
        operation: 'updateOrderStatus',
        originalError: e,
      );
    }
  }

  /// Stream a single order document for real-time updates.
  Stream<Map<String, dynamic>> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw RepositoryException('Order not found', operation: 'watchOrder');
          }
          final data = doc.data()!;
          data['orderId'] = doc.id;
          return data;
        });
  }

  /// Stream orders for a specific user in real-time.
  Stream<List<Map<String, dynamic>>> watchOrdersByUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['orderId'] = doc.id;
              return data;
            }).toList());
  }
}