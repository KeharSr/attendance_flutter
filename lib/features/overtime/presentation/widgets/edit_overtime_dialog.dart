import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditOvertimeDialog extends ConsumerStatefulWidget {
  const EditOvertimeDialog({required this.request, super.key});

  final OvertimeEntity request;

  @override
  ConsumerState<EditOvertimeDialog> createState() => _EditOvertimeDialogState();
}

class _EditOvertimeDialogState extends ConsumerState<EditOvertimeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _reasonController;
  late DateTime _workDate;

  @override
  void initState() {
    super.initState();
    _workDate = DateTime.tryParse(widget.request.workDate) ?? DateTime.now();

    _startTimeController = TextEditingController(
      text: _initialTime(widget.request.overtimeStartTime),
    );
    _endTimeController = TextEditingController(
      text: _initialTime(widget.request.overtimeEndTime),
    );
    _reasonController = TextEditingController(text: widget.request.reason);
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(overtimeViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null &&
          context.mounted) {
        Navigator.pop(context);
      }
    });

    final isLoading = ref.watch(overtimeViewModelProvider).isLoading;
    return AlertDialog(
      title: const Text('Edit overtime'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RequestLabel('Work date'),
              TextFormField(
                key: ValueKey(_workDate),
                readOnly: true,
                enabled: !isLoading,
                initialValue: DateTimeUtils.formatDate(_workDate),
                decoration: requestInput(
                  'Choose a date',
                  icon: Icons.calendar_today_outlined,
                ),
                onTap: () async {
                  final date = await showAppDatePicker(
                    context,
                    selectedDate: _workDate,
                    firstDate: _workDate,
                    helpText: 'Select work date',
                  );
                  if (date != null && mounted) {
                    setState(() => _workDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              const RequestLabel('Overtime start time'),
              TextFormField(
                controller: _startTimeController,
                readOnly: true,
                enabled: !isLoading,
                decoration: requestInput(
                  'Choose start time',
                  icon: Icons.schedule_rounded,
                ),
                onTap: () => _pickTime(_startTimeController),
                validator: (value) => value == null || value.isEmpty
                    ? 'Select an overtime start time.'
                    : null,
              ),
              const SizedBox(height: 16),
              const RequestLabel('Overtime end time'),
              TextFormField(
                controller: _endTimeController,
                readOnly: true,
                enabled: !isLoading,
                decoration: requestInput(
                  'Choose end time',
                  icon: Icons.schedule_rounded,
                ),
                onTap: () => _pickTime(_endTimeController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select an overtime end time.';
                  }
                  if (_startTimeController.text.isNotEmpty &&
                      value.compareTo(_startTimeController.text) <= 0) {
                    return 'End time must be later than start time.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const RequestLabel('Reason for overtime', newText: "*"),
              TextFormField(
                controller: _reasonController,
                enabled: !isLoading,
                minLines: 3,
                maxLines: 6,
                decoration: requestInput('Briefly describe the work...'),
                validator: (value) => value == null || value.trim().length < 5
                    ? 'Please provide a little more detail.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save changes'),
        ),
      ],
    );
  }

  String _initialTime(String? value) {
    final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$')
        .firstMatch(value ?? '');
    if (match == null) return '';
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    return hour < 24 && minute < 60 ? '${match[1]}:${match[2]}' : '';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final selected = await showTimePicker(
      context: context,
      initialTime: parts.length == 2
          ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
          : TimeOfDay.now(),
    );
    if (selected != null && mounted) {
      controller.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(overtimeViewModelProvider.notifier)
        .editOvertimeRequest(
          overtimeId: widget.request.id.toString(),
          workDate: DateTimeUtils.dateOnly(_workDate),
          overtimeStartTime: _startTimeController.text,
          overtimeEndTime: _endTimeController.text,
          reason: _reasonController.text.trim(),
        );
  }
}
