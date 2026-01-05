import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler - must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message: ${message.notification?.title}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('🔔 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // Get FCM Token
        await _getToken();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from a notification
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔔 FCM Token refreshed: $newToken');
        });

        debugPrint('✅ Push notifications initialized');
      } else {
        debugPrint('❌ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Push notification error: $e');
    }
  }

  Future<void> _getToken() async {
    try {
      // For iOS/macOS, we might need to wait for APNS token
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        // Try to get APNS token first
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('⚠️ APNS token not available yet (this is normal on simulator/macOS)');
          debugPrint('⚠️ Push notifications may not work without APNS setup');
          debugPrint('💡 TIP: Test push notifications on Android for easier setup');
          
          // Still try to get FCM token
          _fcmToken = await _messaging.getToken();
        } else {
          debugPrint('✅ APNS Token available');
          _fcmToken = await _messaging.getToken();
        }
      } else {
        // Android or Web - just get FCM token directly
        _fcmToken = await _messaging.getToken();
      }

      if (_fcmToken != null) {
        debugPrint('════════════════════════════════════════════');
        debugPrint('🔥 FCM TOKEN (copy this for testing):');
        debugPrint(_fcmToken!);
        debugPrint('════════════════════════════════════════════');
      } else {
        debugPrint('⚠️ FCM Token not available');
      }
    } catch (e) {
      debugPrint('⚠️ Error getting token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('════════════════════════════════════════════');
    debugPrint('🔔 FOREGROUND NOTIFICATION RECEIVED!');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    debugPrint('════════════════════════════════════════════');
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔔 Notification tapped: ${message.notification?.title}');
    final type = message.data['type'];
    debugPrint('🔔 Notification type: $type');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('🔔 Subscribed to: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('🔔 Unsubscribed from: $topic');
  }
}