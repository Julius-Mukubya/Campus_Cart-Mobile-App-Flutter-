import 'package:flutter/foundation.dart';

class NotificationManager extends ChangeNotifier {
  static final NotificationManager _instance = NotificationManager._internal();
  
  factory NotificationManager() {
    return _instance;
  }
  
  NotificationManager._internal();

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Order Delivered',
      'message': 'Your order #ORD-2024-001 has been delivered successfully',
      'type': 'order',
      'time': '2 hours ago',
      'isRead': false,
      'icon': 'check_circle',
      'color': 'success',
    },
    {
      'id': '2',
      'title': 'Special Offer',
      'message': 'Get 30% off on all electronics! Limited time offer.',
      'type': 'promotion',
      'time': '5 hours ago',
      'isRead': false,
      'icon': 'local_offer',
      'color': 'accent',
    },
    {
      'id': '3',
      'title': 'Order Shipped',
      'message': 'Your order #ORD-2024-002 is on the way',
      'type': 'order',
      'time': '1 day ago',
      'isRead': true,
      'icon': 'local_shipping',
      'color': 'primary',
    },
    {
      'id': '4',
      'title': 'Price Drop Alert',
      'message': 'Smart Watch in your wishlist is now 15% off!',
      'type': 'price_drop',
      'time': '2 days ago',
      'isRead': true,
      'icon': 'trending_down',
      'color': 'success',
    },
    {
      'id': '5',
      'title': 'New Arrival',
      'message': 'Check out the latest collection of designer t-shirts',
      'type': 'new_arrival',
      'time': '3 days ago',
      'isRead': true,
      'icon': 'new_releases',
      'color': 'primary',
    },
  ];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    notifyListeners();
  }
  
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }
  
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
