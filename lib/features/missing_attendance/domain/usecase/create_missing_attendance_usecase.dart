import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class MissingAttendanceParams extends Equatable {
  final String missingDate;
  final String requestedCheckIn;
  final String requestedCheckOut;
  final String reason;

  const MissingAttendanceParams({
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestedCheckOut,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    missingDate,
    requestedCheckIn,
    requestedCheckOut,
    reason,
  ];
}

class CreateMissingAttendanceUsecase
    implements
        UsecaseWithParams<MissingAttendanceEntity, MissingAttendanceParams> {
  final IMissingAttendanceRepository _iMissingAttendanceRepository;

  CreateMissingAttendanceUsecase({required this._iMissingAttendanceRepository});

  @override
  Future<Either<Failure, MissingAttendanceEntity>> call(
    MissingAttendanceParams params,
  ) async {
    return await _iMissingAttendanceRepository.createMissingAttendance(
      missingDate: params.missingDate,
      requestedCheckIn: params.requestedCheckIn,
      requestedCheckOut: params.requestedCheckOut,
      reason: params.reason,
    );
  }
}
