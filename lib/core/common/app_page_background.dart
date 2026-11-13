import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEDF8FD), AppColors.background, Color(0xFFF8FAFD)],
        stops: [0, .35, 1],
      ),
    ),
    child: SizedBox.expand(child: child),
  );
}
