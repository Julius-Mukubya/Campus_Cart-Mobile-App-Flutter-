import 'package:flutter/foundation.dart';
import 'package:madpractical/services/managers/notification_manager.dart';
import '../../utils/app_logger.dart';

class OrderManager extends ChangeNotifier {
  static final OrderManager _instance = OrderManager._internal();
  
  factory OrderManager() {
    return _instance;
  }
  
  OrderManager._internal();

  final List<Map<String, dynamic>> _orders = [];
  final Map<String, Map<String, dynamic>> _orderApprovals = {};

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  
  int get orderCount => _orders.length;
  
  /// Add a new order and send notification to seller
  /// The order should contain: customerName, customerPhone, shippingAddress, products, total
  Future<void> addOrder(Map<String, dynamic> order) async {
    _orders.insert(0, order);
    
    // Send notification to seller about new order
    await _notifySeller(order);
    
    notifyListeners();
  }
  
  /// Send a notification to the seller about a new order
  Future<void> _notifySeller(Map<String, dynamic> order) async {
    try {
      final notificationManager = NotificationManager();
      
      // Extract product seller info (in simplified version, products come from same seller)
      final products = order['products'] as List<Map<String, dynamic>>? ?? [];
      final totalItems = products.fold<int>(0, (sum, product) => sum + (product['quantity'] as int? ?? 0));
      
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'new_order',
        'title': 'New Order Received',
        'message': 'Customer ${order['customerName']} placed an order for $totalItems item(s)',
        'orderId': order['id'],
        'customerName': order['customerName'],
        'customerPhone': order['customerPhone'],
        'shippingAddress': order['shippingAddress'],
        'total': order['total'],
        'itemCount': totalItems,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };
      
      // For now, save to local notifications (in full implementation, this would go to Firebase)
      // and be fetched by the seller's device
      await notificationManager.addNotification(notification);
    } catch (e) {
      AppLogger.error('Error notifying seller', error: e);
    }
  }
  
  Map<String, dynamic>? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order['id'] == id);
    } catch (e) {
      return null;
    }
  }
  
  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = 'Cancelled';
      notifyListeners();
    }
  }
  
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  /// Approve order - seller confirms they can fulfill
  Future<void> approveOrder({
    required String orderId,
    required String sellerId,
    String approvalMessage = 'Your order has been approved. I will contact you shortly!',
  }) async {
    try {
      _orderApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'approved',
        'message': approvalMessage,
        'approvedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex =
          _orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex]['approvalStatus'] = 'approved';
        _orders[orderIndex]['approvedAt'] = DateTime.now().toIso8601String();
        _orders[orderIndex]['status'] = 'Approved';
      }

      // Notify customer about approval
      await _notifyCustomerOfApproval(orderId, approvalMessage);

      notifyListeners();
      AppLogger.info('Order approved: $orderId');
    } catch (e) {
      AppLogger.error('Error approving order', error: e);
    }
  }

  /// Reject order - seller cannot fulfill
  Future<void> rejectOrder({
    required String orderId,
    required String sellerId,
    required String rejectionReason,
  }) async {
    try {
      _orderApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'rejected',
        'reason': rejectionReason,
        'rejectedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex =
          _orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex]['approvalStatus'] = 'rejected';
        _orders[orderIndex]['rejectedAt'] = DateTime.now().toIso8601String();
        _orders[orderIndex]['status'] = 'Rejected';
      }

      // Notify customer about rejection
      await _notifyCustomerOfRejection(orderId, rejectionReason);

      notifyListeners();
      AppLogger.info('Order rejected: $orderId');
    } catch (e) {
      AppLogger.error('Error rejecting order', error: e);
    }
  }

  /// Get approval status of an order
  String getApprovalStatus(String orderId) {
    return _orderApprovals[orderId]?['status'] ?? 'pending';
  }

  /// Check if order is approved
  bool isOrderApproved(String orderId) {
    return getApprovalStatus(orderId) == 'approved';
  }

  /// Notify customer that their order has been approved
  Future<void> _notifyCustomerOfApproval(
      String orderId, String approvalMessage) async {
    try {
      final notificationManager = NotificationManager();

      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'order_approved',
        'title': 'Order Approved!',
        'message': approvalMessage,
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      await notificationManager.addNotification(notification);
      AppLogger.info('Customer notified of approval for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of approval', error: e);
    }
  }

  /// Notify customer that their order has been rejected
  Future<void> _notifyCustomerOfRejection(
      String orderId, String rejectionReason) async {
    try {
      final notificationManager = NotificationManager();

      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'order_rejected',
        'title': 'Order Rejected',
        'message':
            'Your order was rejected. Reason: $rejectionReason',
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      await notificationManager.addNotification(notification);
      AppLogger.info('Customer notified of rejection for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of rejection', error: e);
    }
  }
}

