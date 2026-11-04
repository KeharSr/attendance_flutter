import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/overtime/domain/repository/overtime_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class DeleteOvertimeParams extends Equatable {
  final String overtimeId;

  const DeleteOvertimeParams({required this.overtimeId});

  @override
  List<Object?> get props => [overtimeId];
}

class DeleteOvertimeUsecase
    implements UsecaseWithParams<bool, DeleteOvertimeParams> {
  final IOvertimeRepository _iOvertimeRepository;

  const DeleteOvertimeUsecase({required this._iOvertimeRepository});

  @override
  Future<Either<Failure, bool>> call(DeleteOvertimeParams params) {
    return _iOvertimeRepository.deleteOvertime(overtimeId: params.overtimeId);
  }
}
