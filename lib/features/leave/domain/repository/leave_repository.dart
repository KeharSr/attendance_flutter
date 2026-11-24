import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ILeaveRepository {
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<Either<Failure, RequestListEntity<LeaveEntity>>> getAllLeaves({
    required int year,
    required int month,
  });
  Future<Either<Failure, LeaveEntity>> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<Either<Failure, bool>> deleteLeave({required String leaveRequestId});
}
