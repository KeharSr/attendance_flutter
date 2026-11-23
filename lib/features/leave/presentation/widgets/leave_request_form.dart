import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/request_form_ui.dart';

class LeaveRequestForm extends StatelessWidget {
  const LeaveRequestForm({
    required this.formKey,
    required this.reasonController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.loading,
    required this.onSubmit,
    this.editing = false,
    this.errorMessage,
    super.key,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final DateTime? startDate, endDate;
  final ValueChanged<DateTime> onStartDateChanged, onEndDateChanged;
  final bool loading, editing;
  final VoidCallback onSubmit;
  final String? errorMessage;
  @override
  Widget build(BuildContext context) {
    final tomorrow = DateUtils.dateOnly(DateTime.now())
        .add(const Duration(days: 1));
    return CleanRequestForm(
      title: editing ? 'Edit leave request' : 'Request leave',
      description: editing
          ? 'Update your leave dates and reason.'
          : 'Choose your dates and tell us about your time off.',
      formKey: formKey,
      loading: loading,
      editing: editing,
      onSubmit: onSubmit,
      errorMessage: errorMessage,
      fields: [
        RequestFieldPair(
          first: AppDateField(
            label: 'Start date',
            date: startDate,
            enabled: !loading,
            onTap: () async {
              final date = await showAppDatePicker(
                context,
                selectedDate: startDate,
                firstDate: editing ? tomorrow : null,
                helpText: 'Select start date',
              );
              if (date != null && context.mounted) onStartDateChanged(date);
            },
          ),
          second: AppDateField(
            label: 'End date',
            date: endDate,
            enabled: !loading,
            onTap: () async {
              final minimum =
                  editing &&
                      (startDate == null || startDate!.isBefore(tomorrow))
                  ? tomorrow
                  : startDate;
              final date = await showAppDatePicker(
                context,
                selectedDate: endDate ?? startDate,
                firstDate: minimum,
                helpText: 'Select end date',
              );
              if (date != null && context.mounted) onEndDateChanged(date);
            },
          ),
        ),
        const SizedBox(height: 20),
        RequestReasonField(
          controller: reasonController,
          enabled: !loading,
          hint: 'Tell us the reason for your leave',
        ),
      ],
    );
  }
}
