import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/api/api_exception.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/leave/data/data_source/abstract_leave_data_source.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/domain/repository/leave_repository.dart';
import 'package:dartz/dartz.dart';

class LeaveRepositoryImpl implements ILeaveRepository {
  final ILeaveDataSource _dataSource;

  const LeaveRepositoryImpl({required this._dataSource});

  @override
  Future<Either<Failure, LeaveEntity>> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final result = await _dataSource.submitLeave(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      return Right(result.toEntity());
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, RequestListEntity<LeaveEntity>>> getAllLeaves({
    required int year,
    required int month,
  }) async {
    try {
      final result = await _dataSource.getAllLeaves(year: year, month: month);
      return Right(result.toEntity((item) => item.toEntity()));
    } catch (error) {
      return Left(ServerFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaveEntity>> editLeave({
    required String leaveRequestId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final result = await _dataSource.editLeave(
        leaveRequestId: leaveRequestId,
        startDate: startDate,
        endDate: endDate,
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
  Future<Either<Failure, bool>> deleteLeave({
    required String leaveRequestId,
  }) async {
    try {
      await _dataSource.deleteLeave(leaveRequestId: leaveRequestId);
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
