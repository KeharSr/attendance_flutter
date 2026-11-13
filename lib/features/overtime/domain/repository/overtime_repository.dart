import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IOvertimeRepository {
  Future<Either<Failure, OvertimeEntity>> addOvertime({
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  });

  Future<Either<Failure, List<OvertimeEntity>>> getAllOvertime();

  Future<Either<Failure, OvertimeEntity>> editOvertime({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  });

  Future<Either<Failure, bool>> deleteOvertime({required String overtimeId});
}
