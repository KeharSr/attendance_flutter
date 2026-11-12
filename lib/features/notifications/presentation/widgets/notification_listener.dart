import 'dart:async';

import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:attendance_flutter/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotificationListener extends ConsumerStatefulWidget {
  const AppNotificationListener({
    super.key,
    required this.navigatorKey,
    required this.messengerKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<AppNotificationListener> createState() =>
      _NotificationListenerState();
}

class _NotificationListenerState extends ConsumerState<AppNotificationListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(notificationViewModelProvider.notifier).start());
        unawaited(
          ref
              .read(androidNotificationServiceProvider)
              .initialize(
                onTap: (type) {
                  if (mounted) {
                    ref
                        .read(notificationViewModelProvider.notifier)
                        .handleTap(AppNotification(type: type));
                  }
                },
              ),
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(notificationViewModelProvider.notifier).resume());
    }
  }

  bool get _ready =>
      ref.read(splashViewModelProvider) &&
      ref.read(authSessionProvider) &&
      !ref.read(authViewModelProvider).isLoggingOut;

  void _openNotification(AppNotification message) {
    if (!mounted || !_ready) return;
    final tab = switch (message.destination) {
      NotificationDestination.attendance => DashboardTab.home,
      NotificationDestination.leave => DashboardTab.leave,
      NotificationDestination.overtime => DashboardTab.overtime,
      NotificationDestination.missingAttendance => DashboardTab.missing,
      null => null,
    };
    if (tab == null) return;
    // A tap can target the tab already on screen, so refresh its server state.
    switch (message.destination) {
      case NotificationDestination.leave:
        unawaited(ref.read(leaveViewModelProvider.notifier).getAllLeaves());
      case NotificationDestination.overtime:
        unawaited(
          ref.read(overtimeViewModelProvider.notifier).getAllOvertimeRequest(),
        );
      case NotificationDestination.missingAttendance:
        unawaited(
          ref
              .read(missingAttendanceViewModelProvider.notifier)
              .fetchMissingAttendance(),
        );
      default:
        break;
    }
    widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(dashboardNavigationProvider.notifier).select(tab);
  }

  Future<void> _showForeground(AppNotification message) async {
    // iOS uses native remote-notification foreground presentation.
    if (!_ready ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        message.displayText.isEmpty) {
      return;
    }
    final shown = await ref
        .read(androidNotificationServiceProvider)
        .show(
          title: message.title ?? 'Attendance update',
          body: message.body ?? '',
          type: message.type,
          messageId: message.id,
        );
    if (!mounted || !_ready || shown) return;
    // Keep an in-app fallback if notifications are disabled in system settings.
    widget.messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message.displayText),
        duration: const Duration(seconds: 6),
        action: message.destination != null
            ? SnackBarAction(
                label: 'Open',
                onPressed: () => _openNotification(message),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready =
        ref.watch(splashViewModelProvider) &&
        ref.watch(authSessionProvider) &&
        !ref.watch(authViewModelProvider).isLoggingOut;
    final notification = ref.watch(notificationViewModelProvider);
    ref.listen(authViewModelProvider, (previous, next) {
      if (previous?.isLoggingOut == true &&
          !next.isLoggingOut &&
          next.logoutMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || ref.read(authSessionProvider)) return;
          unawaited(ref.read(androidNotificationServiceProvider).clear());
        });
      }
    });
    ref.listen(notificationViewModelProvider, (previous, next) {
      if (next.foreground != null &&
          !identical(previous?.foreground, next.foreground)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_showForeground(next.foreground!));
        });
      }
    });
    if (ready && notification.pendingTap != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_ready) return;
        final message = ref.read(notificationViewModelProvider).pendingTap;
        if (message == null) return;
        ref.read(notificationViewModelProvider.notifier).acknowledgeTap();
        _openNotification(message);
      });
    }
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
