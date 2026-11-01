import 'package:flutter/material.dart';

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? selectedDate,
  DateTime? firstDate,
  String helpText = 'Select date',
}) {
  final today = DateUtils.dateOnly(DateTime.now());
  final minimumDate = DateUtils.dateOnly(firstDate ?? today);
  final initialDate = DateUtils.dateOnly(selectedDate ?? minimumDate);

  return showDatePicker(
    context: context,
    initialDate: initialDate.isBefore(minimumDate) ? minimumDate : initialDate,
    firstDate: minimumDate,
    lastDate: DateTime(today.year + 2, today.month, today.day),
    helpText: helpText,
    cancelText: 'Cancel',
    confirmText: 'Select',
    fieldHintText: 'MM/DD/YYYY',
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1769E0),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF102A43),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          headerBackgroundColor: const Color(0xFF1769E0),
          headerForegroundColor: Colors.white,
          todayBackgroundColor: const WidgetStatePropertyAll(Color(0x141769E0)),
          todayForegroundColor: const WidgetStatePropertyAll(Color(0xFF1769E0)),
          dayOverlayColor: const WidgetStatePropertyAll(Color(0x141769E0)),
        ),
      ),
      child: child!,
    ),
  );
}
