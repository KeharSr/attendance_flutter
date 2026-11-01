import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/data/data_source/missing_attendance_data_source.dart';
import 'package:attendance_flutter/features/missing_attendance/data/model/missing_attendance_api_model.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';

class MissingAttendanceRepositoryImpl implements IMissingAttendanceRepository {
  final MissingAttendanceDataSource _missingAttendanceDataSource;

  MissingAttendanceRepositoryImpl({required this._missingAttendanceDataSource});

  @override
  Future<Either<Failure, MissingAttendanceEntity>> createMissingAttendance({
    required String missingDate,
    required String requestedCheckIn,
    required String requestedCheckOut,
    required String reason,
  }) async {
    try {
      final response = await _missingAttendanceDataSource
          .createMissingAttendance(
            missingDate: missingDate,
            requestedCheckIn: requestedCheckIn,
            requestedCheckOut: requestedCheckOut,
            reason: reason,
          );

      return Right(response.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MissingAttendanceEntity>>>
  getMissingAttendance() async {
    try {
      final response = await _missingAttendanceDataSource
          .getMissingAttendance();

      return Right(MissingAttendanceApiModel.toEntityList(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
