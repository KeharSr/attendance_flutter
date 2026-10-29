import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
    this.backgroundColor,
    this.label = 'Loading',
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicatorColor = color ?? colorScheme.primary;
    final trackColor =
        backgroundColor ?? indicatorColor.withValues(alpha: 0.16);

    return Semantics(
      label: label,
      liveRegion: true,
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          backgroundColor: trackColor,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message = 'Please wait...',
    this.indicatorSize = 34,
  });

  final String message;
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoadingIndicator(size: indicatorSize),
          const SizedBox(height: 14),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
