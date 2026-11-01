import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsKeys {
  SharedPrefsKeys._();
  static const String isUserLoggedIn = 'is_user_logged_in';
  static const String userPhoneKey = 'user_phone';
  static const String userNameKey = 'user_name';
  static const String userIdKey = 'user_id';
  static const String authTokenKey = 'auth_token';
}

class AppSharedPrefs {
  final SharedPreferences _sharedPreferences;

  AppSharedPrefs({required this._sharedPreferences});

  Future<void> saveUserSession({
    required String userId,
    required String name,
    required String phone,
  }) async {
    await _sharedPreferences.setBool(SharedPrefsKeys.isUserLoggedIn, true);
    await _sharedPreferences.setString(SharedPrefsKeys.userPhoneKey, phone);
    await _sharedPreferences.setString(SharedPrefsKeys.userNameKey, name);
    await _sharedPreferences.setString(SharedPrefsKeys.userIdKey, userId);
  }

  bool isUserLoggedIn() {
    return _sharedPreferences.getBool(SharedPrefsKeys.isUserLoggedIn) ?? false;
  }

  String? getUserName() {
    return _sharedPreferences.getString(SharedPrefsKeys.userNameKey);
  }

  String? getUserId() {
    return _sharedPreferences.getString(SharedPrefsKeys.userIdKey);
  }

  Future<void> saveAuthToken(String token) async {
    await _sharedPreferences.setString(SharedPrefsKeys.authTokenKey, token);
  }

  String? getAuthToken() {
    return _sharedPreferences.getString(SharedPrefsKeys.authTokenKey);
  }

  Future<void> removeSession() async {
    await _sharedPreferences.remove(SharedPrefsKeys.isUserLoggedIn);
    await _sharedPreferences.remove(SharedPrefsKeys.userPhoneKey);
    await _sharedPreferences.remove(SharedPrefsKeys.userNameKey);
    await _sharedPreferences.remove(SharedPrefsKeys.userIdKey);
    await _sharedPreferences.remove(SharedPrefsKeys.authTokenKey);
  }
}
