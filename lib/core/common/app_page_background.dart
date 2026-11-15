import 'package:flutter/material.dart';

class AppPageBackground extends StatelessWidget {
  const AppPageBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(child: child);
}
