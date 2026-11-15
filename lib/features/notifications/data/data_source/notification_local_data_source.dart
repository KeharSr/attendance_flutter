import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:attendance_flutter/features/notifications/data/model/notification_model.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';

class NotificationLocalDataSource {
  const NotificationLocalDataSource({required this.preferences});

  final SharedPreferences preferences;
  static const _installationIdsKey = 'notification_installation_ids';
  static const _permissionRequestedKey = 'notification_permission_requested';

  String _inboxPrefix(String userId) =>
      'notification_inbox_${Uri.encodeComponent(userId)}_';

  Future<List<AppNotification>> readInbox(String userId) async {
    // Background Firebase delivery runs in another isolate with its own cache.
    await preferences.reload();
    final messages = <AppNotification>[];
    for (final key in preferences.getKeys().where(
      (key) => key.startsWith(_inboxPrefix(userId)),
    )) {
      try {
        final json = jsonDecode(preferences.getString(key)!);
        messages.add(
          NotificationModel.fromJson(Map<String, dynamic>.from(json as Map)),
        );
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    messages.sort(
      (a, b) => (b.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        a.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    return messages;
  }

  Future<void> saveNotification(String userId, AppNotification message) async {
    if (userId.isEmpty || message.displayText.isEmpty) return;
    final sentAt = message.sentAt ?? DateTime.now().toUtc();
    final id =
        message.id ??
        jsonEncode([
          message.type,
          message.title,
          message.body,
          sentAt.toIso8601String(),
        ]);
    final key = '${_inboxPrefix(userId)}${Uri.encodeComponent(id)}';
    final json = NotificationModel.toJson(message)
      ..['sentAt'] = sentAt.toIso8601String();
    // A key per event deduplicates retries and avoids a read/modify/write race
    // between foreground and background isolates receiving different messages.
    if (!await preferences.setString(key, jsonEncode(json))) {
      throw StateError('Unable to save the received notification.');
    }
  }

  List<String> get installationIds => List.of(
    preferences.getStringList(_installationIdsKey) ?? const <String>[],
  );

  bool get permissionRequested =>
      preferences.getBool(_permissionRequestedKey) ?? false;

  Future<void> markPermissionRequested() async {
    if (!await preferences.setBool(_permissionRequestedKey, true)) {
      throw StateError('Unable to save notification permission preference.');
    }
  }

  Future<void> remember(String id) async {
    final ids = {...installationIds, id}.toList();
    if (!await preferences.setStringList(_installationIdsKey, ids)) {
      throw StateError('Unable to save notification installation.');
    }
  }

  Future<void> forget(String id) async {
    final ids = installationIds..remove(id);
    if (!await preferences.setStringList(_installationIdsKey, ids)) {
      throw StateError('Unable to remove notification installation.');
    }
  }
}
