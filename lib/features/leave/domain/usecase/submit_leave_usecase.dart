import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SubmitLeaveParams extends Equatable {
  const SubmitLeaveParams({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  @override
  List<Object?> get props => [startDate, endDate, reason];
}

class SubmitLeaveUseCase
    implements UsecaseWithParams<LeaveEntity, SubmitLeaveParams> {
  final ILeaveRepository _iLeaveRepository;

  const SubmitLeaveUseCase({required this._iLeaveRepository});

  @override
  Future<Either<Failure, LeaveEntity>> call(SubmitLeaveParams params) {
    return _iLeaveRepository.submitLeave(
      startDate: params.startDate,
      endDate: params.endDate,
      reason: params.reason,
    );
  }
}
