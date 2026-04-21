import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Top-level handler — must be a plain function (not a method) so FCM can
/// invoke it when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work here — just logging or silent data processing.
  debugPrint('FCM background message: ${message.messageId}');
}

class FCMService {
  FCMService._(); // prevent instantiation

  static final _messaging = FirebaseMessaging.instance;

  /// Call once from main() — before runApp.
  /// Requests permission and wires up message handlers.
  /// Does NOT need a userId.
  static Future<void> setup() async {
    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
     FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    print("FCM Token: $token");
    // Request notification permission (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages — show an in-app banner or update chat UI
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
      // TODO: show a local notification or update chat badge here
    });

    // Tapped notification when app was in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened from background: ${message.notification?.title}');
      // TODO: navigate to the relevant chat screen
    });

    // Notification that launched the app from terminated state
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('FCM launched app: ${initial.notification?.title}');
      // TODO: navigate after the app is fully initialised
    }
  }

  /// Call this once after the user has logged in (e.g. in AuthProvider).
  /// Saves the device FCM token to Firestore so the server can target this user.
  static Future<void> registerToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      debugPrint('FCM token: $token');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));

      // Refresh token when it rotates
      _messaging.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'fcmToken': newToken}, SetOptions(merge: true))
            .catchError((_) {});
      });
    } catch (e) {
      debugPrint('FCM registerToken error: $e');
    }
  }

  /// Remove the token from Firestore on logout so the user stops receiving
  /// notifications for this account on this device.
  static Future<void> unregisterToken(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
    } catch (_) {}
  }
}
