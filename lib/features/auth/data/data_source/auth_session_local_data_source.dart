import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';

abstract class AuthSessionLocalDataSource {
  AuthEntity? getSavedUser();
  Future<void> saveUser(AuthEntity user);
  Future<void> clear();
}

class SavedAuthSessionLocalDataSource implements AuthSessionLocalDataSource {
  SavedAuthSessionLocalDataSource({required this._preferences});
  final AppSharedPrefs _preferences;
  @override
  AuthEntity? getSavedUser() {
    final id = _preferences.getUserId();
    final name = _preferences.getUserName();
    final phone = _preferences.getUserPhone();
    if (!_preferences.isUserLoggedIn() ||
        id == null ||
        id.isEmpty ||
        name == null ||
        phone == null) {
      return null;
    }
    return AuthEntity(
      id: id,
      name: name,
      phone: phone,
      password: '',
      role: null,
    );
  }

  @override
  Future<void> saveUser(AuthEntity user) => _preferences.saveUserSession(
    userId: user.id ?? '',
    name: user.name,
    phone: user.phone,
  );
  @override
  Future<void> clear() => _preferences.removeSession();
}
