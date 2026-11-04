import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/repository/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class StubAttendanceRepository implements IAttendanceRepository {
  Either<Failure, AttendanceEntity?> result = const Right(null);
  Future<Either<Failure, AttendanceEntity?>> Function()? onFetch;
  int fetches = 0;

  @override
  Future<Either<Failure, AttendanceEntity?>> getTodayAttendance() async {
    fetches++;
    return onFetch == null ? result : await onFetch!();
  }

  @override
  Future<Either<Failure, AttendanceEntity>> clockInEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, AttendanceEntity>> clockOutEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) => throw UnimplementedError();
}
