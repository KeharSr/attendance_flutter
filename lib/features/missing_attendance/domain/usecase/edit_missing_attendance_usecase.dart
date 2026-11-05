import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class EditMissingAttendanceParams extends Equatable {
  const EditMissingAttendanceParams({
    required this.requestId,
    required this.missingDate,
    required this.requestedCheckIn,
    required this.requestedCheckOut,
    required this.reason,
  });
  final String requestId;
  final String missingDate;
  final String? requestedCheckIn;
  final String? requestedCheckOut;
  final String reason;

  @override
  List<Object?> get props => [
    requestId,
    missingDate,
    requestedCheckIn,
    requestedCheckOut,
    reason,
  ];
}

class EditMissingAttendanceUsecase
    implements
        UsecaseWithParams<
          MissingAttendanceEntity,
          EditMissingAttendanceParams
        > {
  const EditMissingAttendanceUsecase({required this._repository});
  final IMissingAttendanceRepository _repository;

  @override
  Future<Either<Failure, MissingAttendanceEntity>> call(
    EditMissingAttendanceParams params,
  ) => _repository.editMissingAttendance(
    requestId: params.requestId,
    missingDate: params.missingDate,
    requestedCheckIn: params.requestedCheckIn,
    requestedCheckOut: params.requestedCheckOut,
    reason: params.reason,
  );
}
