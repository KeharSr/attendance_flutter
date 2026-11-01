import 'package:attendance_flutter/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract interface class UsecaseWithOutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class UsecaseWithOutParamsList<SuccessType> {
  Future<Either<Failure, List<SuccessType>>> call();
}
