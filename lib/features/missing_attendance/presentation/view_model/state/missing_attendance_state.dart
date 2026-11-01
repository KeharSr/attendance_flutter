import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:equatable/equatable.dart';

class MissingAttendanceState extends Equatable {
  static const _notProvided = Object();

  final bool isLoading;
  final String? successMessage;
  final String? failureMessage;
  final List<MissingAttendanceEntity> missingAttendance;

  const MissingAttendanceState({
    required this.isLoading,
    this.successMessage,
    this.failureMessage,
    required this.missingAttendance,
  });

  MissingAttendanceState copyWith({
    bool? isLoading,
    Object? successMessage = _notProvided,
    Object? failureMessage = _notProvided,
    List<MissingAttendanceEntity>? missingAttendance,
  }) {
    return MissingAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      failureMessage: identical(failureMessage, _notProvided)
          ? this.failureMessage
          : failureMessage as String?,
      missingAttendance: missingAttendance ?? this.missingAttendance,
    );
  }

  const MissingAttendanceState.inital()
    : isLoading = false,
      successMessage = null,
      failureMessage = null,
      missingAttendance = const [];

  @override
  List<Object?> get props => [
    isLoading,
    successMessage,
    failureMessage,
    missingAttendance,
  ];
}
