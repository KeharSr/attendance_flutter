import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllLeaveUsecase implements UsecaseWithOutParamsList<LeaveEntity> {
  final ILeaveRepository _iLeaveRepository;
  const GetAllLeaveUsecase({required this._iLeaveRepository});

  @override
  Future<Either<Failure, List<LeaveEntity>>> call() {
    return _iLeaveRepository.getAllLeaves();
  }
}
