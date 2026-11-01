import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllOvertimeRequestUsecase
    implements UsecaseWithOutParamsList<OvertimeEntity> {
  final IOvertimeRepository _iOvertimeRepository;

  const GetAllOvertimeRequestUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, List<OvertimeEntity>>> call() {
    return _iOvertimeRepository.getAllOvertime();
  }
}
