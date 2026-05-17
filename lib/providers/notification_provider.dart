import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/services/database/database_service.dart';
import 'package:madpractical/services/managers/preferences_service.dart';

/// Notification state model - represents notifications data
class NotificationState {
  final List<Map<String, dynamic>> notifications;

  const NotificationState({
    this.notifications = const [],
  });

  int get unreadCount => notifications.where((n) => n['isRead'] == false).length;

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

/// NotificationNotifier - handles notification state updates
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  final _db = DatabaseService();

  /// Load persisted notifications from SQLite (call after DB init in main.dart)
  Future<void> loadFromDb() async {
    final userId = PreferencesService.userId;
    if (userId == null || userId.isEmpty) return;
    final rows = await _db.getNotifications(userId);
    state = state.copyWith(notifications: rows);
  }

  /// Persist and display a new notification
  Future<void> addNotification(Map<String, dynamic> notification) async {
    final userId = PreferencesService.userId ?? '';
    await _db.insertNotification(notification, userId);
    await loadFromDb();
  }

  Future<void> markAsRead(String id) async {
    await _db.markNotificationRead(id);
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    final index = updatedNotifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      updatedNotifications[index] = {...updatedNotifications[index], 'isRead': true};
      state = state.copyWith(notifications: updatedNotifications);
    }
  }

  Future<void> markAllAsRead() async {
    final userId = PreferencesService.userId ?? '';
    await _db.markAllNotificationsRead(userId);
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    for (var i = 0; i < updatedNotifications.length; i++) {
      updatedNotifications[i] = {...updatedNotifications[i], 'isRead': true};
    }
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> deleteNotification(String id) async {
    await _db.deleteNotification(id);
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    updatedNotifications.removeWhere((n) => n['id'] == id);
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> clearAll() async {
    final userId = PreferencesService.userId ?? '';
    await _db.clearNotifications(userId);
    state = const NotificationState(notifications: []);
  }
}

/// Notification provider - provides access to notification state
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
