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

    // Request permissions (iOS)
    final messagingSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.info('FCM permission granted: ${messagingSettings.authorizationStatus}');

    // Get initial token
    _currentToken = await _messaging.getToken();
    if (_currentToken != null) {
      AppLogger.info('FCM token obtained');
      await _saveTokenToPrefs();
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM token refreshed');
      _currentToken = newToken;
      _saveTokenToPrefs();
      _uploadTokenToFirestore();
    });

    // Handle foreground messages via local notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage.data);
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

  /// Handle foreground FCM message — show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('FCM foreground message: ${message.messageId}');
    final data = message.data;
    final notification = message.notification;

    final title = notification?.title ?? data['title'] ?? 'Campus Cart';
    final body = notification?.body ?? data['message'] ?? data['body'] ?? '';

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
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    if (_currentToken == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({'fcmToken': _currentToken, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      AppLogger.error('Error uploading FCM token to Firestore', error: e);
    }
  }
}