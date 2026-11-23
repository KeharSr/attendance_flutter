import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/request_form_ui.dart';

class MissingAttendanceRequestForm extends StatelessWidget {
  const MissingAttendanceRequestForm({
    required this.formKey,
    required this.reasonController,
    required this.missingDate,
    required this.checkIn,
    required this.checkOut,
    required this.onDateSelected,
    required this.onCheckInSelected,
    required this.onCheckOutSelected,
    required this.loading,
    required this.onSubmit,
    this.editing = false,
    this.errorMessage,
    super.key,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final DateTime? missingDate;
  final TimeOfDay? checkIn, checkOut;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay?> onCheckInSelected, onCheckOutSelected;
  final bool loading, editing;
  final VoidCallback onSubmit;
  final String? errorMessage;
  @override
  Widget build(BuildContext context) => CleanRequestForm(
    title: editing ? 'Edit attendance report' : 'Report missing attendance',
    description: editing
        ? 'Update the date, corrected times and reason.'
        : 'Add the date and times that were not recorded.',
    formKey: formKey,
    loading: loading,
    editing: editing,
    onSubmit: onSubmit,
    errorMessage: errorMessage,
    fields: [
      AppDateField(
        label: 'Missing date',
        date: missingDate,
        enabled: !loading,
        onTap: () async {
          final date = await showAppDatePicker(
            context,
            selectedDate: missingDate,
            firstDate: editing ? DateTime(1900) : null,
            lastDate: DateTime.now(),
            helpText: 'Select missing date',
          );
          if (date != null && context.mounted) onDateSelected(date);
        },
      ),
      const SizedBox(height: 20),
      RequestFieldPair(
        first: RequestTimeField(
          label: 'Requested check-in',
          value: checkIn,
          enabled: !loading,
          clearable: editing,
          onChanged: onCheckInSelected,
        ),
        second: RequestTimeField(
          label: 'Requested check-out',
          value: checkOut,
          enabled: !loading,
          clearable: editing,
          initialTime: const TimeOfDay(hour: 17, minute: 0),
          onChanged: onCheckOutSelected,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        editing
            ? 'Provide at least one time. Check-out must be after check-in.'
            : 'Check-out must be after check-in on the same day.',
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 20),
      RequestReasonField(
        controller: reasonController,
        enabled: !loading,
        hint: 'Briefly explain the missing entry',
      ),
    ],
  );
}
