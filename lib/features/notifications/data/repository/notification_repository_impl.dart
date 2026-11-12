import 'package:attendance_flutter/core/api/api_exception.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/core/service/notifications/firebase_messaging_service.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_local_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_remote_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/model/notification_model.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/domain/repository/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  const NotificationRepositoryImpl({
    required this.messaging,
    required this.remote,
    required this.local,
  });

  final FirebaseMessagingService messaging;
  final NotificationRemoteDataSource remote;
  final NotificationLocalDataSource local;

  @override
  bool get isSupported => messaging.isSupported;
  @override
  Stream<String> get registrations => messaging.registrations;
  @override
  Stream<AppNotification> get foregroundMessages =>
      messaging.foregroundMessages.map(NotificationModel.fromRemoteMessage);
  @override
  Stream<AppNotification> get openedMessages =>
      messaging.openedMessages.map(NotificationModel.fromRemoteMessage);
  @override
  List<String> get savedInstallationIds => local.installationIds;

  @override
  Future<AppNotification?> initialize() async {
    final message = await messaging.initialize();
    return message == null
        ? null
        : NotificationModel.fromRemoteMessage(message);
  }

  @override
  Future<bool> enable({required bool requestPermission}) async {
    final shouldAsk = requestPermission && !local.permissionRequested;
    final allowed = await messaging.permissionGranted(
      requestPermission: shouldAsk,
    );
    // A platform error before the prompt completes must not permanently
    // suppress the permission request on the next login.
    if (shouldAsk) await local.markPermissionRequested();
    if (!allowed) return false;
    await messaging.register();
    return true;
  }

  @override
  Future<void> disable() => messaging.unregister();

  @override
  Future<Either<Failure, Unit>> registerDevice(
    String installationId,
  ) => _execute(() async {
    // Persist before HTTP: a timed-out response may still have saved the ID.
    await local.remember(installationId);
    await remote.registerDevice(installationId);
    if (kDebugMode) {
      debugPrint('[notifications] Installation registered with backend.');
    }
  });

  @override
  Future<Either<Failure, Unit>> unregisterDevice(String installationId) =>
      _execute(() async {
        await remote.unregisterDevice(installationId);
        await local.forget(installationId);
      });

  Future<Either<Failure, Unit>> _execute(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on ApiException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[notifications] Backend registration update failed '
          '(HTTP ${error.statusCode ?? 'unavailable'}): ${error.message}',
        );
      }
      return Left(
        ServerFailure(message: error.message, statusCode: error.statusCode),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message:
              'Unable to update notification registration. Please try again.',
        ),
      );
    }
  }
}
