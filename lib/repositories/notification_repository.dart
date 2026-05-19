import 'package:sqflite/sqflite.dart';
import '../utils/exceptions.dart';
import '../utils/app_logger.dart';

class NotificationRepository {
  static final NotificationRepository _instance = NotificationRepository._internal();
  late Database _db;
  bool _initialized = false;

  factory NotificationRepository() {
    return _instance;
  }

  NotificationRepository._internal();

  /// Initialize database connection
  Future<void> initialize(Database database) async {
    if (!_initialized) {
      _db = database;
      _initialized = true;
    }
  }

  /// Get all notifications for a user
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final notifications = await _db.query(
        'notifications',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      return notifications;
    } catch (e) {
      AppLogger.error('Failed to fetch user notifications', error: e);
      throw RepositoryException('Failed to fetch notifications: $e');
    }
  }

  /// Get unread notification count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE userId = ? AND isRead = 0',
        [userId],
      );
      return result.isNotEmpty ? result[0]['count'] as int : 0;
    } catch (e) {
      AppLogger.error('Failed to get unread count', error: e);
      throw RepositoryException('Failed to get unread count: $e');
    }
  }

  /// Add a new notification
  Future<int> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _db.insert(
        'notifications',
        {
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'metadata': metadata != null ? Uri.encodeComponent(Uri.encodeComponent(metadata.toString())) : null,
          'isRead': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      AppLogger.error('Failed to add notification', error: e);
      throw RepositoryException('Failed to add notification: $e');
    }
  }

  /// Mark notification as read
  Future<int> markAsRead(int notificationId) async {
    try {
      return await _db.update(
        'notifications',
        {
          'isRead': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
      throw RepositoryException('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<int> markAllAsRead(String userId) async {
    try {
      return await _db.update(
        'notifications',
        {
          'isRead': 1,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
      throw RepositoryException('Failed to mark all as read: $e');
    }
  }

  /// Delete a notification
  Future<int> deleteNotification(int notificationId) async {
    try {
      return await _db.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      AppLogger.error('Failed to delete notification', error: e);
      throw RepositoryException('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<int> deleteAllNotifications(String userId) async {
    try {
      return await _db.delete(
        'notifications',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      AppLogger.error('Failed to delete all notifications', error: e);
      throw RepositoryException('Failed to delete all notifications: $e');
    }
  }

  /// Get notifications by type
  Future<List<Map<String, dynamic>>> getNotificationsByType(
    String userId,
    String type,
  ) async {
    try {
      return await _db.query(
        'notifications',
        where: 'userId = ? AND type = ?',
        whereArgs: [userId, type],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      AppLogger.error('Failed to fetch notifications by type', error: e);
      throw RepositoryException('Failed to fetch notifications: $e');
    }
  }
}
