import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';

class OrderService {
  final FirebaseFirestore _firestore;

  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new order
  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
    required double total,
    String? customerId,
    String? sellerId,
  }) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        'items': items,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'total': total,
        'customerId': customerId,
        'sellerId': sellerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating order', error: e);
      rethrow;
    }
  }

  /// Confirm an order after payment
  Future<void> confirmOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'confirmed': true,
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Error confirming order', error: e);
      rethrow;
    }
  }

  /// Get orders for a user
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching orders', error: e);
      return [];
    }
  }

  /// Get orders for a seller
  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching seller orders', error: e);
      return [];
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status, {String? reason}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (reason != null) updates['rejectionReason'] = reason;
      await _firestore.collection('orders').doc(orderId).update(updates);
    } catch (e) {
      AppLogger.error('Error updating order status', error: e);
      rethrow;
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }
}