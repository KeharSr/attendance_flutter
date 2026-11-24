import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:equatable/equatable.dart';

class LeaveState extends Equatable {
  static const _notProvided = Object();

  const LeaveState({
    required this.isLoading,
    this.summary,
    required this.requests,
    required this.selectedYear,
    required this.selectedMonth,
    this.startDate,
    this.endDate,
    this.errorMessage,
    this.successMessage,
  });

  factory LeaveState.initial() {
    final now = DateTime.now();
    return LeaveState(
      isLoading: false,
      requests: const [],
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  final RequestSummaryEntity? summary;
  final bool isLoading;
  final List<LeaveEntity> requests;
  final int selectedYear;
  final int selectedMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? errorMessage;
  final String? successMessage;

  LeaveState copyWith({
    bool? isLoading,
    Object? summary = _notProvided,
    List<LeaveEntity>? requests,
    int? selectedYear,
    int? selectedMonth,
    Object? startDate = _notProvided,
    Object? endDate = _notProvided,
    Object? errorMessage = _notProvided,
    Object? successMessage = _notProvided,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      summary: identical(summary, _notProvided)
          ? this.summary
          : summary as RequestSummaryEntity?,
      requests: requests ?? this.requests,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      startDate: identical(startDate, _notProvided)
          ? this.startDate
          : startDate as DateTime?,
      endDate: identical(endDate, _notProvided)
          ? this.endDate
          : endDate as DateTime?,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    summary,
    requests,
    selectedYear,
    selectedMonth,
    startDate,
    endDate,
    errorMessage,
    successMessage,
  ];
}
