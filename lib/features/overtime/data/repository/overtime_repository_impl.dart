import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/data/data_source/overtime_data_source.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';

class OvertimeRepositoryImpl implements IOvertimeRepository {
  final OvertimeDataSource _overtimeDataSource;

  OvertimeRepositoryImpl({required this._overtimeDataSource});
  @override
  Future<Either<Failure, OvertimeEntity>> addOvertime({
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    try {
      final result = await _overtimeDataSource.addOvertime(
        workDate: workDate,
        overtimeStartTime: overtimeStartTime,
        overtimeEndTime: overtimeEndTime,
        reason: reason,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RequestListEntity<OvertimeEntity>>> getAllOvertime({
    required int year,
    required int month,
  }) async {
    try {
      final result = await _overtimeDataSource.getAllOvertime(
        year: year,
        month: month,
      );

      return Right(result.toEntity((item) => item.toEntity()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OvertimeEntity>> editOvertime({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    try {
      final result = await _overtimeDataSource.editOvertime(
        overtimeId: overtimeId,
        workDate: workDate,
        overtimeStartTime: overtimeStartTime,
        overtimeEndTime: overtimeEndTime,
        reason: reason,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteOvertime({
    required String overtimeId,
  }) async {
    try {
      await _overtimeDataSource.deleteOvertimeRequest(overtimeId: overtimeId);
      return Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
