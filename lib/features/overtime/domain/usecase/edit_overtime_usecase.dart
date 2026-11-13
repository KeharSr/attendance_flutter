import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class EditOvertimeRequestParams extends Equatable {
  final String workDate;
  final String overtimeStartTime;
  final String overtimeEndTime;
  final String reason;
  final String overtimeId;

  const EditOvertimeRequestParams({
    required this.workDate,
    required this.overtimeStartTime,
    required this.overtimeEndTime,
    required this.reason,
    required this.overtimeId,
  });

  @override
  List<Object?> get props => [
    workDate,
    overtimeStartTime,
    overtimeEndTime,
    reason,
    overtimeId,
  ];
}

class EditOvertimeUsecase
    implements UsecaseWithParams<OvertimeEntity, EditOvertimeRequestParams> {
  final IOvertimeRepository _iOvertimeRepository;

  const EditOvertimeUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, OvertimeEntity>> call(
    EditOvertimeRequestParams params,
  ) {
    return _iOvertimeRepository.editOvertime(
      overtimeId: params.overtimeId,
      workDate: params.workDate,
      overtimeStartTime: params.overtimeStartTime,
      overtimeEndTime: params.overtimeEndTime,
      reason: params.reason,
    );
  }
}
