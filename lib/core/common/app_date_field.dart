import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';

import 'app_theme.dart';
import 'request_form_ui.dart';

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
      RequestFieldLabel(label),
      TextFormField(
        key: ValueKey('$label-${date?.toIso8601String()}'),
        readOnly: true,
        enabled: enabled,
        onTap: onTap,
        initialValue: date == null ? null : DateTimeUtils.formatDate(date!),
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        decoration: cleanRequestInput(
          'Select date',
          icon: LucideIcons.calendar,
        ),
      ),
    ],
  );
}
