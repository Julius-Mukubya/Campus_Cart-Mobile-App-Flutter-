import 'package:flutter/foundation.dart';
import 'package:madpractical/services/notification_manager.dart';

class OrderManager extends ChangeNotifier {
  static final OrderManager _instance = OrderManager._internal();
  
  factory OrderManager() {
    return _instance;
  }
  
  OrderManager._internal();

  final List<Map<String, dynamic>> _orders = [];

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
      print('Error notifying seller: $e');
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
}
