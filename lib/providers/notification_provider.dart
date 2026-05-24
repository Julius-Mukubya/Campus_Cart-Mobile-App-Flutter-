import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/models/notification_model.dart';
import 'package:madpractical/services/notification_service.dart';

/// Notification state model
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// NotificationNotifier - handles notification state with real-time Firestore
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _notificationsSub;
  String? _currentUserId;

  NotificationNotifier() : super(const NotificationState());

  @override
  void dispose() {
    _notificationsSub?.cancel();
    super.dispose();
  }

  /// Start streaming notifications for a user
  void startListening(String userId) {
    if (userId.isEmpty) return;
    _currentUserId = userId;
    _notificationsSub?.cancel();
    state = state.copyWith(isLoading: true);
    _notificationsSub = _notificationService.notificationsStream(userId).listen(
      (notifications) {
        if (mounted) {
          state = state.copyWith(notifications: notifications, isLoading: false);
        }
      },
      onError: (e) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  /// Stop listening
  void stopListening() {
    _notificationsSub?.cancel();
    _currentUserId = null;
  }

  Future<void> markAsRead(String id) async {
    if (_currentUserId == null) return;
    await _notificationService.markAsRead(_currentUserId!, id);
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    await _notificationService.markAllAsRead(_currentUserId!);
  }

  Future<void> deleteNotification(String id) async {
    if (_currentUserId == null) return;
    await _notificationService.deleteNotification(_currentUserId!, id);
  }

  Future<void> clearAll() async {
    if (_currentUserId == null) return;
    final currentIds = state.notifications.map((n) => n.id).toList();
    for (final id in currentIds) {
      await _notificationService.deleteNotification(_currentUserId!, id);
    }
  }
}

/// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});