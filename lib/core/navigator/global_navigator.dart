import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

void navigateToLogin() {
  navigator.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginView()),
    (route) => false,
  );
}
