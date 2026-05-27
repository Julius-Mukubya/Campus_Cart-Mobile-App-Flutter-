import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_logger.dart';
import 'preferences_service.dart';

/// Global navigator key to handle navigation from background notifications
final GlobalKey<NavigatorState> fcmNavigatorKey = GlobalKey<NavigatorState>();

/// FCM service for push notifications and local notifications.
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;
  String? _currentUserId;

  /// Initialize FCM and local notifications
  Future<void> init() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions (iOS) - wrap in try-catch to handle permission errors
    try {
      final messagingSettings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.info('FCM permission granted: ${messagingSettings.authorizationStatus}');
    } catch (e) {
      AppLogger.warning('FCM permission request failed: $e');
    }

    // Get initial token - wrap in try-catch to handle Google Play Services issues
    try {
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        AppLogger.info('FCM token obtained successfully');
        AppLogger.info('FCM Token: $_currentToken');
        await _saveTokenToPrefs();
      } else {
        AppLogger.warning('FCM token is null - device may not have Google Play Services');
      }
    } catch (e) {
      AppLogger.warning('Failed to get FCM token: $e. Notifications will use local-only mode.');
    }

    // Listen for token refresh - wrap in try-catch
    try {
      _messaging.onTokenRefresh.listen((newToken) {
        AppLogger.info('FCM token refreshed');
        AppLogger.info('New FCM Token: $newToken');
        _currentToken = newToken;
        _saveTokenToPrefs();
        _uploadTokenToFirestore();
      });
    } catch (e) {
      AppLogger.warning('FCM token refresh listener failed: $e');
    }

    // Handle foreground messages via local notifications
    try {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e) {
      AppLogger.warning('FCM foreground message handler failed: $e');
    }

    // Handle background message tap (app opened from terminated state)
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage.data);
      }
    } catch (e) {
      AppLogger.warning('FCM initial message handler failed: $e');
    }
  }

  /// Register the top-level background message handler
  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    AppLogger.info('FCM background message: ${message.messageId}');
    // The message data is available for the app to process when opened
  }

  /// Set the current user ID and upload FCM token to Firestore
  Future<void> setUserId(String userId) async {
    _currentUserId = userId;
    if (_currentToken != null) {
      await _uploadTokenToFirestore();
    }
  }

  /// Clear user ID on logout
  Future<void> clearUserId() async {
    _currentUserId = null;
  }

  /// Handle foreground FCM message — show local notification and save to Firestore
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('FCM foreground message: ${message.messageId}');
    final data = message.data;
    final notification = message.notification;

    final title = notification?.title ?? data['title'] ?? 'Campus Cart';
    final body = notification?.body ?? data['message'] ?? data['body'] ?? '';

    // Save to Firestore notifications collection for the current user
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .collection('notifications')
            .add({
          'title': title,
          'message': body,
          'type': data['type'] ?? 'notification',
          'data': data,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        AppLogger.info('Push notification saved to Firestore');
      } catch (e) {
        AppLogger.warning('Failed to save push notification to Firestore: $e');
      }
    }

    // Show local notification
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      payload: data['type'] != null
          ? '${data['type']}|${data['referenceId'] ?? ''}'
          : null,
    );
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_cart_channel',
      'Campus Cart Notifications',
      channelDescription: 'Notifications from Campus Cart',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Handle notification tap (from local notification or FCM background tap)
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _navigateFromPayload(payload);
    }
  }

  void _handleMessageTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String? ?? '';
    if (type != null) {
      _navigateFromPayload('$type|$referenceId');
    }
  }

  /// Navigate based on notification type
  void _navigateFromPayload(String payload) {
    final parts = payload.split('|');
    if (parts.length < 2) return;
    final type = parts[0];
    final referenceId = parts[1];

    final context = fcmNavigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'order':
        context.push('/order-details/$referenceId');
        break;
      case 'chat':
        context.push('/chat/$referenceId');
        break;
      case 'notification':
        context.push('/notifications');
        break;
      case 'new_order':
        context.push('/seller/orders');
        break;
      case 'seller_request':
        context.push('/admin/dashboard');
        break;
      default:
        context.push('/notifications');
        break;
    }
  }

  /// Save token to local preferences
  Future<void> _saveTokenToPrefs() async {
    if (_currentToken != null) {
      await PreferencesService.setFcmToken(_currentToken!);
    }
  }

  /// Upload FCM token to Firestore user document
  Future<void> _uploadTokenToFirestore() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      AppLogger.warning('Cannot upload FCM token: userId is empty');
      return;
    }
    if (_currentToken == null) {
      AppLogger.warning('Cannot upload FCM token: token is null');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({
            'fcmToken': _currentToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp()
          });
      AppLogger.info('FCM token uploaded to Firestore for user: $_currentUserId');
    } catch (e) {
      AppLogger.error('Error uploading FCM token to Firestore', error: e);
    }
  }
}