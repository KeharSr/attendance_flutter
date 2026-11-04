import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  static const _notProvided = Object();

  final bool isLoading;
  final bool isFetchingToday;
  final bool hasLoadedToday;
  final String? todayErrorMessage;
  final String? errorMessage;
  final String? successMessage;
  final AttendanceEntity? attendance;

  const AttendanceState({
    required this.isLoading,
    this.isFetchingToday = false,
    this.hasLoadedToday = false,
    this.todayErrorMessage,
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
    bool? isFetchingToday,
    bool? hasLoadedToday,
    Object? todayErrorMessage = _notProvided,
    Object? errorMessage = _notProvided,
    Object? successMessage = _notProvided,
    Object? attendance = _notProvided,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingToday: isFetchingToday ?? this.isFetchingToday,
      hasLoadedToday: hasLoadedToday ?? this.hasLoadedToday,
      todayErrorMessage: identical(todayErrorMessage, _notProvided)
          ? this.todayErrorMessage
          : todayErrorMessage as String?,
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
    isFetchingToday,
    hasLoadedToday,
    todayErrorMessage,
    errorMessage,
    successMessage,
    attendance,
  ];
}
