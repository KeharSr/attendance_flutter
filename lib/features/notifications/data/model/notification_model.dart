import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  static AppNotification fromRemoteMessage(RemoteMessage message) {
    return AppNotification(
      id: message.data['eventId']?.toString() ?? message.messageId,
      title: message.notification?.title ?? message.data['title']?.toString(),
      body: message.notification?.body ?? message.data['body']?.toString(),
      type: message.data['type']?.toString(),
    );
  }
}
