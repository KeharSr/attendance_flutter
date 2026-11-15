import 'dart:async';

import 'notification_inbox.dart';

import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/domain/repository/notification_repository.dart';
import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:attendance_flutter/features/notifications/presentation/view_model/state/notification_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class NotificationViewModel extends Notifier<NotificationState> {
  late INotificationRepository _repository;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Future<void> _operations = Future<void>.value();
  Future<void>? _initialization;
  Timer? _retryTimer;
  int _retryCount = 0;
  int _sessionVersion = 0;
  bool _started = false;
  bool _active = false;
  bool _permissionGranted = false;
  String? _syncedId;
  String? _latestId;

  @override
  NotificationState build() {
    _repository = ref.read(notificationRepositoryProvider);
    ref.listen(authSessionProvider, (previous, loggedIn) {
      if (!_started) return;
      if (loggedIn) {
        unawaited(activate());
      } else {
        _suspend();
      }
    });
    ref.onDispose(() {
      _active = false;
      _sessionVersion++;
      _retryTimer?.cancel();
      for (final subscription in _subscriptions) {
        unawaited(subscription.cancel());
      }
    });
    return const NotificationState();
  }

  Future<void> start() async {
    if (_started || !_repository.isSupported) return;
    if (kDebugMode) {
      debugPrint('[notifications] Starting notification listeners.');
    }
    _started = true;
    try {
      await _ensureInitialized();
      if (ref.mounted && ref.read(authSessionProvider)) await activate();
    } catch (_) {
      _reportError();
      if (ref.mounted && ref.read(authSessionProvider)) {
        _active = true;
        _scheduleRetry();
      }
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= () async {
      if (_subscriptions.isEmpty) {
        // Subscribe before register() so its first FID event cannot be lost.
        _subscriptions.addAll([
          _repository.registrations.listen(
            _onRegistration,
            onError: _onStreamError,
          ),
          _repository.foregroundMessages.listen(
            (message) => unawaited(_receiveForeground(message)),
            onError: _onStreamError,
          ),
          _repository.openedMessages.listen(handleTap, onError: _onStreamError),
        ]);
      }
      try {
        final initial = await _repository.initialize();
        if (initial != null && ref.mounted) handleTap(initial);
      } catch (_) {
        _initialization = null;
        rethrow;
      }
    }();
  }

  Future<void> _receiveForeground(AppNotification message) async {
    if (!ref.mounted ||
        !ref.read(authSessionProvider) ||
        ref.read(authViewModelProvider).isLoggingOut) {
      return;
    }
    final version = _sessionVersion;
    // Save before presentation, including messages received while Firebase
    // initialization is still finishing for an already signed-in account.
    await ref.read(notificationInboxProvider.notifier).record(message);
    if (!ref.mounted ||
        version != _sessionVersion ||
        !ref.read(authSessionProvider) ||
        ref.read(authViewModelProvider).isLoggingOut) {
      return;
    }
    state = NotificationState(
      foreground: message,
      pendingTap: state.pendingTap,
    );
  }

  Future<void> activate({bool requestPermission = true}) async {
    if (!ref.mounted ||
        !_repository.isSupported ||
        !ref.read(authSessionProvider) ||
        ref.read(authViewModelProvider).isLoggingOut) {
      return;
    }
    _started = true;
    _active = true;
    final version = _sessionVersion;
    await _enqueue(() async {
      if (!_isCurrent(version)) return;
      try {
        await _ensureInitialized();
        if (!_isCurrent(version)) return;
        final enabled = await _repository.enable(
          requestPermission: requestPermission,
        );
        if (!_isCurrent(version)) return;
        _permissionGranted = enabled;
        if (!enabled) {
          // Permission can be revoked in Settings. Remove the server mapping.
          for (final id in _repository.savedInstallationIds) {
            final result = await ref
                .read(unregisterDeviceUsecaseProvider)
                .call(id);
            if (result.isLeft()) {
              _reportError();
              _scheduleRetry();
              return;
            }
          }
          _syncedId = null;
          await _repository.disable();
          return;
        }
        // Also retry an earlier failed HTTP upload even if Firebase doesn't
        // emit another registration event during this activation.
        if (_latestId != null) await _register(_latestId!, version);
      } catch (_) {
        _reportError();
        _scheduleRetry();
      }
    });
  }

  Future<void> resume() async {
    await ref.read(notificationInboxProvider.notifier).reload();
    _retryCount = 0;
    _retryTimer?.cancel();
    await activate(requestPermission: false);
  }

  void _onRegistration(String id) {
    if (!ref.mounted || !_active || id.trim().isEmpty) return;
    if (kDebugMode) {
      debugPrint('[notifications] Firebase installation ID received.');
    }
    _latestId = id;
    final version = _sessionVersion;
    unawaited(_enqueue(() => _register(id, version)));
  }

  Future<void> _register(String id, int version) async {
    if (!_isCurrent(version) || !_permissionGranted) return;
    if (_syncedId != id) {
      final result = await ref.read(registerDeviceUsecaseProvider).call(id);
      if (!ref.mounted) return;
      if (result.isLeft()) {
        _reportError();
        _scheduleRetry();
        return;
      }
      if (!_isCurrent(version)) return;
      _syncedId = id;
    }
    // A replaced FID must not remain attached to the employee indefinitely.
    for (final oldId in _repository.savedInstallationIds.where(
      (value) => value != id,
    )) {
      if (!_isCurrent(version)) return;
      final result = await ref
          .read(unregisterDeviceUsecaseProvider)
          .call(oldId);
      if (result.isLeft()) {
        _reportError();
        _scheduleRetry();
        return;
      }
    }
    if (!_isCurrent(version)) return;
    _retryCount = 0;
    _retryTimer?.cancel();
    state = NotificationState(
      foreground: state.foreground,
      pendingTap: state.pendingTap,
    );
  }

  /// Finish every in-flight registration and detach it while JWT credentials
  /// are still available. Auth logout must run only after this succeeds.
  Future<Either<Failure, Unit>> prepareLogout() async {
    _suspend();
    Either<Failure, Unit> outcome = const Right(unit);
    await _enqueue(() async {
      for (final id in _repository.savedInstallationIds) {
        if (!ref.mounted) return;
        final result = await ref.read(unregisterDeviceUsecaseProvider).call(id);
        if (result.isLeft()) {
          outcome = const Left(
            ServerFailure(
              message: 'Unable to disconnect notifications. Please retry signing out.',
            ),
          );
          return;
        }
      }
      if (_repository.isSupported) {
        try {
          await _repository.disable();
        } catch (_) {
          // Server mappings are gone; Firebase cleanup can retry next session.
        }
      }
    });
    return outcome;
  }

  void _suspend() {
    _active = false;
    _permissionGranted = false;
    _sessionVersion++;
    _syncedId = null;
    _latestId = null;
    _retryTimer?.cancel();
    _retryCount = 0;
    if (ref.mounted) state = const NotificationState();
  }

  void handleTap(AppNotification message) {
    if (!ref.mounted) return;
    if (ref.read(authViewModelProvider).isLoggingOut) return;
    unawaited(ref.read(notificationInboxProvider.notifier).record(message));
    if (message.destination == null) return;
    state = NotificationState(
      foreground: state.foreground,
      pendingTap: message,
    );
  }

  void acknowledgeTap() {
    state = NotificationState(
      foreground: state.foreground,
      errorMessage: state.errorMessage,
    );
  }

  bool _isCurrent(int version) =>
      ref.mounted && _active && version == _sessionVersion;

  Future<void> _enqueue(Future<void> Function() action) {
    final operation = _operations.then((_) => action());
    _operations = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }

  void _onStreamError(Object error) {
    _reportError();
    _scheduleRetry();
  }

  void _reportError() {
    if (!ref.mounted || !_active) return;
    state = NotificationState(
      foreground: state.foreground,
      pendingTap: state.pendingTap,
      errorMessage:
          'Notifications could not connect. We will retry automatically.',
    );
  }

  void _scheduleRetry() {
    if (!ref.mounted || !_active || _retryCount >= 3) return;
    if (_retryTimer?.isActive ?? false) return;
    _retryCount++;
    _retryTimer = Timer(const Duration(seconds: 10), () {
      if (ref.mounted && _active) unawaited(activate(requestPermission: false));
    });
  }
}
