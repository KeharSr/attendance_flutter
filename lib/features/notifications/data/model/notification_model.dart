import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  static AppNotification fromRemoteMessage(RemoteMessage message) {
    return AppNotification(
      id: message.data['eventId']?.toString() ?? message.messageId,
      title: message.notification?.title ?? message.data['title']?.toString(),
      body: message.notification?.body ?? message.data['body']?.toString(),
      type: message.data['type']?.toString(),
      sentAt: (message.sentTime ?? DateTime.now()).toUtc(),
      entityId: (message.data['entityId'] ?? message.data['requestId'])
          ?.toString(),
      status: message.data['status']?.toString(),
    );
  }

  static Map<String, Object?> toJson(AppNotification message) => {
    'id': message.id,
    'title': message.title,
    'body': message.body,
    'type': message.type,
    'sentAt': message.sentAt?.toUtc().toIso8601String(),
    'entityId': message.entityId,
    'status': message.status,
  };

  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String?,
    title: json['title'] as String?,
    body: json['body'] as String?,
    type: json['type'] as String?,
    sentAt: DateTime.tryParse(json['sentAt'] as String? ?? ''),
    entityId: json['entityId'] as String?,
    status: json['status'] as String?,
  );
}
