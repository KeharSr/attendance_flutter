import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class FetchMissingAttendanceParams extends Equatable {
  const FetchMissingAttendanceParams({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object?> get props => [year, month];
}

class FetchMissingAttendanceUsecase
    implements
        UsecaseWithParams<
          RequestListEntity<MissingAttendanceEntity>,
          FetchMissingAttendanceParams
        > {
  final IMissingAttendanceRepository _iMissingAttendanceRepository;

  FetchMissingAttendanceUsecase({required this._iMissingAttendanceRepository});

  @override
  Future<Either<Failure, RequestListEntity<MissingAttendanceEntity>>> call(
    FetchMissingAttendanceParams params,
  ) async {
    return await _iMissingAttendanceRepository.getMissingAttendance(
      year: params.year,
      month: params.month,
    );
  }
}
