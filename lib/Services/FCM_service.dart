import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  static Future<void> setup({required GlobalKey<NavigatorState> navigatorKey}) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('FCM Token: ${await _messaging.getToken()}');

    // Foreground: show an in-app SnackBar banner
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title;
      final body = message.notification?.body;
      if (title == null && body == null) return;

      final context = navigatorKey.currentContext;
      if (context == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.message, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                    if (body != null)
                      Text(body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF8B1A2B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    });

    // Background tap: go back to home screen
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });

    // Terminated tap: go back to home screen after app is built
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      });
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
