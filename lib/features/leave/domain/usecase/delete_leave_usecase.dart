import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteLeaveParams extends Equatable {
  const DeleteLeaveParams({required this.leaveRequestId});
  final String leaveRequestId;

  @override
  List<Object?> get props => [leaveRequestId];
}

class DeleteLeaveUsecase implements UsecaseWithParams<bool, DeleteLeaveParams> {
  const DeleteLeaveUsecase({required this._repository});
  final ILeaveRepository _repository;

  @override
  Future<Either<Failure, bool>> call(DeleteLeaveParams params) =>
      _repository.deleteLeave(leaveRequestId: params.leaveRequestId);
}
