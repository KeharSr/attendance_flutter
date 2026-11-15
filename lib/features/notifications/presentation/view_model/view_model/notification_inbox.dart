import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final notificationInboxProvider =
    AsyncNotifierProvider<NotificationInbox, List<AppNotification>>(
      NotificationInbox.new,
    );

class NotificationInbox extends AsyncNotifier<List<AppNotification>> {
  Future<void> _pending = Future<void>.value();
  int _generation = 0;

  @override
  Future<List<AppNotification>> build() async {
    _generation++;
    if (!ref.watch(authSessionProvider)) return const [];
    final userId = ref.read(appSharedPrefsProvider).getUserId();
    if (userId == null || userId.isEmpty) return const [];
    return ref.read(notificationLocalDataSourceProvider).readInbox(userId);
  }

  Future<void> reload() => _update();

  Future<void> record(AppNotification message) => _update(message);

  Future<void> _update([AppNotification? message]) {
    if (!ref.read(authSessionProvider)) return Future<void>.value();
    final userId = ref.read(appSharedPrefsProvider).getUserId();
    if (userId == null || userId.isEmpty) {
      if (kDebugMode) {
        debugPrint('[notifications] Inbox skipped: saved user ID is missing.');
      }
      return Future<void>.value();
    }
    final generation = _generation;
    final local = ref.read(notificationLocalDataSourceProvider);
    bool current() =>
        ref.mounted &&
        generation == _generation &&
        ref.read(authSessionProvider) &&
        ref.read(appSharedPrefsProvider).getUserId() == userId;
    final operation = _pending.then((_) async {
      if (!current()) return;
      // Let the initial disk read finish before publishing an updated inbox.
      try {
        await future;
      } catch (_) {
        /* A refresh can recover a failed read. */
      }
      if (!current()) return;
      if (message != null) await local.saveNotification(userId, message);
      final messages = await local.readInbox(userId);
      if (current()) {
        state = AsyncData(messages);
        if (kDebugMode) {
          debugPrint(
            '[notifications] Inbox loaded: ${messages.length} saved notifications.',
          );
        }
      }
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        if (kDebugMode) {
          debugPrint('[notifications] Inbox update failed: $error');
        }
        if (current()) state = AsyncError(error, stack);
      },
    );
    return _pending;
  }
}
