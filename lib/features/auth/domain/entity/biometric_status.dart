import 'auth_entity.dart';

class BiometricStatus {
  const BiometricStatus({required this.available, required this.enabled});
  final bool available;
  final bool enabled;
}

class BiometricLoginResult {
  const BiometricLoginResult.authenticated(AuthEntity this.user);
  const BiometricLoginResult.cancelled() : user = null;
  final AuthEntity? user;
}
