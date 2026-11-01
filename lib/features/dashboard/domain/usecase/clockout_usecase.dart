import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/repository/attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ClockOutParams extends Equatable {
  final double latitude;
  final double longitude;
  final num accuracy;

  const ClockOutParams({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

class ClockOutUseCase
    implements UsecaseWithParams<AttendanceEntity, ClockOutParams> {
  final IAttendanceRepository _iAttendanceRepository;

  ClockOutUseCase({required this._iAttendanceRepository});

  @override
  Future<Either<Failure, AttendanceEntity>> call(ClockOutParams params) {
    return _iAttendanceRepository.clockOutEvent(
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
    );
  }
}
