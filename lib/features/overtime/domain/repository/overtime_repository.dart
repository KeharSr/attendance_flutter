import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IOvertimeRepository {
  Future<Either<Failure, OvertimeEntity>> addOvertime({
    required String workDate,
    required double overtimeHours,
    required String reason,
  });
  Future<Either<Failure, List<OvertimeEntity>>> getAllOvertime();
}
