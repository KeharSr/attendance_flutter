import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> clockInEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  });

  Future<Either<Failure, AttendanceEntity>> clockOutEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  });
}
