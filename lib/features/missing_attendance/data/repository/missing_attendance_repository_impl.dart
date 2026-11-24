import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/api/api_exception.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/data/data_source/abstract_miss_attendance_data_source.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';

class MissingAttendanceRepositoryImpl implements IMissingAttendanceRepository {
  final IMissingAttendanceDataSource _missingAttendanceDataSource;

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
  Future<Either<Failure, RequestListEntity<MissingAttendanceEntity>>>
  getMissingAttendance({required int year, required int month}) async {
    try {
      final response = await _missingAttendanceDataSource.getMissingAttendance(
        year: year,
        month: month,
      );

      return Right(response.toEntity((item) => item.toEntity()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MissingAttendanceEntity>> editMissingAttendance({
    required String requestId,
    required String missingDate,
    required String? requestedCheckIn,
    required String? requestedCheckOut,
    required String reason,
  }) async {
    try {
      final result = await _missingAttendanceDataSource.editMissingAttendance(
        requestId: requestId,
        missingDate: missingDate,
        requestedCheckIn: requestedCheckIn,
        requestedCheckOut: requestedCheckOut,
        reason: reason,
      );
      return Right(result.toEntity());
    } on ApiException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Unable to update the request. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMissingAttendance({
    required String requestId,
  }) async {
    try {
      await _missingAttendanceDataSource.deleteMissingAttendance(
        requestId: requestId,
      );
      return const Right(true);
    } on ApiException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Unable to delete the request. Please try again.',
        ),
      );
    }
  }
}
