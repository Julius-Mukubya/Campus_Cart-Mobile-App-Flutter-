import 'package:flutter/foundation.dart';

class OrderManager extends ChangeNotifier {
  static final OrderManager _instance = OrderManager._internal();
  
  factory OrderManager() {
    return _instance;
  }
  
  OrderManager._internal();

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2024-001',
      'date': '2024-11-25',
      'status': 'Delivered',
      'total': 215000.0,
      'items': 3,
      'products': [
        {'name': 'Wireless Headphones', 'quantity': 1, 'price': 85000.0},
        {'name': 'Designer T-Shirt', 'quantity': 2, 'price': 45000.0},
        {'name': 'Coffee Maker', 'quantity': 1, 'price': 95000.0},
      ],
    },
    {
      'id': 'ORD-2024-002',
      'date': '2024-11-20',
      'status': 'In Transit',
      'total': 120000.0,
      'items': 1,
      'products': [
        {'name': 'Smart Watch', 'quantity': 1, 'price': 120000.0},
      ],
    },
    {
      'id': 'ORD-2024-003',
      'date': '2024-11-15',
      'status': 'Processing',
      'total': 75000.0,
      'items': 1,
      'products': [
        {'name': 'Running Shoes', 'quantity': 1, 'price': 75000.0},
      ],
    },
  ];

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
}
