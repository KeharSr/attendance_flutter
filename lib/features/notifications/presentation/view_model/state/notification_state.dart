import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';

class NotificationState {
  const NotificationState({
    this.foreground,
    this.pendingTap,
    this.errorMessage,
  });

  final AppNotification? foreground;
  final AppNotification? pendingTap;
  final String? errorMessage;
}
