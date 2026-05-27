import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

class OrderService {
  final FirebaseFirestore _firestore;
  final OrderRepository? _orderRepository;
  final NotificationService _notificationService;

  OrderService({FirebaseFirestore? firestore, OrderRepository? orderRepository, NotificationService? notificationService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _orderRepository = orderRepository,
        _notificationService = notificationService ?? NotificationService();

  /// ── New Order ──────────────────────────────────────────────────────

  /// Create a new order (simplified — no delivery address, no payment)
  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String sellerId,
    required bool showContactToSeller,
  }) async {
    try {
      final orderData = {
        'items': items,
        'total': total,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'sellerId': sellerId,
        'showContactToSeller': showContactToSeller,
        'status': 'pending',
        'sellerConfirmed': false,
        'customerConfirmed': false,
        'rejectionReason': null,
      };

      if (_orderRepository != null) {
        return await _orderRepository.createOrder(orderData);
      }

      final docRef = await _firestore.collection('orders').add({
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Order created: ${docRef.id}');

      // Notify customer
      _notificationService.sendNotification(
        userId: customerId,
        title: 'Order Placed',
        message: 'Your order #${docRef.id} has been placed successfully.',
        type: 'success',
        data: {'orderId': docRef.id},
      );
      // Notify seller
      _notificationService.sendNotification(
        userId: sellerId,
        title: 'New Order',
        message: 'New order from $customerName.',
        type: 'primary',
        data: {'orderId': docRef.id},
      );
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating order', error: e);
      rethrow;
    }
  }

  /// ── Accept / Reject ────────────────────────────────────────────────

  /// Seller accepts an order
  Future<void> acceptOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) throw Exception('Order not found');
      final orderData = doc.data()!;
      final sellerId = orderData['sellerId'] as String? ?? '';

      await _firestore.collection('orders').doc(orderId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Order accepted: $orderId');

      // Fetch seller details for the notification
      String sellerName = 'the seller';
      String sellerPhone = '';
      if (sellerId.isNotEmpty) {
        try {
          final sellerDoc = await _firestore.collection('users').doc(sellerId).get();
          if (sellerDoc.exists) {
            final sellerData = sellerDoc.data()!;
            sellerName = sellerData['name'] ?? sellerData['displayName'] ?? 'the seller';
            sellerPhone = sellerData['phone'] ?? '';
          }
        } catch (_) {
          // Fallback to generic name
        }
      }

      // Notify customer with seller details
      final customerId = orderData['customerId'] as String? ?? '';
      if (customerId.isNotEmpty) {
        String message = 'Order accepted by $sellerName';
        if (sellerPhone.isNotEmpty && orderData['showContactToSeller'] == true) {
          message += ' — Contact: $sellerPhone';
        }
        _notificationService.sendNotification(
          userId: customerId,
          title: 'Order Accepted',
          message: message,
          type: 'success',
          data: {'orderId': orderId},
        );
      }
    } catch (e) {
      AppLogger.error('Error accepting order', error: e);
      rethrow;
    }
  }

  /// Seller rejects an order (reason is required)
  Future<void> rejectOrder(String orderId, String reason) async {
    try {
      if (reason.trim().isEmpty) {
        throw Exception('Rejection reason is required');
      }
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Order rejected: $orderId');

      // Notify customer
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final customerId = data['customerId'] as String? ?? '';
        if (customerId.isNotEmpty) {
          _notificationService.sendNotification(
            userId: customerId,
            title: 'Order Rejected',
            message: 'Your order #$orderId has been rejected. Reason: $reason',
            type: 'error',
            data: {'orderId': orderId},
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error rejecting order', error: e);
      rethrow;
    }
  }

  /// ── Dual Confirmation Completion ───────────────────────────────────

  /// Mark seller's confirmation for completion
  Future<void> markSellerComplete(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'sellerConfirmed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _checkAndComplete(orderId);
    } catch (e) {
      AppLogger.error('Error marking seller complete', error: e);
      rethrow;
    }
  }

  /// Mark customer's confirmation for completion
  Future<void> markCustomerComplete(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'customerConfirmed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _checkAndComplete(orderId);
    } catch (e) {
      AppLogger.error('Error marking customer complete', error: e);
      rethrow;
    }
  }

  /// Check if both confirmed and mark as completed
  Future<void> _checkAndComplete(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      if (data['sellerConfirmed'] == true && data['customerConfirmed'] == true) {
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        AppLogger.info('Order completed: $orderId');

        // Notify both parties
        final customerId = data['customerId'] as String? ?? '';
        final sellerId = data['sellerId'] as String? ?? '';
        if (customerId.isNotEmpty) {
          _notificationService.sendNotification(
            userId: customerId,
            title: 'Order Complete!',
            message: 'Your order #$orderId is complete. Leave a review!',
            type: 'success',
            data: {'orderId': orderId},
          );
        }
        if (sellerId.isNotEmpty) {
          _notificationService.sendNotification(
            userId: sellerId,
            title: 'Order Completed',
            message: 'Order #$orderId has been completed.',
            type: 'success',
            data: {'orderId': orderId},
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error checking completion', error: e);
    }
  }

  /// ── Customer Cancel ────────────────────────────────────────────────

  /// Customer cancels an order (only when status is 'pending')
  Future<void> cancelOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) throw Exception('Order not found');
      final status = doc.data()!['status'] as String? ?? '';
      if (status != 'pending') {
        throw Exception('Can only cancel pending orders');
      }
      final orderData = doc.data()!;
      final sellerId = orderData['sellerId'] as String? ?? '';
      final customerName = orderData['customerName'] as String? ?? 'A customer';

      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Order cancelled: $orderId');

      // Notify seller
      if (sellerId.isNotEmpty) {
        _notificationService.sendNotification(
          userId: sellerId,
          title: 'Order Cancelled',
          message: '$customerName cancelled their order #$orderId.',
          type: 'error',
          data: {'orderId': orderId},
        );
      }
    } catch (e) {
      AppLogger.error('Error cancelling order', error: e);
      rethrow;
    }
  }

  /// ── Follow-up ──────────────────────────────────────────────────────

  /// Customer follow-up — re-enables chat on a completed order
  Future<void> enableFollowUp(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'followUp': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Follow-up enabled for order: $orderId');
    } catch (e) {
      AppLogger.error('Error enabling follow-up', error: e);
      rethrow;
    }
  }

  /// ── Fetch Orders ───────────────────────────────────────────────────

  /// Get orders for a customer
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
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
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching seller orders', error: e);
      return [];
    }
  }

  /// Update order status (generic)
  Future<void> updateOrderStatus(String orderId, String status, {String? reason}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (reason != null) updates['rejectionReason'] = reason;
      await _firestore.collection('orders').doc(orderId).update(updates);
      AppLogger.info('Order status updated: $orderId -> $status');
    } catch (e) {
      AppLogger.error('Error updating order status', error: e);
      rethrow;
    }
  }
}