import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/data/data_source/overtime_data_source.dart';
import 'package:attendance_flutter/features/overtime/data/model/overtime_api_model.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';

class OvertimeRepositoryImpl implements IOvertimeRepository {
  final OvertimeDataSource _overtimeDataSource;

  OvertimeRepositoryImpl({required this._overtimeDataSource});
  @override
  Future<Either<Failure, OvertimeEntity>> addOvertime({
    required String workDate,
    required double overtimeHours,
    required String reason,
  }) async {
    try {
      final result = await _overtimeDataSource.addOvertime(
        workDate: workDate,
        overtimeHours: overtimeHours,
        reason: reason,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OvertimeEntity>>> getAllOvertime() async {
    try {
      final result = await _overtimeDataSource.getAllOvertime();

      return Right(OvertimeApiModel.toEntityList(result));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
