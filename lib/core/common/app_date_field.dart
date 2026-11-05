import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:flutter/material.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RequestLabel(label),
      TextFormField(
        key: ValueKey('$label-${date?.toIso8601String()}'),
        readOnly: true,
        enabled: enabled,
        onTap: onTap,
        initialValue: date == null ? null : DateTimeUtils.formatDate(date!),
        style: const TextStyle(color: requestInk, fontSize: 14),
        decoration:
            requestInput(
              'Select date',
              icon: Icons.calendar_today_outlined,
            ).copyWith(
              suffixIcon: const Icon(
                Icons.expand_more_rounded,
                color: requestMuted,
                size: 20,
              ),
            ),
      ),
    ],
  );
}
