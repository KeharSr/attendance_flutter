import 'package:attendance_flutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_local_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/model/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final userId = prefs.getString(SharedPrefsKeys.userIdKey);
  if (prefs.getBool(SharedPrefsKeys.isUserLoggedIn) != true ||
      userId == null ||
      userId.isEmpty) {
    return;
  }
  try {
    await NotificationLocalDataSource(preferences: prefs)
        .saveNotification(userId, NotificationModel.fromRemoteMessage(message));
  } catch (_) {
    debugPrint('[notifications] Unable to save the background notification.');
  }
}
