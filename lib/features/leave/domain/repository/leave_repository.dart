import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ILeaveRepository {
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });

  Future<Either<Failure, List<LeaveEntity>>> getAllLeaves();
}
