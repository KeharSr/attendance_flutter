import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_local_data_source.dart';

class SecureTokenLocalDataSource implements TokenLocalDataSource {
  SecureTokenLocalDataSource({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;
  static const accessKey = 'auth_token';
  static const refreshKey = 'auth_refresh_token';
  static const biometricEnabledKey = 'biometric_enabled';
  static const biometricUserKey = 'biometric_user_id';
  static const legacyBiometricRefreshKey = 'biometric_refresh_token';

  @override
  Future<String?> getAccessToken() => _storage.read(key: accessKey);
  @override
  Future<String?> getRefreshToken() => _storage.read(key: refreshKey);

  @override
  Future<void> saveTokens({
    required String authAccessToken,
    String? refreshToken,
  }) async {
    if (refreshToken != null) {
      // Persist the rotated refresh token first so interrupted writes can recover.
      await _storage.write(key: refreshKey, value: refreshToken);
      await _storage.delete(key: legacyBiometricRefreshKey);
    }
    await _storage.write(key: accessKey, value: authAccessToken);
  }

  @override
  Future<bool> isBiometricEnabledFor(String userId) async {
    if (userId.isEmpty) return false;
    final enabled = await _storage.read(key: biometricEnabledKey);
    final owner = await _storage.read(key: biometricUserKey);
    final refresh = await getRefreshToken();
    return enabled == 'true' &&
        owner == userId &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  @override
  Future<void> enableBiometricsFor(String userId) async {
    final refresh = await getRefreshToken();
    if (userId.isEmpty || refresh == null || refresh.isEmpty) {
      throw StateError('Sign in before enabling biometric sign-in.');
    }
    await _storage.write(key: biometricUserKey, value: userId);
    await _storage.write(key: biometricEnabledKey, value: 'true');
    await _storage.delete(key: legacyBiometricRefreshKey);
  }

  @override
  Future<void> disableBiometrics() async {
    await Future.wait([
      _storage.delete(key: biometricEnabledKey),
      _storage.delete(key: biometricUserKey),
      _storage.delete(key: legacyBiometricRefreshKey),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: accessKey),
      _storage.delete(key: refreshKey),
      disableBiometrics(),
    ]);
  }
}
