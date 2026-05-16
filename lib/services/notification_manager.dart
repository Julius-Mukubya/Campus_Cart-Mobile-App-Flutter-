import 'package:flutter/foundation.dart';
import 'package:madpractical/services/database_service.dart';
import 'package:madpractical/services/preferences_service.dart';

class NotificationManager extends ChangeNotifier {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final _db = DatabaseService();
  final List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  /// Load persisted notifications from SQLite. Call after DB init in main.dart.
  Future<void> loadFromDb() async {
    final userId = PreferencesService.userId;
    if (userId == null || userId.isEmpty) return;
    final rows = await _db.getNotifications(userId);
    _notifications
      ..clear()
      ..addAll(rows);
    notifyListeners();
  }

  /// Persist and display a new notification.
  Future<void> addNotification(Map<String, dynamic> notification) async {
    final userId = PreferencesService.userId ?? '';
    await _db.insertNotification(notification, userId);
    await loadFromDb();
  }

  Future<void> markAsRead(String id) async {
    await _db.markNotificationRead(id);
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index] = {..._notifications[index], 'isRead': true};
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = PreferencesService.userId ?? '';
    await _db.markAllNotificationsRead(userId);
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = {..._notifications[i], 'isRead': true};
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _db.deleteNotification(id);
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    final userId = PreferencesService.userId ?? '';
    await _db.clearNotifications(userId);
    _notifications.clear();
    notifyListeners();
  }
}
