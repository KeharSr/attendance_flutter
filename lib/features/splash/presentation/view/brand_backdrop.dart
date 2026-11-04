import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({required this.child, this.dark = false, super.key});
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: dark ? AppColors.ink : AppColors.background,
    child: SizedBox.expand(child: child),
  );
}
