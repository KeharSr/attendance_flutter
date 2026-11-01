import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:equatable/equatable.dart';

class OvertimeState extends Equatable {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final List<OvertimeEntity> overtime;
  final DateTime? workDate;

  const OvertimeState({
    required this.isLoading,
    required this.successMessage,
    required this.errorMessage,
    required this.overtime,
    this.workDate,
  });

  factory OvertimeState.initial() {
    return const OvertimeState(
      isLoading: false,
      successMessage: null,
      errorMessage: null,
      overtime: [],
    );
  }

  OvertimeState copyWith({
    bool? isLoading,
    Object? successMessage = _notProvided,
    Object? errorMessage = _notProvided,
    List<OvertimeEntity>? overtime,
    Object? workDate = _notProvided,
  }) {
    return OvertimeState(
      isLoading: isLoading ?? this.isLoading,
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
    successMessage,
    errorMessage,
    overtime,
    workDate,
  ];
}
