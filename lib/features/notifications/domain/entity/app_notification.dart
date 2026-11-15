enum NotificationDestination { attendance, leave, overtime, missingAttendance }

/// Notification content independent of Firebase and the UI framework.
class AppNotification {
  const AppNotification({
    this.id,
    this.title,
    this.body,
    this.type,
    this.sentAt,
    this.entityId,
    this.status,
  });

  final String? id;
  final String? title;
  final String? body;
  final String? type;
  final DateTime? sentAt;
  final String? entityId;
  final String? status;

  bool get isAttendanceReminder => type == 'clock_in' || type == 'clock_out';

  NotificationDestination? get destination => switch (type) {
    'login_success' ||
    'clock_in' ||
    'clock_out' => NotificationDestination.attendance,
    'leave_approved' || 'leave_rejected' => NotificationDestination.leave,
    'overtime_approved' ||
    'overtime_rejected' => NotificationDestination.overtime,
    'missing_attendance_approved' ||
    'missing_attendance_rejected' => NotificationDestination.missingAttendance,
    _ => null,
  };

  String get displayText => [
    title,
    body,
  ].whereType<String>().where((text) => text.trim().isNotEmpty).join('\n');
}
