import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  // Lazy access keeps unsupported platforms and widget tests independent
  // of the Firebase platform plugin.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      Firebase.apps.isNotEmpty;

  Stream<String> get registrations => _messaging.onRegistered;
  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;
  Stream<RemoteMessage> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> initialize() async {
    await _setForegroundPresentation(false);
    return _messaging.getInitialMessage();
  }

  Future<bool> permissionGranted({required bool requestPermission}) async {
    final settings = requestPermission
        ? await _messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
        : await _messaging.getNotificationSettings();
    if (kDebugMode) {
      debugPrint(
        '[notifications] Permission: ${settings.authorizationStatus.name}',
      );
    }
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> register() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          await _messaging.getAPNSToken() == null) {
        // Retry on app resume. Avoid blocking app startup on APNs registration.
        throw StateError('APNs registration is not ready yet.');
      }
      if (kDebugMode) debugPrint('[notifications] Registering with Firebase.');
      await _messaging.setAutoInitEnabled(true);
      await _setForegroundPresentation(true);
      await _messaging.register();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[notifications] Firebase registration failed '
          '(${error.code}): ${error.message}',
        );
      }
      rethrow;
    }
  }

  Future<void> unregister() async {
    await _messaging.setAutoInitEnabled(false);
    await _setForegroundPresentation(false);
    await _messaging.unregister();
  }

  Future<void> _setForegroundPresentation(bool enabled) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: enabled,
        badge: enabled,
        sound: enabled,
      );
    }
  }
}
