import 'package:attendance_flutter/core/domain/entity/request_list_entity.dart';
import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetAllOvertimeParams extends Equatable {
  const GetAllOvertimeParams({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object?> get props => [year, month];
}

class GetAllOvertimeRequestUsecase
    implements
        UsecaseWithParams<
          RequestListEntity<OvertimeEntity>,
          GetAllOvertimeParams
        > {
  final IOvertimeRepository _iOvertimeRepository;

  const GetAllOvertimeRequestUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, RequestListEntity<OvertimeEntity>>> call(
    GetAllOvertimeParams params,
  ) {
    return _iOvertimeRepository.getAllOvertime(
      year: params.year,
      month: params.month,
    );
  }
}
