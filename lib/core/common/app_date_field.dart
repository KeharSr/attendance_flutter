import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-${date?.toIso8601String()}'),
      readOnly: true,
      onTap: onTap,
      initialValue: date == null ? null : DateTimeUtils.formatDate(date!),
      style: const TextStyle(
        color: Color(0xFF102A43),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select $label',
        prefixIcon: const Icon(
          Icons.calendar_today_rounded,
          color: Color(0xFF1769E0),
          size: 19,
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF667085),
        ),
      ),
    );
  }
}
