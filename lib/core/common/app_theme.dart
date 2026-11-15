import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF4F9FC);
  static const skyPale = Color(0xFFCFECF7);
  static const skyLight = Color(0xFFA0D9EF);
  static const sky = Color(0xFF62C1E5);
  static const blue = Color(0xFF20A7DB);
  static const blueDeep = Color(0xFF1C96C5);
  static const surface = Colors.white;
  static const ink = Color(0xFF163449);
  static const muted = Color(0xFF667085);
  static const accent = Color(0xFF126B8E);
  static const accentLight = skyPale;
  static const border = Color(0xFFDFEDF4);
  static const success = Color(0xFF067647);
  static const danger = Color(0xFFB42318);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
  );
  return base.copyWith(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => const Icon(LucideIcons.arrowLeft),
      closeButtonIconBuilder: (context) => const Icon(LucideIcons.x),
      drawerButtonIconBuilder: (context) => const Icon(LucideIcons.menu),
      endDrawerButtonIconBuilder: (context) => const Icon(LucideIcons.menu),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shape.copyWith(side: const BorderSide(color: AppColors.border)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        elevation: 0,
        shape: shape,
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(48, 44),
        side: const BorderSide(color: AppColors.border),
        shape: shape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
