import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:equatable/equatable.dart';

class OvertimeState extends Equatable {
  final int selectedYear;
  final int selectedMonth;
  final RequestSummaryEntity? summary;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final List<OvertimeEntity> overtime;
  final DateTime? workDate;

  const OvertimeState({
    required this.isLoading,
    this.summary,
    required this.selectedYear,
    required this.selectedMonth,
    required this.successMessage,
    required this.errorMessage,
    required this.overtime,
    this.workDate,
  });

  factory OvertimeState.initial() {
    final now = DateTime.now();
    return OvertimeState(
      selectedYear: now.year,
      selectedMonth: now.month,
      isLoading: false,
      successMessage: null,
      errorMessage: null,
      overtime: [],
    );
  }

  OvertimeState copyWith({
    bool? isLoading,
    Object? summary = _notProvided,
    int? selectedYear,
    int? selectedMonth,
    Object? successMessage = _notProvided,
    Object? errorMessage = _notProvided,
    List<OvertimeEntity>? overtime,
    Object? workDate = _notProvided,
  }) {
    return OvertimeState(
      isLoading: isLoading ?? this.isLoading,
      summary: identical(summary, _notProvided)
          ? this.summary
          : summary as RequestSummaryEntity?,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      overtime: overtime ?? this.overtime,
      workDate: identical(workDate, _notProvided)
          ? this.workDate
          : workDate as DateTime?,
    );
  }

  static const _notProvided = Object();

  @override
  List<Object?> get props => [
    isLoading,
    summary,
    selectedYear,
    selectedMonth,
    successMessage,
    errorMessage,
    overtime,
    workDate,
  ];
}
