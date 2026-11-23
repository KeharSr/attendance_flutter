import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:attendance_flutter/features/auth/presentation/view_model/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Auth extends AuthViewModel {
  int logins = 0;
  int biometricLogins = 0;
  @override
  Future<void> loadBiometricStatus() async {
    state = state.copyWith(biometricAvailable: true, biometricEnabled: true);
  }

  @override
  Future<void> loginWithBiometrics() async {
    biometricLogins++;
  }

  String? phone, password;
  @override
  Future<void> loginUser({
    required String phone,
    required String password,
  }) async {
    logins++;
    this.phone = phone;
    this.password = password;
  }
}

void main() {
  testWidgets(
    'fingerprint calls the view model and password sign-in remains available',
    (tester) async {
      final auth = _Auth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authViewModelProvider.overrideWith(() => auth)],
          child: MaterialApp(theme: buildAppTheme(), home: const LoginView()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Sign in with biometrics'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sign in with biometrics'));
      expect(auth.logins, 0);
      expect(auth.biometricLogins, 1);
      expect(find.byTooltip('Sign in with biometrics'), findsOneWidget);
      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(auth.logins, 0);
      expect(find.text('Enter your phone number'), findsWidgets);
      await tester.enterText(find.byType(TextFormField).first, '9800000000');
      await tester.enterText(find.byType(TextFormField).last, 'test-password');
      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      expect(auth.logins, 1);
      expect(auth.phone, '9800000000');
      expect(auth.password, 'test-password');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'login and fingerprint section fit narrow screens with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authViewModelProvider.overrideWith(_Auth.new)],
          child: MaterialApp(
            theme: buildAppTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.8)),
              child: child!,
            ),
            home: const LoginView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Sign in with biometrics'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Sign in with biometrics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
