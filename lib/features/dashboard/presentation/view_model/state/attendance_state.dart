import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  static const _notProvided = Object();

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final AttendanceEntity? attendance;

  const AttendanceState({
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    this.attendance,
  });

  factory AttendanceState.initial() {
    return const AttendanceState(
      isLoading: false,
      errorMessage: null,
      successMessage: null,
      attendance: null,
    );
  }

  AttendanceState copyWith({
    bool? isLoading,
    Object? errorMessage = _notProvided,
    Object? successMessage = _notProvided,
    Object? attendance = _notProvided,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      attendance: identical(attendance, _notProvided)
          ? this.attendance
          : attendance as AttendanceEntity?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    attendance,
  ];
}
