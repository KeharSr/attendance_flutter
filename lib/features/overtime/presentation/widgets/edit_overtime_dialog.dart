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
  late final TextEditingController _hoursController;
  late final TextEditingController _reasonController;
  late DateTime _workDate;

  @override
  void initState() {
    super.initState();
    _workDate = DateTime.tryParse(widget.request.workDate) ?? DateTime.now();
    _hoursController = TextEditingController(
      text: widget.request.overtimeHours.toString(),
    );
    _reasonController = TextEditingController(text: widget.request.reason);
  }

  @override
  void dispose() {
    _hoursController.dispose();
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
              const RequestLabel('Extra hours'),
              TextFormField(
                controller: _hoursController,
                enabled: !isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: requestInput('e.g. 2.5', suffix: 'hours'),
                validator: (value) {
                  final hours = double.tryParse(value?.trim() ?? '');
                  return hours == null || !hours.isFinite || hours <= 0
                      ? 'Enter a duration greater than zero.'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              const RequestLabel('Reason for overtime'),
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final hours = double.parse(_hoursController.text.trim());
    ref.read(overtimeViewModelProvider.notifier).editOvertimeRequest(
      overtimeId: widget.request.id.toString(),
      workDate: DateTimeUtils.dateOnly(_workDate),
      overtimeHours: hours,
      reason: _reasonController.text.trim(),
    );
  }
}
