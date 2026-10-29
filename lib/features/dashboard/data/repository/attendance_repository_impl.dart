import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/data/data_source/attendance_data_source.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/repository/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class AttendanceRepositoryImpl implements IAttendanceRepository {
  final AttendanceDataSource _attendanceDataSource;

  AttendanceRepositoryImpl({required this._attendanceDataSource});

  @override
  Future<Either<Failure, AttendanceEntity>> clockInEvent({
    required double latitude,
    required double longitude,
    required num accuracy,
  }) async {
    try {
      final result = await _attendanceDataSource.clockIn(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      final resultToEntity = result.toEntity();

      return Right((resultToEntity));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
