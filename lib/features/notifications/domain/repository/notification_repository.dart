import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:dartz/dartz.dart';

abstract interface class INotificationRepository {
  bool get isSupported;
  Stream<String> get registrations;
  Stream<AppNotification> get foregroundMessages;
  Stream<AppNotification> get openedMessages;

  Future<AppNotification?> initialize();
  Future<bool> enable({required bool requestPermission});
  Future<void> disable();

  /// Includes attempted registrations, so a lost HTTP response cannot leave
  /// an installation associated with a user after logout.
  List<String> get savedInstallationIds;
  Future<Either<Failure, Unit>> registerDevice(String installationId);
  Future<Either<Failure, Unit>> unregisterDevice(String installationId);
}
