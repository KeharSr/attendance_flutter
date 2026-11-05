import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class EditLeaveParams extends Equatable {
  const EditLeaveParams({
    required this.leaveRequestId,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });
  final String leaveRequestId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  @override
  List<Object?> get props => [leaveRequestId, startDate, endDate, reason];
}

class EditLeaveUsecase
    implements UsecaseWithParams<LeaveEntity, EditLeaveParams> {
  const EditLeaveUsecase({required this._repository});
  final ILeaveRepository _repository;

  @override
  Future<Either<Failure, LeaveEntity>> call(EditLeaveParams params) =>
      _repository.editLeave(
        leaveRequestId: params.leaveRequestId,
        startDate: params.startDate,
        endDate: params.endDate,
        reason: params.reason,
      );
}
