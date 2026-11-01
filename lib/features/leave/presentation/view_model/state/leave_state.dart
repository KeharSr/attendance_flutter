import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:equatable/equatable.dart';

class LeaveState extends Equatable {
  static const _notProvided = Object();

  const LeaveState({
    required this.isLoading,
    required this.requests,
    this.startDate,
    this.endDate,
    this.errorMessage,
    this.successMessage,
  });

  factory LeaveState.initial() {
    return const LeaveState(isLoading: false, requests: []);
  }

  final bool isLoading;
  final List<LeaveEntity> requests;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? errorMessage;
  final String? successMessage;

  LeaveState copyWith({
    bool? isLoading,
    List<LeaveEntity>? requests,
    Object? startDate = _notProvided,
    Object? endDate = _notProvided,
    Object? errorMessage = _notProvided,
    Object? successMessage = _notProvided,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
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
    requests,
    startDate,
    endDate,
    errorMessage,
    successMessage,
  ];
}
