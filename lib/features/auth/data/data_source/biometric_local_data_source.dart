import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

abstract class BiometricLocalDataSource {
  Future<bool> isAvailable();
  Future<bool> authenticate({required String reason});
}

class DeviceBiometricLocalDataSource implements BiometricLocalDataSource {
  DeviceBiometricLocalDataSource({required this._authentication});
  final LocalAuthentication _authentication;

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return false;
    }
    try {
      if (!await _authentication.canCheckBiometrics) return false;
      return (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.userCanceled ||
          error.code == LocalAuthExceptionCode.systemCanceled ||
          error.code == LocalAuthExceptionCode.userRequestedFallback) {
        return false;
      }
      final locked =
          error.code == LocalAuthExceptionCode.temporaryLockout ||
          error.code == LocalAuthExceptionCode.biometricLockout;
      throw BiometricDeviceException(
        locked
            ? 'Biometrics are locked. Unlock your device or use your password.'
            : 'Biometrics are unavailable. Try again or use your password.',
      );
    }
  }
}

class BiometricDeviceException implements Exception {
  const BiometricDeviceException(this.message);
  final String message;
}
