import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';
import '../models/notification_model.dart';

/// Service for sending and managing notifications via Firestore.
class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to a user's notifications collection
  CollectionReference _notificationsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  /// Send a notification to a user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (userId.isEmpty) {
        AppLogger.warning('Cannot send notification: userId is empty');
        return;
      }

      await _notificationsRef(userId).add({
        'title': title,
        'message': message,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Notification sent to user $userId: [$type] $title');
    } catch (e) {
      AppLogger.error('Error sending notification', error: e);
    }
  }

  /// Stream notifications for a user (real-time)
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _notificationsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return NotificationModel.fromMap(data, doc.id);
            }).toList());
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      AppLogger.error('Error marking notification as read', error: e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error marking all notifications as read', error: e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting unread count', error: e);
      return 0;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).delete();
    } catch (e) {
      AppLogger.error('Error deleting notification', error: e);
    }
  }
}