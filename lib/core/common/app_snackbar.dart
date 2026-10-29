import 'package:flutter/material.dart';

enum AppSnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static const _defaultDuration = Duration(seconds: 4);

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final appearance = _appearance(context, type);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          elevation: 4,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: appearance.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Semantics(
            liveRegion: true,
            label: trimmedMessage,
            child: Row(
              children: [
                Icon(appearance.icon, color: appearance.foregroundColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trimmedMessage,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: appearance.foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: appearance.foregroundColor,
                  onPressed: onAction,
                ),
        ),
      );
  }

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }

  static _SnackBarAppearance _appearance(
    BuildContext context,
    AppSnackBarType type,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      AppSnackBarType.success => _SnackBarAppearance(
        backgroundColor: const Color(0xFF166534),
        foregroundColor: colorScheme.onPrimary,
        icon: Icons.check_circle_outline_rounded,
      ),
      AppSnackBarType.error => _SnackBarAppearance(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        icon: Icons.error_outline_rounded,
      ),
      AppSnackBarType.warning => _SnackBarAppearance(
        backgroundColor: const Color(0xFF92400E),
        foregroundColor: Colors.white,
        icon: Icons.warning_amber_rounded,
      ),
      AppSnackBarType.info => _SnackBarAppearance(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: Icons.info_outline_rounded,
      ),
    };
  }
}

class _SnackBarAppearance {
  const _SnackBarAppearance({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
}
