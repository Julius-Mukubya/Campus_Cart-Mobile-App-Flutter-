import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// Notifications are stored in-memory for now.
/// Full Firestore sync will be implemented in TASK 6.
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  /// Load notifications (placeholder — in-memory only for now)
  void loadFromPrefs() {
    // Notifications are in-memory only. Will be connected to Firestore in TASK 6.
  }

  /// Add a new notification
  Future<void> addNotification(Map<String, dynamic> notification) async {
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    updatedNotifications.insert(0, notification);
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> markAsRead(String id) async {
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    final index = updatedNotifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      updatedNotifications[index] = {...updatedNotifications[index], 'isRead': true};
      state = state.copyWith(notifications: updatedNotifications);
    }
  }

  Future<void> markAllAsRead() async {
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    for (var i = 0; i < updatedNotifications.length; i++) {
      updatedNotifications[i] = {...updatedNotifications[i], 'isRead': true};
    }
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> deleteNotification(String id) async {
    final updatedNotifications = List<Map<String, dynamic>>.from(state.notifications);
    updatedNotifications.removeWhere((n) => n['id'] == id);
    state = state.copyWith(notifications: updatedNotifications);
  }

  Future<void> clearAll() async {
    state = const NotificationState(notifications: []);
  }
}

/// Notification provider - provides access to notification state
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
