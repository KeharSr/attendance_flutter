import 'package:attendance_flutter/features/splash/presentation/view/splash_view.dart';
import 'package:attendance_flutter/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupComplete = ref.watch(splashViewModelProvider);
    final isUserLoggedIn = ref.watch(authSessionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GBN Store HRMS',
      theme: buildAppTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOut,
        child: !startupComplete
            ? const SplashView(key: ValueKey('splash'))
            : isUserLoggedIn
            ? const DashboardView(key: ValueKey('dashboard'))
            : const LoginView(key: ValueKey('login')),
      ),
    );
  }
}
