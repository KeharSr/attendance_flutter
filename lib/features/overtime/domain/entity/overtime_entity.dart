import 'package:equatable/equatable.dart';

class OvertimeEntity extends Equatable {
  final String id;
  final String userId;
  final String? overtimeStartTime;
  final String? overtimeEndTime;
  final String workDate;
  final String reason;
  final String status;
  final String? overtimeApproveStartTime;
  final String? overtimeApproveEndTime;
  final double? overtimeRequestedHours;
  final double? overtimeAcceptedHours;
  final String? adminComment;
  final String? createdAt;
  final String? updatedAt;

  const OvertimeEntity({
    required this.id,
    required this.userId,
    this.overtimeStartTime,
    this.overtimeEndTime,
    this.workDate = '',
    required this.reason,
    required this.status,
    this.overtimeApproveStartTime,
    this.overtimeApproveEndTime,
    this.overtimeRequestedHours,
    this.overtimeAcceptedHours,
    this.adminComment,
    this.createdAt,
    this.updatedAt,
  });

  /// Requested hours from the API, falling back to the same-day time interval.
  Duration? get duration {
    int? secondsOfDay(String? value) {
      final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$')
          .firstMatch(value?.trim() ?? '');
      if (match == null) return null;
      final hour = int.parse(match[1]!);
      final minute = int.parse(match[2]!);
      final second = int.parse(match[3] ?? '0');
      if (hour > 23 || minute > 59 || second > 59) return null;
      return hour * 3600 + minute * 60 + second;
    }

    if (overtimeRequestedHours != null &&
        overtimeRequestedHours! >= 0 &&
        overtimeRequestedHours!.isFinite) {
      return Duration(
        microseconds: (overtimeRequestedHours! * Duration.microsecondsPerHour)
            .round(),
      );
    }
    final start = secondsOfDay(overtimeStartTime);
    final end = secondsOfDay(overtimeEndTime);
    if (start == null || end == null || end <= start) return null;
    return Duration(seconds: end - start);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    overtimeStartTime,
    overtimeEndTime,
    workDate,
    reason,
    status,
    overtimeApproveStartTime,
    overtimeApproveEndTime,
    overtimeRequestedHours,
    overtimeAcceptedHours,
    adminComment,
    createdAt,
    updatedAt,
  ];
}
