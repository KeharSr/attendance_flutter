import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/domain/entity/biometric_status.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetBiometricStatusUsecase {
  const GetBiometricStatusUsecase(this.repository);
  final IAuthRepository repository;
  Future<Either<Failure, BiometricStatus>> call() =>
      repository.getBiometricStatus();
}

class EnableBiometricLoginUsecase {
  const EnableBiometricLoginUsecase(this.repository);
  final IAuthRepository repository;
  Future<Either<Failure, bool>> call() => repository.enableBiometricLogin();
}

class LoginWithBiometricsUsecase {
  const LoginWithBiometricsUsecase(this.repository);
  final IAuthRepository repository;
  Future<Either<Failure, BiometricLoginResult>> call() =>
      repository.loginWithBiometrics();
}

/// Turning biometrics off revokes the backend session and clears all credentials.
/// On failure the enrollment stays enabled so the UI reflects the actual session.
class DisableBiometricAndLogoutUsecase {
  const DisableBiometricAndLogoutUsecase(this.repository);
  final IAuthRepository repository;
  Future<Either<Failure, String>> call() => repository.logoutUser();
}

/// Token cleanup already ran in the HTTP interceptor before this is called.
class ClearExpiredSessionUsecase {
  const ClearExpiredSessionUsecase(this.repository);
  final IAuthRepository repository;
  Future<Either<Failure, Unit>> call() => repository.clearExpiredSession();
}
