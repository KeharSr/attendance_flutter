import 'package:shared_preferences/shared_preferences.dart';

class NotificationLocalDataSource {
  const NotificationLocalDataSource({required this.preferences});

  final SharedPreferences preferences;
  static const _installationIdsKey = 'notification_installation_ids';
  static const _permissionRequestedKey = 'notification_permission_requested';

  List<String> get installationIds => List.of(
    preferences.getStringList(_installationIdsKey) ?? const <String>[],
  );

  bool get permissionRequested =>
      preferences.getBool(_permissionRequestedKey) ?? false;

  Future<void> markPermissionRequested() async {
    if (!await preferences.setBool(_permissionRequestedKey, true)) {
      throw StateError('Unable to save notification permission preference.');
    }
  }

  Future<void> remember(String id) async {
    final ids = {...installationIds, id}.toList();
    if (!await preferences.setStringList(_installationIdsKey, ids)) {
      throw StateError('Unable to save notification installation.');
    }
  }

  Future<void> forget(String id) async {
    final ids = installationIds..remove(id);
    if (!await preferences.setStringList(_installationIdsKey, ids)) {
      throw StateError('Unable to remove notification installation.');
    }
  }
}
