import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? selectedDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String helpText = 'Select date',
}) {
  final today = DateUtils.dateOnly(DateTime.now());
  final minimumDate = DateUtils.dateOnly(
    firstDate ?? today.subtract(const Duration(days: 3)),
  );
  final maximumDate = DateUtils.dateOnly(
    lastDate ?? DateTime(today.year + 2, today.month, today.day),
  );
  final requestedDate = DateUtils.dateOnly(selectedDate ?? minimumDate);
  final initialDate = requestedDate.isBefore(minimumDate)
      ? minimumDate
      : requestedDate.isAfter(maximumDate)
      ? maximumDate
      : requestedDate;

  return showDatePicker(
    context: context,
    switchToInputEntryModeIcon: const Icon(LucideIcons.pencil),
    switchToCalendarEntryModeIcon: const Icon(LucideIcons.calendar),
    initialDate: initialDate,
    firstDate: minimumDate,
    lastDate: maximumDate,
    helpText: helpText,
    cancelText: 'Cancel',
    confirmText: 'Select',
    fieldHintText: 'MM/DD/YYYY',
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.ink,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          headerBackgroundColor: AppColors.skyPale,
          headerForegroundColor: AppColors.ink,
          todayBackgroundColor: const WidgetStatePropertyAll(AppColors.skyPale),
          todayForegroundColor: const WidgetStatePropertyAll(AppColors.accent),
          dayOverlayColor: const WidgetStatePropertyAll(AppColors.skyPale),
        ),
      ),
      child: child!,
    ),
  );
}
