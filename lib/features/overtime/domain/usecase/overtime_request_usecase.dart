import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class OvertimeRequestParams extends Equatable {
  final String workDate;
  final String overtimeStartTime;
  final String overtimeEndTime;
  final String reason;

  const OvertimeRequestParams({
    required this.workDate,
    required this.overtimeStartTime,
    required this.overtimeEndTime,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    workDate,
    overtimeStartTime,
    overtimeEndTime,
    reason,
  ];
}

class OvertimeRequestUsecase
    implements UsecaseWithParams<OvertimeEntity, OvertimeRequestParams> {
  final IOvertimeRepository _iOvertimeRepository;

  const OvertimeRequestUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, OvertimeEntity>> call(OvertimeRequestParams params) {
    return _iOvertimeRepository.addOvertime(
      workDate: params.workDate,
      overtimeStartTime: params.overtimeStartTime,
      overtimeEndTime: params.overtimeEndTime,
      reason: params.reason,
    );
  }
}
