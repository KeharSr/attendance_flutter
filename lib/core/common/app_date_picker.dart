import 'package:flutter/material.dart';

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? selectedDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String helpText = 'Select date',
}) {
  final today = DateUtils.dateOnly(DateTime.now());
  final minimumDate = DateUtils.dateOnly(firstDate ?? today);
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
          primary: Color(0xFF006B7A),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF182230),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          headerBackgroundColor: const Color(0xFF006B7A),
          headerForegroundColor: Colors.white,
          todayBackgroundColor: const WidgetStatePropertyAll(Color(0x14006B7A)),
          todayForegroundColor: const WidgetStatePropertyAll(Color(0xFF006B7A)),
          dayOverlayColor: const WidgetStatePropertyAll(Color(0x14006B7A)),
        ),
      ),
      child: child!,
    ),
  );
}
