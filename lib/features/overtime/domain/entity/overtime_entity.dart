import 'package:equatable/equatable.dart';

class OvertimeEntity extends Equatable {
  final String id;
  final String userId;
  final String? overtimeStartTime;
  final String? overtimeEndTime;
  final String workDate;
  final String reason;
  final String status;
  final String? rejectReason;

  const OvertimeEntity({
    required this.id,
    required this.userId,
    this.overtimeStartTime,
    this.overtimeEndTime,
    this.workDate = '',
    required this.reason,
    required this.status,
    this.rejectReason,
  });

  /// Duration of a valid same-day overtime interval returned by the API.
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
    rejectReason,
  ];
}
