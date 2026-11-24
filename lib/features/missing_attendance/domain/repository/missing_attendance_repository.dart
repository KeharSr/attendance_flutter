import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
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

  Future<Either<Failure, RequestListEntity<MissingAttendanceEntity>>>
  getMissingAttendance({required int year, required int month});
  Future<Either<Failure, MissingAttendanceEntity>> editMissingAttendance({
    required String requestId,
    required String missingDate,
    required String? requestedCheckIn,
    required String? requestedCheckOut,
    required String reason,
  });

  Future<Either<Failure, bool>> deleteMissingAttendance({
    required String requestId,
  });
}
