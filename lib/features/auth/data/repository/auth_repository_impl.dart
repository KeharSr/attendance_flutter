import 'package:attendance_flutter/core/service/token_storage/token_local_data_source.dart';

import '../data_source/biometric_local_data_source.dart';
import '../data_source/auth_session_local_data_source.dart';
import '../../domain/entity/biometric_status.dart';

import 'package:dio/dio.dart';
import 'package:attendance_flutter/core/api/api_exception.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/auth/data/data_source/abstract_auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/model/auth_api_model.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource _authDataSource;

  const AuthRepositoryImpl({
    required this._authDataSource,
    required this._biometrics,
    required this._tokenStore,
    required this._session,
  });

  final BiometricLocalDataSource _biometrics;
  final TokenLocalDataSource _tokenStore;
  final AuthSessionLocalDataSource _session;

  @override
  Future<Either<Failure, AuthEntity>> createUser(AuthEntity user) async {
    try {
      final model = AuthApiModel.fromEntity(user);

      final result = await _authDataSource.createUser(model);

      return Right(result.data.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _authDataSource.loginUser(
        phone: phone,
        password: password,
      );
      final user = result.toEntity();
      // A password login to a different account must never inherit enrollment.
      if (!await _tokenStore.isBiometricEnabledFor(user.id ?? '')) {
        await _tokenStore.disableBiometrics();
      }
      await _session.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left((ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, String>> logoutUser() async {
    try {
      final message = await _authDataSource.logoutUser();
      await _authDataSource.clearSavedSession();
      await _session.clear();
      return Right(message);
    } on ApiException catch (error) {
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Unable to sign out. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, BiometricStatus>> getBiometricStatus() async {
    try {
      final userId = _session.getSavedUser()?.id;
      final available = await _biometrics.isAvailable();
      final enabled =
          userId != null && await _tokenStore.isBiometricEnabledFor(userId);
      return Right(BiometricStatus(available: available, enabled: enabled));
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Unable to read biometric settings.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> enableBiometricLogin() async {
    try {
      final userId = _session.getSavedUser()?.id;
      final refresh = await _tokenStore.getRefreshToken();
      if (userId == null ||
          userId.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        return const Left(
          ServerFailure(message: 'Sign in before enabling biometric sign-in.'),
        );
      }
      if (!await _biometrics.isAvailable()) {
        return const Left(
          ServerFailure(
            message:
                'Set up fingerprint or Face ID in your device settings first.',
          ),
        );
      }
      if (!await _biometrics.authenticate(
        reason: 'Verify your identity to enable biometric sign-in.',
      )) {
        return const Right(false);
      }
      if (_session.getSavedUser()?.id != userId) {
        return const Left(
          ServerFailure(message: 'Your account changed. Please sign in again.'),
        );
      }
      await _tokenStore.enableBiometricsFor(userId);
      return const Right(true);
    } on BiometricDeviceException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Unable to enable biometric sign-in. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, BiometricLoginResult>> loginWithBiometrics() async {
    try {
      final user = _session.getSavedUser();
      final userId = user?.id;
      if (user == null ||
          userId == null ||
          !await _tokenStore.isBiometricEnabledFor(userId)) {
        return const Left(
          ServerFailure(
            message: 'Sign in with your password and enable biometric sign-in in Profile.',
          ),
        );
      }
      if (!await _biometrics.isAvailable()) {
        return const Left(
          ServerFailure(
            message:
                'Biometrics are unavailable. Use your password to sign in.',
          ),
        );
      }
      if (!await _biometrics.authenticate(
        reason: 'Verify your identity to sign in to GBN Store.',
      )) {
        return const Right(BiometricLoginResult.cancelled());
      }
      // Recheck enrollment after the OS prompt, in case the session was cleared.
      if (_session.getSavedUser()?.id != userId ||
          !await _tokenStore.isBiometricEnabledFor(userId)) {
        return const Left(
          ServerFailure(message: 'Your session changed. Please sign in again.'),
        );
      }
      if (!await _authDataSource.restoreSavedSession()) {
        return const Left(
          ServerFailure(
            message: 'Your session expired. Sign in with your password.',
            statusCode: 401,
          ),
        );
      }
      return Right(BiometricLoginResult.authenticated(user));
    } on BiometricDeviceException catch (error) {
      return Left(ServerFailure(message: error.message));
    } on DioException catch (error) {
      // Preserve enrollment and tokens on transient errors and server outages.
      return Left(
        ServerFailure(
          message: 'Unable to verify your session. Check your connection and try again.',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Unable to sign in with biometrics. Try again or use your password.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> clearExpiredSession() async {
    try {
      await _session.clear();
      return const Right(unit);
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Unable to clear the saved profile.'),
      );
    }
  }
}
