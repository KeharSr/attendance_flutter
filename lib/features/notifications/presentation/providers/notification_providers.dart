import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/notifications/firebase_messaging_service.dart';
import 'package:attendance_flutter/core/service/notifications/android_notification_service.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_local_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_remote_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:attendance_flutter/features/notifications/domain/repository/notification_repository.dart';
import 'package:attendance_flutter/features/notifications/domain/usecase/register_device_usecase.dart';
import 'package:attendance_flutter/features/notifications/domain/usecase/unregister_device_usecase.dart';
import 'package:attendance_flutter/features/notifications/presentation/view_model/state/notification_state.dart';
import 'package:attendance_flutter/features/notifications/presentation/view_model/view_model/notification_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMessagingServiceProvider = Provider(
  (ref) => FirebaseMessagingService(),
);

final androidNotificationServiceProvider = Provider((ref) {
  final service = AndroidNotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationLocalDataSourceProvider = Provider(
  (ref) => NotificationLocalDataSource(
    preferences: ref.read(sharedPreferencesProvider),
  ),
);

final notificationRemoteDataSourceProvider = Provider(
  (ref) => NotificationRemoteDataSource(apiClient: ref.read(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<INotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    messaging: ref.read(firebaseMessagingServiceProvider),
    remote: ref.read(notificationRemoteDataSourceProvider),
    local: ref.read(notificationLocalDataSourceProvider),
  ),
);

final registerDeviceUsecaseProvider = Provider(
  (ref) => RegisterDeviceUsecase(
    repository: ref.read(notificationRepositoryProvider),
  ),
);

final unregisterDeviceUsecaseProvider = Provider(
  (ref) => UnregisterDeviceUsecase(
    repository: ref.read(notificationRepositoryProvider),
  ),
);

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );
