/// Shared token persistence contract for authenticated HTTP and auth repositories.
abstract class TokenLocalDataSource {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String authAccessToken,
    String? refreshToken,
  });
  Future<bool> isBiometricEnabledFor(String userId);
  Future<void> enableBiometricsFor(String userId);
  Future<void> disableBiometrics();
  Future<void> clearTokens();
}
