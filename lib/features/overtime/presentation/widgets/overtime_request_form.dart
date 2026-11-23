import 'package:attendance_flutter/core/common/request_form_ui.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';

class OvertimeRequestForm extends StatelessWidget {
  const OvertimeRequestForm({
    required this.workDate,
    required this.onDateChanged,
    required this.isLoading,
    this.editing = false,
    this.firstDate,
    this.lastDate,
    super.key,
    required this.formKey,
    required this.startTimeController,
    required this.endTimeController,
    required this.reasonController,
    required this.onSubmit,
  });

  final DateTime? workDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isLoading, editing;
  final DateTime? firstDate, lastDate;
  final GlobalKey<FormState> formKey;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController reasonController;
  final VoidCallback onSubmit;

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final parts = controller.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
        : TimeOfDay.now();
    final selected = await showTimePicker(
      switchToInputEntryModeIcon: const Icon(LucideIcons.keyboard),
      switchToTimerEntryModeIcon: const Icon(LucideIcons.clock),
      context: context,
      initialTime: initial,
    );
    if (selected != null && context.mounted) {
      controller.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    }
  }

  InputDecoration _input(String hint, {IconData? icon}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFFD0D5DD)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      suffixIcon: icon == null
          ? null
          : Icon(icon, size: 18, color: AppColors.muted),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      errorMaxLines: 3,
    );
  }

  Widget _timeField(BuildContext context, {required bool start}) {
    final controller = start ? startTimeController : endTimeController;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(start ? 'Start time' : 'End time'),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: !isLoading,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          decoration: _input('Select time', icon: LucideIcons.clock),
          onTap: () => _pickTime(context, controller),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return start
                  ? 'Select an overtime start time.'
                  : 'Select an overtime end time.';
            }
            if (!start &&
                startTimeController.text.isNotEmpty &&
                value.compareTo(startTimeController.text) <= 0) {
              return 'End time must be later than start time.';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Text(
          editing ? 'Edit overtime' : 'Request overtime',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          editing
              ? 'Update your work date, extra hours and reason.'
              : 'Add your work date, extra hours and a brief reason.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FormLabel('Work date'),
              TextFormField(
                key: ValueKey(workDate),
                readOnly: true,
                enabled: !isLoading,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                initialValue: workDate == null
                    ? ''
                    : DateTimeUtils.formatDate(workDate!),
                decoration: _input(
                  'Select work date',
                  icon: LucideIcons.calendar,
                ),
                validator: (_) =>
                    workDate == null ? 'Select a work date.' : null,
                onTap: () async {
                  final date = await showAppDatePicker(
                    context,
                    selectedDate: workDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    helpText: 'Select work date',
                  );
                  if (date != null && context.mounted) {
                    onDateChanged(date);
                  }
                },
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final start = _timeField(context, start: true);
                  final end = _timeField(context, start: false);
                  if (constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(13) > 18) {
                    return Column(
                      children: [start, const SizedBox(height: 16), end],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: start),
                      const SizedBox(width: 12),
                      Expanded(child: end),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Start and end times must be on the same day.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              const RequestFieldLabel(
                'Reason for overtime',
                requiredField: true,
              ),
              TextFormField(
                controller: reasonController,
                enabled: !isLoading,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: _input('What did you work on?'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add a reason.';
                  }
                  return value.trim().length < 5
                      ? 'Please provide a little more detail.'
                      : null;
                },
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: isLoading
                      ? const AppLoadingIndicator(size: 16, strokeWidth: 2)
                      : Icon(
                          editing ? LucideIcons.check : LucideIcons.send,
                          size: 16,
                        ),
                  label: Text(
                    isLoading
                        ? (editing ? 'Saving...' : 'Submitting...')
                        : (editing ? 'Save changes' : 'Submit request'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
