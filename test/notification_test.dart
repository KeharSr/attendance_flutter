import 'dart:async';
import 'dart:convert';

import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/core/service/notifications/firebase_messaging_service.dart';
import 'package:attendance_flutter/core/service/notifications/android_notification_service.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/auth/domain/usecase/logout_user_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_local_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_remote_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/model/notification_model.dart';
import 'package:attendance_flutter/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/domain/repository/notification_repository.dart';
import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:attendance_flutter/features/notifications/presentation/widgets/notification_listener.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PermissionMessaging extends FirebaseMessagingService {
  bool failPermission = true;
  final requests = <bool>[];

  @override
  Future<bool> permissionGranted({required bool requestPermission}) async {
    requests.add(requestPermission);
    if (failPermission) {
      throw StateError('Permission channel temporarily unavailable');
    }
    return false;
  }
}

class _Repository implements INotificationRepository {
  final registrationEvents = StreamController<String>.broadcast(sync: true);
  final foregroundEvents = StreamController<AppNotification>.broadcast(
    sync: true,
  );
  final openedEvents = StreamController<AppNotification>.broadcast(sync: true);
  final calls = <String>[];
  final ids = <String>[];
  bool allowed = true;
  bool failRegister = false;
  bool failUnregister = false;
  String id = 'installation-a';
  AppNotification? initialMessage;
  Completer<void>? pendingRegister;

  @override
  bool get isSupported => true;
  @override
  Stream<String> get registrations => registrationEvents.stream;
  @override
  Stream<AppNotification> get foregroundMessages => foregroundEvents.stream;
  @override
  Stream<AppNotification> get openedMessages => openedEvents.stream;
  @override
  List<String> get savedInstallationIds => List.of(ids);
  @override
  Future<AppNotification?> initialize() async => initialMessage;
  @override
  Future<bool> enable({required bool requestPermission}) async {
    calls.add('enable');
    if (allowed) registrationEvents.add(id);
    return allowed;
  }

  @override
  Future<void> disable() async {
    calls.add('disable');
  }

  @override
  Future<Either<Failure, Unit>> registerDevice(String installationId) async {
    calls.add('register:$installationId');
    if (!ids.contains(installationId)) ids.add(installationId);
    await pendingRegister?.future;
    return failRegister
        ? const Left(ServerFailure(message: 'Offline'))
        : const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> unregisterDevice(String installationId) async {
    calls.add('unregister:$installationId');
    if (failUnregister) return const Left(ServerFailure(message: 'Offline'));
    ids.remove(installationId);
    return const Right(unit);
  }

  Future<void> dispose() async {
    await registrationEvents.close();
    await foregroundEvents.close();
    await openedEvents.close();
  }
}

class _Logout implements LogoutUserUsecase {
  _Logout(this.calls);
  final List<String> calls;
  bool fail = false;
  @override
  Future<Either<Failure, String>> call() async {
    calls.add('auth-logout');
    return fail
        ? const Left(ServerFailure(message: 'Logout failed'))
        : const Right('Signed out');
  }
}

Future<ProviderContainer> _container(
  _Repository repository, {
  bool loggedIn = true,
  _Logout? logout,
}) async {
  SharedPreferences.setMockInitialValues({
    SharedPrefsKeys.isUserLoggedIn: loggedIn,
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationRepositoryProvider.overrideWithValue(repository),
      if (logout != null) logoutUserUsecaseProvider.overrideWithValue(logout),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await repository.dispose();
  });
  return container;
}

Future<void> _flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  bool fail = false;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'success': !fail,
        'message': fail ? 'Registration rejected' : 'OK',
      }),
      fail ? 500 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in {
    'leave': NotificationDestination.leave,
    'overtime': NotificationDestination.overtime,
    'missing_attendance': NotificationDestination.missingAttendance,
  }.entries) {
    for (final decision in ['approved', 'rejected']) {
      test(
        '${entry.key} $decision preserves backend content and pending tap',
        () async {
          final message = NotificationModel.fromRemoteMessage(
            RemoteMessage(
              messageId: 'firebase-attempt-2',
              notification: const RemoteNotification(
                title: 'Backend title',
                body: 'Backend body',
              ),
              data: {'type': '${entry.key}_$decision', 'eventId': 'event-10'},
            ),
          );
          expect(message.destination, entry.value);
          expect(message.id, 'event-10');
          expect(message.displayText, 'Backend title\nBackend body');
          final repository = _Repository()..initialMessage = message;
          final container = await _container(repository, loggedIn: false);
          await container.read(notificationViewModelProvider.notifier).start();
          expect(
            container.read(notificationViewModelProvider).pendingTap,
            same(message),
          );
        },
      );
    }
  }

  testWidgets('native notification bridge handles cold and warm taps', (
    tester,
  ) async {
    const channel = AndroidNotificationService.channel;
    final taps = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'initialize') return 'clock_in';
      return true;
    });
    final service = AndroidNotificationService();
    addTearDown(() {
      service.dispose();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });
    await service.initialize(onTap: taps.add);
    expect(taps, ['clock_in']);
    tester.binding.channelBuffers.push(
      channel.name,
      channel.codec.encodeMethodCall(
        const MethodCall('notificationTapped', 'clock_out'),
      ),
      (_) {},
    );
    await tester.pump();
    expect(taps, ['clock_in', 'clock_out']);
  });

  for (final failure in ['none', 'detach', 'logout']) {
    testWidgets(
      'attendance notifications remain and sign-out is silent: $failure',
      (tester) async {
        final shown = <Map<Object?, Object?>>[];
        var clearCalls = 0;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          AndroidNotificationService.channel,
          (call) async {
            if (call.method == 'clear') clearCalls++;
            if (call.method == 'show') {
              shown.add(Map<Object?, Object?>.from(call.arguments as Map));
              return true;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            AndroidNotificationService.channel,
            null,
          ),
        );
        final repository = _Repository();
        final logout = _Logout(repository.calls)..fail = failure == 'logout';
        final container = await _container(repository, logout: logout);
        final navigatorKey = GlobalKey<NavigatorState>();
        final messengerKey = GlobalKey<ScaffoldMessengerState>();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: messengerKey,
              builder: (_, child) => AppNotificationListener(
                navigatorKey: navigatorKey,
                messengerKey: messengerKey,
                child: child!,
              ),
              home: const Scaffold(body: Text('App')),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 2400));
        await tester.pumpAndSettle();
        expect(shown, isEmpty);
        repository.foregroundEvents.add(
          const AppNotification(
            id: 'remote-message-1',
            title: 'Clock out successful',
            body: 'You have clocked out successfully.',
            type: 'clock_out',
          ),
        );
        await tester.pumpAndSettle();
        expect(shown.single['type'], 'clock_out');
        expect(shown.single['messageId'], 'remote-message-1');
        expect(find.byType(SnackBar), findsNothing);
        repository.failUnregister = failure == 'detach';
        await container.read(authViewModelProvider.notifier).logoutUser();
        await tester.pumpAndSettle();
        expect(shown, hasLength(1));
        expect(shown.single['type'], 'clock_out');
        if (failure == 'none') {
          expect(clearCalls, 1);
          expect(container.read(authSessionProvider), isFalse);
        } else {
          expect(clearCalls, 0);
          expect(container.read(authSessionProvider), isTrue);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test(
    'permission platform failure does not suppress the next permission request',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = NotificationLocalDataSource(
        preferences: await SharedPreferences.getInstance(),
      );
      final messaging = _PermissionMessaging();
      final repository = NotificationRepositoryImpl(
        messaging: messaging,
        remote: NotificationRemoteDataSource(apiClient: ApiClient(dio: Dio())),
        local: local,
      );
      await expectLater(
        repository.enable(requestPermission: true),
        throwsStateError,
      );
      expect(local.permissionRequested, isFalse);
      messaging.failPermission = false;
      expect(await repository.enable(requestPermission: true), isFalse);
      expect(local.permissionRequested, isTrue);
      await repository.enable(requestPermission: true);
      expect(messaging.requests, [true, true, false]);
    },
  );

  testWidgets(
    'reminder taps wait for login and disabled native display falls back to Open',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        AndroidNotificationService.channel,
        (call) async => call.method == 'show' ? false : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          AndroidNotificationService.channel,
          null,
        ),
      );
      final repository = _Repository()
        ..initialMessage = const AppNotification(type: 'clock_in');
      final container = await _container(repository, loggedIn: false);
      final navigatorKey = GlobalKey<NavigatorState>();
      final messengerKey = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: messengerKey,
            builder: (_, child) => AppNotificationListener(
              navigatorKey: navigatorKey,
              messengerKey: messengerKey,
              child: child!,
            ),
            home: Scaffold(
              body: Consumer(
                builder: (_, ref, _) =>
                    Text(ref.watch(dashboardNavigationProvider).name),
              ),
            ),
          ),
        ),
      );
      container
          .read(dashboardNavigationProvider.notifier)
          .select(DashboardTab.profile);
      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pumpAndSettle();
      expect(find.text('profile'), findsOneWidget);
      expect(
        container.read(notificationViewModelProvider).pendingTap,
        isNotNull,
      );
      container.read(authSessionProvider.notifier).markLoggedIn();
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(container.read(notificationViewModelProvider).pendingTap, isNull);
      container
          .read(dashboardNavigationProvider.notifier)
          .select(DashboardTab.profile);
      repository.foregroundEvents.add(
        const AppNotification(type: 'clock_out', title: 'Time to clock out'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Time to clock out'), findsOneWidget);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      container
          .read(dashboardNavigationProvider.notifier)
          .select(DashboardTab.profile);
      repository.openedEvents.add(const AppNotification(type: 'clock_in'));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'register and unregister use installationId, JWT and the agreed API paths',
    () async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-access'});
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final adapter = _Adapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final client = ApiClient(dio: dio);
      client.dio.interceptors.removeWhere((value) => value is PrettyDioLogger);
      final repository = NotificationRepositoryImpl(
        messaging: FirebaseMessagingService(),
        remote: NotificationRemoteDataSource(apiClient: client),
        local: NotificationLocalDataSource(preferences: prefs),
      );
      expect((await repository.registerDevice('fid-123')).isRight(), isTrue);
      expect(repository.savedInstallationIds, ['fid-123']);
      expect((await repository.unregisterDevice('fid-123')).isRight(), isTrue);
      expect(repository.savedInstallationIds, isEmpty);
      expect(adapter.requests.map((r) => r.method), ['POST', 'DELETE']);
      expect(adapter.requests.map((r) => r.path), [
        ApiEndpoints.registerDevice,
        ApiEndpoints.unregisterDevice,
      ]);
      for (final request in adapter.requests) {
        expect(request.data, {'installationId': 'fid-123'});
        expect(request.headers['Authorization'], 'Bearer test-access');
      }
      adapter.fail = true;
      expect(
        (await repository.registerDevice('uncertain-fid')).isLeft(),
        isTrue,
      );
      expect(repository.savedInstallationIds, ['uncertain-fid']);
      expect(
        (await repository.unregisterDevice('uncertain-fid')).isLeft(),
        isTrue,
      );
      expect(repository.savedInstallationIds, ['uncertain-fid']);
    },
  );

  test('registration waits for login and repeated registration events are deduplicated', () async {
    final repository = _Repository();
    final container = await _container(repository, loggedIn: false);
    final model = container.read(notificationViewModelProvider.notifier);
    await model.start();
    expect(repository.calls, isEmpty);
    container.read(authSessionProvider.notifier).markLoggedIn();
    await _flush();
    repository.registrationEvents.add(repository.id);
    await _flush();
    expect(repository.calls.where((call) => call.startsWith('register:')), [
      'register:installation-a',
    ]);
  });

  test('denied permission does not register and revocation removes the saved mapping', () async {
    final repository = _Repository()..allowed = false;
    final container = await _container(repository);
    final model = container.read(notificationViewModelProvider.notifier);
    await model.start();
    await _flush();
    expect(repository.ids, isEmpty);
    repository.allowed = true;
    await model.resume();
    await _flush();
    expect(repository.ids, ['installation-a']);
    repository.allowed = false;
    await model.resume();
    expect(repository.ids, isEmpty);
  });

  test('new installation replaces old registration and HTTP failures retry on resume', () async {
    final repository = _Repository()..failRegister = true;
    final container = await _container(repository);
    final model = container.read(notificationViewModelProvider.notifier);
    await model.start();
    await _flush();
    expect(
      container.read(notificationViewModelProvider).errorMessage,
      isNotNull,
    );
    repository.failRegister = false;
    await model.resume();
    await _flush();
    expect(container.read(notificationViewModelProvider).errorMessage, isNull);
    repository.id = 'installation-b';
    repository.registrationEvents.add(repository.id);
    await _flush();
    expect(repository.ids, ['installation-b']);
    expect(repository.calls, contains('unregister:installation-a'));
  });

  test('logout waits for an in-flight registration before unregister and auth logout', () async {
    final repository = _Repository()..pendingRegister = Completer<void>();
    final container = await _container(
      repository,
      logout: _Logout(repository.calls),
    );
    final model = container.read(notificationViewModelProvider.notifier);
    final starting = model.start();
    await _flush();
    expect(repository.calls, contains('register:installation-a'));
    final logout = container.read(authViewModelProvider.notifier).logoutUser();
    await _flush();
    expect(repository.calls, isNot(contains('auth-logout')));
    repository.pendingRegister!.complete();
    await starting;
    await logout;
    expect(
      repository.calls,
      containsAllInOrder([
        'register:installation-a',
        'unregister:installation-a',
        'disable',
        'auth-logout',
      ]),
    );
    repository.registrationEvents.add('late-registration');
    await _flush();
    expect(repository.ids, isEmpty);
    expect(container.read(authSessionProvider), isFalse);
  });

  test('failed detach keeps authentication available for a retry', () async {
    final repository = _Repository();
    final container = await _container(
      repository,
      logout: _Logout(repository.calls),
    );
    await container.read(notificationViewModelProvider.notifier).start();
    await _flush();
    repository.failUnregister = true;
    await container.read(authViewModelProvider.notifier).logoutUser();
    expect(container.read(authSessionProvider), isTrue);
    expect(repository.calls, isNot(contains('auth-logout')));
    expect(
      container.read(authViewModelProvider).errorMessage,
      contains('disconnect notifications'),
    );
    repository.failUnregister = false;
    await container.read(authViewModelProvider.notifier).logoutUser();
    expect(container.read(authSessionProvider), isFalse);
  });

  test(
    'failed auth logout restores the detached notification registration',
    () async {
      final repository = _Repository();
      final logout = _Logout(repository.calls)..fail = true;
      final container = await _container(repository, logout: logout);
      await container.read(notificationViewModelProvider.notifier).start();
      await _flush();
      await container.read(authViewModelProvider.notifier).logoutUser();
      await _flush();
      expect(container.read(authSessionProvider), isTrue);
      expect(repository.ids, ['installation-a']);
      expect(
        repository.calls,
        containsAllInOrder([
          'unregister:installation-a',
          'auth-logout',
          'register:installation-a',
        ]),
      );
    },
  );

  test('cold-start reminder is retained for login; logout clears pending UI messages', () async {
    final repository = _Repository()
      ..initialMessage = const AppNotification(type: 'clock_in');
    final container = await _container(repository, loggedIn: false);
    final model = container.read(notificationViewModelProvider.notifier);
    await model.start();
    expect(
      container.read(notificationViewModelProvider).pendingTap?.type,
      'clock_in',
    );
    container.read(authSessionProvider.notifier).markLoggedIn();
    await _flush();
    model.acknowledgeTap();
    expect(container.read(notificationViewModelProvider).pendingTap, isNull);
    repository.foregroundEvents.add(
      const AppNotification(title: 'Clock out', type: 'clock_out'),
    );
    expect(
      container.read(notificationViewModelProvider).foreground?.title,
      'Clock out',
    );
    repository.openedEvents.add(const AppNotification(type: 'clock_out'));
    expect(
      container.read(notificationViewModelProvider).pendingTap?.type,
      'clock_out',
    );
    await model.prepareLogout();
    expect(container.read(notificationViewModelProvider).pendingTap, isNull);
    expect(container.read(notificationViewModelProvider).foreground, isNull);
  });

  test('Firebase data is mapped to a framework-independent reminder', () {
    final notification = NotificationModel.fromRemoteMessage(
      const RemoteMessage(
        messageId: 'message-1',
        notification: RemoteNotification(
          title: 'Clock in',
          body: 'Your workday starts now.',
        ),
        data: {'type': 'clock_in'},
      ),
    );
    expect(notification.isAttendanceReminder, isTrue);
    expect(notification.displayText, 'Clock in\nYour workday starts now.');
  });
}
