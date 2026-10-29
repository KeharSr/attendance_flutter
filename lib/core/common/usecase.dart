import 'package:attendance_flutter/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract interface class UsecaseWithOutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
