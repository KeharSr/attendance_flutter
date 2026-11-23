import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:attendance_flutter/app/app.dart';
import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/auth/data/data_source/auth_data_source.dart';
import 'package:attendance_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:attendance_flutter/features/auth/data/data_source/biometric_local_data_source.dart';
import 'package:attendance_flutter/features/auth/data/data_source/auth_session_local_data_source.dart';
import 'package:attendance_flutter/core/service/token_storage/secure_token_local_data_source.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/profile_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => respond(options);
  @override
  void close({bool force = false}) {}
}

class _Backend {
  late final ApiClient client;
  final requests = <RequestOptions>[];
  String validAccess = 'access-valid';
  int refreshes = 0;
  int logouts = 0;
  bool failLogout = false;
  bool rejectRefresh = false;
  bool rejectAllProtected = false;
  Completer<void>? pendingLogout;
  Completer<void>? pendingRefresh;

  _Backend({Future<void> Function()? onSessionExpired}) {
    Dio createDio() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      dio.httpClientAdapter = _Adapter(_respond);
      return dio;
    }

    client = ApiClient(
      dio: createDio(),
      refreshDio: createDio(),
      onSessionExpired: onSessionExpired,
    );
    client.dio.interceptors.removeWhere(
      (interceptor) => interceptor is PrettyDioLogger,
    );
  }

  ResponseBody json(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  Future<ResponseBody> _respond(RequestOptions request) async {
    requests.add(request);
    final path = request.uri.path;
    if (path.endsWith('/users/loginUser')) {
      return json(200, {
        'success': true,
        'data': {
          'id': '7',
          'name': 'Test Employee',
          'phone': '9800000000',
          'role': 'employee',
          'accessToken': validAccess,
          'refreshToken': 'refresh-valid',
        },
      });
    }
    if (path.endsWith('/users/refreshToken')) {
      refreshes++;
      expectSync(request.headers['Authorization'], isNull);
      final body = request.data is String
          ? jsonDecode(request.data as String)
          : request.data;
      expectSync((body as Map)['refreshToken'], 'refresh-valid');
      if (pendingRefresh != null) await pendingRefresh!.future;
      if (rejectRefresh) return json(401, {'message': 'Invalid refresh token'});
      validAccess = 'access-rotated';
      return json(200, {
        'success': true,
        'data': {'accessToken': validAccess, 'refreshToken': 'refresh-rotated'},
      });
    }
    if (rejectAllProtected ||
        request.headers['Authorization'] != 'Bearer $validAccess') {
      return json(401, {'message': 'Invalid or expired token'});
    }
    if (path.endsWith('/users/logout')) {
      logouts++;
      if (pendingLogout != null) await pendingLogout!.future;
      if (failLogout) {
        return json(500, {'success': false, 'message': 'Logout failed'});
      }
      return json(200, {'success': true, 'message': 'Logout successful'});
    }
    return json(200, {'success': true, 'data': null});
  }
}

AuthRepositoryImpl _repository(
  _Backend backend,
  SharedPreferences preferences,
) => AuthRepositoryImpl(
  authDataSource: AuthDataSource(apiClient: backend.client),
  biometrics: DeviceBiometricLocalDataSource(
    authentication: LocalAuthentication(),
  ),
  tokenStore: SecureTokenLocalDataSource(),
  session: SavedAuthSessionLocalDataSource(
    preferences: AppSharedPrefs(sharedPreferences: preferences),
  ),
);

Future<SharedPreferences> _prefs({bool loggedIn = true}) async {
  SharedPreferences.setMockInitialValues({
    SharedPrefsKeys.isUserLoggedIn: loggedIn,
    if (loggedIn) SharedPrefsKeys.userNameKey: 'Test Employee',
    if (loggedIn) SharedPrefsKeys.userIdKey: '7',
    if (loggedIn) SharedPrefsKeys.userPhoneKey: '9800000000',
  });
  return SharedPreferences.getInstance();
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-valid',
      'auth_refresh_token': 'refresh-valid',
    }),
  );

  test('logout posts the bearer token, then clears secure storage and saved employee data', () async {
    final prefs = await _prefs();
    final backend = _Backend();
    final source = _repository(backend, prefs);
    expect(
      (await source.logoutUser()).fold(
        (failure) => throw StateError(failure.message),
        (message) => message,
      ),
      'Logout successful',
    );
    expect(backend.requests.single.method, 'POST');
    expect(backend.requests.single.path, ApiEndpoints.logout);
    expect(
      backend.requests.single.headers['Authorization'],
      'Bearer access-valid',
    );
    expect(await backend.client.getAccessToken(), isNull);
    expect(await backend.client.getRefreshToken(), isNull);
    expect(prefs.getBool(SharedPrefsKeys.isUserLoggedIn), isNull);
    expect(prefs.getString(SharedPrefsKeys.userNameKey), isNull);
    expect(prefs.getString(SharedPrefsKeys.userIdKey), isNull);
    expect(prefs.getString(SharedPrefsKeys.userPhoneKey), isNull);
  });

  test('logout refreshes expired access, retries once, and clears both rotated tokens', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-expired',
      'auth_refresh_token': 'refresh-valid',
    });
    final prefs = await _prefs();
    final backend = _Backend();
    final source = _repository(backend, prefs);
    expect(
      (await source.logoutUser()).fold(
        (failure) => throw StateError(failure.message),
        (message) => message,
      ),
      'Logout successful',
    );
    expect(backend.refreshes, 1);
    expect(backend.logouts, 1);
    expect(backend.requests.map((r) => r.uri.path).toList(), [
      '/api/v1/users/logout',
      '/api/v1/users/refreshToken',
      '/api/v1/users/logout',
    ]);
    expect(
      backend.requests.last.headers['Authorization'],
      'Bearer access-rotated',
    );
    expect(await backend.client.getAccessToken(), isNull);
    expect(await backend.client.getRefreshToken(), isNull);
  });

  test(
    'failed logout preserves the local session and exposes the API failure',
    () async {
      final prefs = await _prefs();
      final backend = _Backend()..failLogout = true;
      final repo = _repository(backend, prefs);
      final result = await repo.logoutUser();
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Logout failed'),
        (_) => fail('Expected failure'),
      );
      expect(await backend.client.getAccessToken(), 'access-valid');
      expect(await backend.client.getRefreshToken(), 'refresh-valid');
      expect(prefs.getBool(SharedPrefsKeys.isUserLoggedIn), isTrue);
    },
  );

  test('simultaneous expired requests share one refresh operation', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-expired',
      'auth_refresh_token': 'refresh-valid',
    });
    final backend = _Backend()..pendingRefresh = Completer<void>();
    final first = backend.client.get<dynamic>(ApiEndpoints.todayAttendance);
    final second = backend.client.get<dynamic>(ApiEndpoints.todayAttendance);
    await _waitFor(() => backend.refreshes == 1);
    backend.pendingRefresh!.complete();
    final responses = await Future.wait([first, second]);
    expect(responses.every((response) => response.statusCode == 200), isTrue);
    expect(backend.refreshes, 1);
    expect(await backend.client.getRefreshToken(), 'refresh-rotated');
  });

  test('a failed refresh or rejected retry terminates instead of recursively refreshing', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-expired',
      'auth_refresh_token': 'refresh-valid',
    });
    final backend = _Backend()..rejectRefresh = true;
    await expectLater(
      backend.client
          .post<dynamic>(ApiEndpoints.logout)
          .timeout(const Duration(seconds: 2)),
      throwsA(isA<Exception>()),
    );
    expect(backend.refreshes, 1);
    expect(await backend.client.getAccessToken(), isNull);
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-expired',
      'auth_refresh_token': 'refresh-valid',
    });
    final rejectedRetry = _Backend()..rejectAllProtected = true;
    await expectLater(
      rejectedRetry.client
          .post<dynamic>(ApiEndpoints.logout)
          .timeout(const Duration(seconds: 2)),
      throwsA(isA<Exception>()),
    );
    expect(rejectedRetry.refreshes, 1);
    expect(await rejectedRetry.client.getRefreshToken(), isNull);
  });

  test(
    'an in-flight refresh cannot restore credentials after local cleanup',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'access-expired',
        'auth_refresh_token': 'refresh-valid',
      });
      final backend = _Backend()..pendingRefresh = Completer<void>();
      final request = backend.client
          .get<dynamic>(ApiEndpoints.todayAttendance)
          .then<Object?>((_) => null, onError: (Object error) => error);
      await _waitFor(() => backend.refreshes == 1);
      await backend.client.clearTokens();
      backend.pendingRefresh!.complete();
      expect(await request, isA<Exception>());
      expect(await backend.client.getAccessToken(), isNull);
      expect(await backend.client.getRefreshToken(), isNull);
    },
  );

  for (final scenario in [
    'missing tokens',
    'rejected refresh',
    'rejected retry',
  ]) {
    testWidgets('notification 401 logs out after $scenario', (tester) async {
      FlutterSecureStorage.setMockInitialValues(
        scenario == 'missing tokens'
            ? {}
            : {
                'auth_token': 'access-expired',
                'auth_refresh_token': 'refresh-valid',
              },
      );
      final prefs = await _prefs();
      late ProviderContainer container;
      var expirations = 0;
      final backend =
          _Backend(
              onSessionExpired: () async {
                expirations++;
                await container
                    .read(authViewModelProvider.notifier)
                    .expireSession();
              },
            )
            ..rejectRefresh = scenario == 'rejected refresh'
            ..rejectAllProtected = scenario == 'rejected retry';
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(backend.client),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const App()),
      );
      // Send the registration before dashboard startup to isolate the failure.
      final registration = backend.client
          .post<dynamic>(ApiEndpoints.registerDevice)
          .then<Object?>((_) => null, onError: (Object error) => error);
      await tester.pumpAndSettle();
      final registrationError = await registration;
      expect(registrationError, isA<Exception>());
      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pumpAndSettle();
      expect(expirations, 1);
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(DashboardView), findsNothing);
      expect(
        find.text('Your session has expired. Please sign in again.'),
        findsOneWidget,
      );
      expect(container.read(authSessionProvider), isFalse);
      expect(prefs.getBool(SharedPrefsKeys.isUserLoggedIn), isNull);
      expect(prefs.getString(SharedPrefsKeys.userIdKey), isNull);
      expect(await backend.client.getAccessToken(), isNull);
      expect(await backend.client.getRefreshToken(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'login and API logout use the root auth flow and show the logout message on Login',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await _prefs(loggedIn: false);
      final backend = _Backend();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(backend.client),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const App()),
      );
      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '9800000000');
      await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardView), findsOneWidget);
      container
          .read(dashboardNavigationProvider.notifier)
          .select(DashboardTab.profile);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(DashboardView), findsNothing);
      expect(find.text('Logout successful'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(LoginView))).canPop(),
        isFalse,
      );
      expect(await backend.client.getAccessToken(), isNull);
      expect(container.read(authSessionProvider), isFalse);
      expect(container.read(authViewModelProvider).user, isNull);
      expect(container.read(attendanceViewModelProvider).attendance, isNull);
      expect(container.read(leaveViewModelProvider).requests, isEmpty);
      expect(container.read(overtimeViewModelProvider).overtime, isEmpty);
      expect(
        container.read(missingAttendanceViewModelProvider).missingAttendance,
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'profile disables repeated sign-out taps and stays open when the API fails',
    (tester) async {
      final prefs = await _prefs();
      final backend = _Backend()
        ..failLogout = true
        ..pendingLogout = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(backend.client),
        ],
      );
      addTearDown(container.dispose);
      container.read(authSessionProvider.notifier).markLoggedIn();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: ProfileView())),
        ),
      );
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      for (var i = 0; i < 10 && backend.logouts == 0; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Signing out...'),
      );
      expect(button.onPressed, isNull);
      await container.read(authViewModelProvider.notifier).logoutUser();
      expect(backend.logouts, 1);
      backend.pendingLogout!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ProfileView), findsOneWidget);
      expect(find.text('Logout failed'), findsOneWidget);
      expect(container.read(authSessionProvider), isTrue);
      expect(await backend.client.getRefreshToken(), 'refresh-valid');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
