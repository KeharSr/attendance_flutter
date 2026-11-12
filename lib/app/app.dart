import 'package:attendance_flutter/features/splash/presentation/view/splash_view.dart';
import 'package:attendance_flutter/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/features/notifications/presentation/widgets/notification_listener.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final startupComplete = ref.watch(splashViewModelProvider);
    final isUserLoggedIn = ref.watch(authSessionProvider);
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      builder: (context, child) => AppNotificationListener(
        navigatorKey: _navigatorKey,
        messengerKey: _messengerKey,
        child: child ?? const SizedBox.shrink(),
      ),
      debugShowCheckedModeBanner: false,
      title: 'GBN Store HRMS',
      theme: buildAppTheme(),
      home: !startupComplete
          ? const SplashView(key: ValueKey('splash'))
          : isUserLoggedIn
          ? DashboardView(
              key: const ValueKey('dashboard'),
              message: authState.successMessage,
            )
          : LoginView(
              key: const ValueKey('login'),
              message: authState.logoutMessage,
            ),
    );
  }
}
