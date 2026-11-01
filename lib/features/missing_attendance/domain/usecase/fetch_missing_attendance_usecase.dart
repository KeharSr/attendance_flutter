import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';

class FetchMissingAttendanceUsecase
    implements UsecaseWithOutParamsList<MissingAttendanceEntity> {
  final IMissingAttendanceRepository _iMissingAttendanceRepository;

  FetchMissingAttendanceUsecase({required this._iMissingAttendanceRepository});

  @override
  Future<Either<Failure, List<MissingAttendanceEntity>>> call() async {
    return await _iMissingAttendanceRepository.getMissingAttendance();
  }
}
