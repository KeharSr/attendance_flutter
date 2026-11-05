import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/repository/missing_attendance_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteMissingAttendanceParams extends Equatable {
  const DeleteMissingAttendanceParams({required this.requestId});
  final String requestId;

  @override
  List<Object?> get props => [requestId];
}

class DeleteMissingAttendanceUsecase
    implements UsecaseWithParams<bool, DeleteMissingAttendanceParams> {
  const DeleteMissingAttendanceUsecase({required this._repository});
  final IMissingAttendanceRepository _repository;

  @override
  Future<Either<Failure, bool>> call(DeleteMissingAttendanceParams params) =>
      _repository.deleteMissingAttendance(requestId: params.requestId);
}
