import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
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
    String? errorMessage,
    String? successMessage,
    AttendanceEntity? attendance,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
       errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      attendance: attendance ?? this.attendance,
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
