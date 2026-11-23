import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:attendance_flutter/app/app.dart';
import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/core/service/token_storage/secure_token_local_data_source.dart';
import 'package:attendance_flutter/features/auth/data/data_source/biometric_local_data_source.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Device implements BiometricLocalDataSource {
  bool available = true;
  bool accepted = true;
  int prompts = 0;
  Completer<bool>? pendingPrompt;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    return pendingPrompt?.future ?? Future.value(accepted);
  }
}

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
  final refreshTokens = <String>[];
  int logouts = 0;
  int protectedAttempts = 0;
  bool offline = false;
  bool rejectRefresh = false;
  bool malformedRefresh = false;
  bool malformedLogin = false;
  bool failLogout = false;
  bool expiredAccess = false;
  String access = 'access-0';
  String refresh = 'refresh-0';
  Completer<void>? pendingRefresh;
  late final ApiClient client;
  late final Dio refreshDio;
  _Backend(
    SecureTokenLocalDataSource store,
    Future<void> Function() onExpired,
  ) {
    Dio dio() =>
        Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
          ..httpClientAdapter = _Adapter(respond);
    refreshDio = dio();
    client = ApiClient(
      dio: dio(),
      refreshDio: refreshDio,
      tokenStore: store,
      onSessionExpired: onExpired,
    );
    client.dio.interceptors.removeWhere((entry) => entry is PrettyDioLogger);
  }
  ResponseBody json(int status, Map<String, Object?> data) =>
      ResponseBody.fromString(
        jsonEncode(data),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
  Future<ResponseBody> respond(RequestOptions request) async {
    if (request.uri.path == Uri.parse(ApiEndpoints.refreshToken).path) {
      expectSync(request.headers['Authorization'], isNull);
      final body = request.data is String
          ? jsonDecode(request.data as String)
          : request.data;
      final supplied = (body as Map)['refreshToken'] as String;
      refreshTokens.add(supplied);
      if (pendingRefresh != null) await pendingRefresh!.future;
      if (offline) {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        );
      }
      if (rejectRefresh || supplied != refresh) {
        return json(401, {'message': 'Invalid refresh token'});
      }
      if (malformedRefresh) return json(200, {'data': null});
      access = 'access-${refreshTokens.length}';
      refresh = 'refresh-${refreshTokens.length}';
      expiredAccess = false;
      return json(200, {
        'data': {'accessToken': access, 'refreshToken': refresh},
      });
    }
    if (request.uri.path == Uri.parse(ApiEndpoints.loginUser).path) {
      if (malformedLogin) {
        return json(200, {
          'data': {'accessToken': access, 'refreshToken': refresh},
        });
      }
      return json(200, {
        'data': {
          'id': '8',
          'name': 'Other Employee',
          'phone': '9811111111',
          'role': 'employee',
          'accessToken': access,
          'refreshToken': refresh,
        },
      });
    }
    if (request.uri.path == Uri.parse(ApiEndpoints.logout).path) {
      protectedAttempts++;
      if (expiredAccess ||
          request.headers['Authorization'] != 'Bearer $access') {
        return json(401, {'message': 'Expired token'});
      }
      logouts++;
      if (failLogout) {
        return json(500, {'message': 'Logout failed', 'success': false});
      }
      return json(200, {'success': true, 'message': 'Logout successful'});
    }
    return json(200, {'success': true, 'data': null});
  }

  void dispose() {
    client.dio.close(force: true);
    refreshDio.close(force: true);
  }
}

class _Harness {
  _Harness(
    this.container,
    this.store,
    this.device,
    this.backend,
    this.preferences,
  );
  final ProviderContainer container;
  final SecureTokenLocalDataSource store;
  final _Device device;
  final _Backend backend;
  final SharedPreferences preferences;
  static Future<_Harness> create({
    bool enabled = true,
    bool unlocked = false,
  }) async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_token': 'access-0',
      'auth_refresh_token': 'refresh-0',
      if (enabled) 'biometric_enabled': 'true',
      if (enabled) 'biometric_user_id': '7',
    });
    SharedPreferences.setMockInitialValues({
      SharedPrefsKeys.isUserLoggedIn: true,
      SharedPrefsKeys.userIdKey: '7',
      SharedPrefsKeys.userNameKey: 'Test Employee',
      SharedPrefsKeys.userPhoneKey: '9800000000',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SecureTokenLocalDataSource();
    final device = _Device();
    late ProviderContainer container;
    final backend = _Backend(
      store,
      () => container.read(authViewModelProvider.notifier).expireSession(),
    );
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        tokenLocalDataSourceProvider.overrideWithValue(store),
        biometricLocalDataSourceProvider.overrideWithValue(device),
        apiClientProvider.overrideWithValue(backend.client),
      ],
    );
    if (unlocked) container.read(authSessionProvider.notifier).markLoggedIn();
    final harness = _Harness(container, store, device, backend, preferences);
    addTearDown(() {
      container.dispose();
      backend.dispose();
    });
    return harness;
  }
}

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saved credentials never bypass sign-in on cold start', () async {
    final h = await _Harness.create();
    expect(h.container.read(authSessionProvider), isFalse);
    await h.container
        .read(authViewModelProvider.notifier)
        .loadBiometricStatus();
    expect(h.container.read(authViewModelProvider).biometricEnabled, isTrue);
    expect(h.container.read(authViewModelProvider).biometricAvailable, isTrue);
    expect(h.backend.refreshTokens, isEmpty);
    expect(h.device.prompts, 0);
  });

  test('enabling requires device authentication and binds enrollment to the current account', () async {
    final h = await _Harness.create(enabled: false, unlocked: true);
    await h.container
        .read(authViewModelProvider.notifier)
        .setBiometricLoginEnabled(true);
    expect(h.device.prompts, 1);
    expect(await h.store.isBiometricEnabledFor('7'), isTrue);
    expect(await h.store.isBiometricEnabledFor('8'), isFalse);
    expect(await h.store.getRefreshToken(), 'refresh-0');
    expect(h.container.read(authViewModelProvider).biometricEnabled, isTrue);
  });

  test('cancelled enrollment leaves biometric access disabled', () async {
    final h = await _Harness.create(enabled: false, unlocked: true);
    h.device.accepted = false;
    await h.container
        .read(authViewModelProvider.notifier)
        .setBiometricLoginEnabled(true);
    expect(await h.store.isBiometricEnabledFor('7'), isFalse);
    expect(h.container.read(authViewModelProvider).isBiometricLoading, isFalse);
    expect(h.container.read(authViewModelProvider).errorMessage, isNull);
  });

  test('biometric sign-in rotates tokens and subsequent sign-in uses the rotated refresh token', () async {
    final h = await _Harness.create();
    final model = h.container.read(authViewModelProvider.notifier);
    await model.loginWithBiometrics();
    expect(h.container.read(authSessionProvider), isTrue);
    expect(h.container.read(authViewModelProvider).user?.id, '7');
    expect(await h.store.getAccessToken(), 'access-1');
    expect(await h.store.getRefreshToken(), 'refresh-1');
    h.container.read(authSessionProvider.notifier).markLoggedOut();
    await model.loginWithBiometrics();
    expect(h.backend.refreshTokens, ['refresh-0', 'refresh-1']);
    expect(await h.store.getRefreshToken(), 'refresh-2');
    expect(await h.store.isBiometricEnabledFor('7'), isTrue);
  });

  test(
    'cancelled biometric sign-in never calls the server or unlocks the app',
    () async {
      final h = await _Harness.create();
      h.device.accepted = false;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginWithBiometrics();
      expect(h.backend.refreshTokens, isEmpty);
      expect(h.container.read(authSessionProvider), isFalse);
      expect(await h.store.isBiometricEnabledFor('7'), isTrue);
      expect(h.container.read(authViewModelProvider).errorMessage, isNull);
    },
  );

  test(
    'unavailable hardware leaves password fallback and saved enrollment intact',
    () async {
      final h = await _Harness.create();
      h.device.available = false;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginWithBiometrics();
      expect(h.device.prompts, 0);
      expect(h.backend.refreshTokens, isEmpty);
      expect(
        h.container.read(authViewModelProvider).errorMessage,
        contains('unavailable'),
      );
      expect(await h.store.isBiometricEnabledFor('7'), isTrue);
    },
  );

  test(
    'offline refresh preserves the saved session and can be retried',
    () async {
      final h = await _Harness.create();
      h.backend.offline = true;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginWithBiometrics();
      expect(h.container.read(authSessionProvider), isFalse);
      expect(await h.store.getRefreshToken(), 'refresh-0');
      expect(await h.store.isBiometricEnabledFor('7'), isTrue);
      expect(h.preferences.getString(SharedPrefsKeys.userIdKey), '7');
      h.backend.offline = false;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginWithBiometrics();
      expect(h.container.read(authSessionProvider), isTrue);
      expect(h.backend.refreshTokens, ['refresh-0', 'refresh-0']);
    },
  );

  test('a malformed refresh response does not erase a saved session', () async {
    final h = await _Harness.create();
    h.backend.malformedRefresh = true;
    await h.container
        .read(authViewModelProvider.notifier)
        .loginWithBiometrics();
    expect(h.container.read(authSessionProvider), isFalse);
    expect(await h.store.getRefreshToken(), 'refresh-0');
    expect(await h.store.isBiometricEnabledFor('7'), isTrue);
    expect(h.preferences.getString(SharedPrefsKeys.userIdKey), '7');
  });

  test(
    'a rejected refresh clears credentials, enrollment, and saved profile',
    () async {
      final h = await _Harness.create();
      h.backend.rejectRefresh = true;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginWithBiometrics();
      expect(h.container.read(authSessionProvider), isFalse);
      expect(await h.store.getAccessToken(), isNull);
      expect(await h.store.getRefreshToken(), isNull);
      expect(await h.store.isBiometricEnabledFor('7'), isFalse);
      expect(h.preferences.getString(SharedPrefsKeys.userIdKey), isNull);
      expect(
        h.container.read(authViewModelProvider).logoutMessage,
        contains('expired'),
      );
    },
  );

  test('turning biometrics off refreshes expired access, logs out, and clears every credential', () async {
    final h = await _Harness.create(unlocked: true);
    final model = h.container.read(authViewModelProvider.notifier);
    await model.loadBiometricStatus();
    h.backend.expiredAccess = true;
    await model.setBiometricLoginEnabled(false);
    expect(h.backend.protectedAttempts, 2);
    expect(h.backend.logouts, 1);
    expect(h.backend.refreshTokens, ['refresh-0']);
    expect(h.container.read(authSessionProvider), isFalse);
    expect(await h.store.getRefreshToken(), isNull);
    expect(await h.store.isBiometricEnabledFor('7'), isFalse);
    expect(h.preferences.getString(SharedPrefsKeys.userIdKey), isNull);
  });

  test('failed logout keeps the switch enabled and the session available for retry', () async {
    final h = await _Harness.create(unlocked: true);
    final model = h.container.read(authViewModelProvider.notifier);
    await model.loadBiometricStatus();
    h.backend.failLogout = true;
    await model.setBiometricLoginEnabled(false);
    expect(h.container.read(authSessionProvider), isTrue);
    expect(h.container.read(authViewModelProvider).biometricEnabled, isTrue);
    expect(await h.store.isBiometricEnabledFor('7'), isTrue);
    expect(
      h.container.read(authViewModelProvider).errorMessage,
      'Logout failed',
    );
  });

  test('a late biometric refresh cannot restore credentials after they are cleared', () async {
    final h = await _Harness.create();
    h.backend.pendingRefresh = Completer<void>();
    final login = h.container
        .read(authViewModelProvider.notifier)
        .loginWithBiometrics();
    await _until(() => h.backend.refreshTokens.isNotEmpty);
    await h.backend.client.clearTokens();
    h.backend.pendingRefresh!.complete();
    await login;
    expect(await h.store.getAccessToken(), isNull);
    expect(await h.store.getRefreshToken(), isNull);
    expect(h.container.read(authSessionProvider), isFalse);
  });

  test('simultaneous restorations share one refresh request', () async {
    final h = await _Harness.create();
    h.backend.pendingRefresh = Completer<void>();
    final first = h.backend.client.restoreSavedSession();
    final second = h.backend.client.restoreSavedSession();
    await _until(() => h.backend.refreshTokens.isNotEmpty);
    h.backend.pendingRefresh!.complete();
    expect(await Future.wait([first, second]), [true, true]);
    expect(h.backend.refreshTokens.length, 1);
  });

  test(
    'password sign-in to another account clears the previous enrollment',
    () async {
      final h = await _Harness.create();
      await h.container
          .read(authViewModelProvider.notifier)
          .loginUser(phone: '9811111111', password: 'password');
      expect(h.preferences.getString(SharedPrefsKeys.userIdKey), '8');
      expect(await h.store.isBiometricEnabledFor('7'), isFalse);
      expect(await h.store.isBiometricEnabledFor('8'), isFalse);
    },
  );

  test(
    'malformed password login cannot pair new tokens with an old enrollment',
    () async {
      final h = await _Harness.create();
      h.backend.malformedLogin = true;
      await h.container
          .read(authViewModelProvider.notifier)
          .loginUser(phone: '9811111111', password: 'password');
      expect(h.container.read(authSessionProvider), isFalse);
      expect(await h.store.getRefreshToken(), isNull);
      expect(await h.store.isBiometricEnabledFor('7'), isFalse);
    },
  );

  test('sign-out while already locked does not leave the UI busy', () async {
    final h = await _Harness.create();
    await h.container.read(authViewModelProvider.notifier).logoutUser();
    expect(h.container.read(authViewModelProvider).isLoggingOut, isFalse);
    expect(h.backend.logouts, 0);
  });

  test(
    'clearing tokens also removes legacy biometric refresh-token copies',
    () async {
      final h = await _Harness.create();
      const storage = FlutterSecureStorage();
      await storage.write(key: 'biometric_refresh_token', value: 'old-copy');
      await h.store.clearTokens();
      expect(await storage.read(key: 'biometric_refresh_token'), isNull);
      expect(await storage.read(key: 'biometric_enabled'), isNull);
      expect(await storage.read(key: 'biometric_user_id'), isNull);
    },
  );

  test(
    'pending enrollment rejects duplicate prompts and sign-out races',
    () async {
      final h = await _Harness.create(enabled: false, unlocked: true);
      final model = h.container.read(authViewModelProvider.notifier);
      h.device.pendingPrompt = Completer<bool>();
      final enable = model.setBiometricLoginEnabled(true);
      await _until(() => h.device.prompts == 1);
      await model.setBiometricLoginEnabled(true);
      await model.logoutUser();
      expect(h.device.prompts, 1);
      expect(h.backend.logouts, 0);
      h.device.pendingPrompt!.complete(false);
      await enable;
      expect(await h.store.isBiometricEnabledFor('7'), isFalse);
    },
  );

  test('a late device prompt cannot unlock an expired session', () async {
    final h = await _Harness.create();
    final model = h.container.read(authViewModelProvider.notifier);
    h.device.pendingPrompt = Completer<bool>();
    final login = model.loginWithBiometrics();
    await _until(() => h.device.prompts == 1);
    await h.backend.client.clearTokens();
    await model.expireSession();
    h.device.pendingPrompt!.complete(true);
    await login;
    expect(h.backend.refreshTokens, isEmpty);
    expect(h.container.read(authSessionProvider), isFalse);
    expect(
      h.container.read(authViewModelProvider).logoutMessage,
      contains('expired'),
    );
  });

  testWidgets(
    'fingerprint login opens the dashboard and switching off returns to login',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final h = await _Harness.create();
      await tester.pumpWidget(
        UncontrolledProviderScope(container: h.container, child: const App()),
      );
      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Sign in with biometrics'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sign in with biometrics'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardView), findsOneWidget);
      h.container
          .read(dashboardNavigationProvider.notifier)
          .select(DashboardTab.profile);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      expect(h.container.read(authSessionProvider), isFalse);
      expect(await h.store.isBiometricEnabledFor('7'), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
