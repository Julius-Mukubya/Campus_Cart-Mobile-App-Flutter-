import 'package:flutter/foundation.dart';

class OrderManager extends ChangeNotifier {
  static final OrderManager _instance = OrderManager._internal();
  
  factory OrderManager() {
    return _instance;
  }
  
  OrderManager._internal();

  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  
  int get orderCount => _orders.length;
  
  void addOrder(Map<String, dynamic> order) {
    _orders.insert(0, order);
    notifyListeners();
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
