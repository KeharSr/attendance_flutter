import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/repository/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class TodayAttendanceUsecase
    implements UsecaseWithOutParams<AttendanceEntity?> {
  final IAttendanceRepository _iAttendanceRepository;

  TodayAttendanceUsecase({required this._iAttendanceRepository});

  @override
  Future<Either<Failure, AttendanceEntity?>> call() {
    return _iAttendanceRepository.getTodayAttendance();
  }
}
