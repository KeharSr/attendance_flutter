import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:equatable/equatable.dart';

class MissingAttendanceState extends Equatable {
  static const _notProvided = Object();

  final int selectedYear;
  final int selectedMonth;
  final RequestSummaryEntity? summary;
  final bool isLoading;
  final String? successMessage;
  final String? failureMessage;
  final List<MissingAttendanceEntity> missingAttendance;

  const MissingAttendanceState({
    required this.isLoading,
    this.summary,
    required this.selectedYear,
    required this.selectedMonth,
    this.successMessage,
    this.failureMessage,
    required this.missingAttendance,
  });

  MissingAttendanceState copyWith({
    bool? isLoading,
    Object? summary = _notProvided,
    int? selectedYear,
    int? selectedMonth,
    Object? successMessage = _notProvided,
    Object? failureMessage = _notProvided,
    List<MissingAttendanceEntity>? missingAttendance,
  }) {
    return MissingAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      summary: identical(summary, _notProvided)
          ? this.summary
          : summary as RequestSummaryEntity?,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      failureMessage: identical(failureMessage, _notProvided)
          ? this.failureMessage
          : failureMessage as String?,
      missingAttendance: missingAttendance ?? this.missingAttendance,
    );
  }

  factory MissingAttendanceState.inital() {
    final now = DateTime.now();
    return MissingAttendanceState(
      isLoading: false,
      selectedYear: now.year,
      selectedMonth: now.month,
      missingAttendance: const [],
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    summary,
    selectedYear,
    selectedMonth,
    successMessage,
    failureMessage,
    missingAttendance,
  ];
}
