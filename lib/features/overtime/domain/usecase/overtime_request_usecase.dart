import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class OvertimeRequestParams extends Equatable {
  final String workDate;
  final double overtimeHours;
  final String reason;

  const OvertimeRequestParams({
    required this.workDate,
    required this.overtimeHours,
    required this.reason,
  });

  @override
  List<Object?> get props => [workDate, overtimeHours, reason];
}

class OvertimeRequestUsecase
    implements UsecaseWithParams<OvertimeEntity, OvertimeRequestParams> {
  final IOvertimeRepository _iOvertimeRepository;

  const OvertimeRequestUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, OvertimeEntity>> call(OvertimeRequestParams params) {
    return _iOvertimeRepository.addOvertime(
      workDate: params.workDate,
      overtimeHours: params.overtimeHours,
      reason: params.reason,
    );
  }
}
