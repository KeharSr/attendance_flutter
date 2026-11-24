import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllLeaveParams extends Equatable {
  const GetAllLeaveParams({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object?> get props => [year, month];
}

class GetAllLeaveUsecase
    implements
        UsecaseWithParams<RequestListEntity<LeaveEntity>, GetAllLeaveParams> {
  final ILeaveRepository _iLeaveRepository;
  const GetAllLeaveUsecase({required this._iLeaveRepository});

  @override
  Future<Either<Failure, RequestListEntity<LeaveEntity>>> call(
    GetAllLeaveParams params,
  ) {
    return _iLeaveRepository.getAllLeaves(
      year: params.year,
      month: params.month,
    );
  }
}
