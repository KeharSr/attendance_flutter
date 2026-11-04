import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.background,
    child: SizedBox.expand(child: child),
  );
}
