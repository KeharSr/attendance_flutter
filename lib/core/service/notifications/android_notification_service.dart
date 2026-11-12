import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Displays received pushes using Android's notification manager. Delivery
/// remains Firebase-based; this adapter only handles foreground presentation.
class AndroidNotificationService {
  static const channel = MethodChannel(
    'com.kehar.attendance_flutter/notifications',
  );

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> initialize({required void Function(String type) onTap}) async {
    if (!isSupported) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'notificationTapped' && call.arguments is String) {
        onTap(call.arguments as String);
      }
    });
    final initialType = await _invoke<String>('initialize');
    if (initialType != null) onTap(initialType);
  }

  Future<bool> show({
    required String title,
    required String body,
    String? type,
    String? messageId,
  }) async {
    if (!isSupported) return false;
    return await _invoke<bool>('show', {
          'title': title,
          'body': body,
          'type': type,
          'messageId': messageId,
        }) ??
        false;
  }

  Future<void> clear() async {
    if (isSupported) await _invoke<void>('clear');
  }

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      // Unit tests and an app awaiting its first full native rebuild.
      return null;
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('[notifications] Android display failed (${error.code}).');
      }
      return null;
    }
  }

  void dispose() {
    if (isSupported) channel.setMethodCallHandler(null);
  }
}
