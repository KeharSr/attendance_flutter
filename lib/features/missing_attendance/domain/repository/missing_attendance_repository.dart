import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IMissingAttendanceRepository {
  Future<Either<Failure, MissingAttendanceEntity>> createMissingAttendance({
    required String missingDate,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
  });

  Future<Either<Failure, List<MissingAttendanceEntity>>> getMissingAttendance();
}
