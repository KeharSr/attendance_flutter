import 'package:attendance_flutter/core/common/usecase.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/notifications/domain/repository/notification_repository.dart';
import 'package:dartz/dartz.dart';

class UnregisterDeviceUsecase implements UsecaseWithParams<Unit, String> {
  const UnregisterDeviceUsecase({required this.repository});

  final INotificationRepository repository;

  @override
  Future<Either<Failure, Unit>> call(String installationId) =>
      repository.unregisterDevice(installationId);
}
