import '../entity/biometric_status.dart';

import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthEntity>> createUser(AuthEntity user);
  Future<Either<Failure, AuthEntity>> loginUser({
    required String phone,
    required String password,
  });
  Future<Either<Failure, String>> logoutUser();
  Future<Either<Failure, Unit>> clearExpiredSession();
  Future<Either<Failure, BiometricStatus>> getBiometricStatus();
  Future<Either<Failure, bool>> enableBiometricLogin();
  Future<Either<Failure, BiometricLoginResult>> loginWithBiometrics();
}
