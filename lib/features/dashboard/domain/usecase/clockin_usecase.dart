import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/repository/attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ClockInParams extends Equatable {
  final double latitude;
  final double longitude;
  final num accuracy;

  const ClockInParams({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

class ClockinUsecase
    implements UsecaseWithParams<AttendanceEntity, ClockInParams> {
  final IAttendanceRepository _iAttendanceRepository;

  ClockinUsecase({required this._iAttendanceRepository});

  @override
  Future<Either<Failure, AttendanceEntity>> call(ClockInParams params) {
    return _iAttendanceRepository.clockInEvent(
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
    );
  }
}
