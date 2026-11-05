import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditMissingAttendanceDialog extends ConsumerStatefulWidget {
  const EditMissingAttendanceDialog({required this.request, super.key});
  final MissingAttendanceEntity request;
  @override
  ConsumerState<EditMissingAttendanceDialog> createState() =>
      _EditMissingAttendanceDialogState();
}

class _EditMissingAttendanceDialogState
    extends ConsumerState<EditMissingAttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  DateTime? _date;
  TimeOfDay? _checkIn;
  TimeOfDay? _checkOut;
  bool _submitted = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _date = DateTime.tryParse(widget.request.missingDate);
    _checkIn = _parseTime(widget.request.requestedCheckIn);
    _checkOut = _parseTime(widget.request.requestCheckOut);
    _reasonController = TextEditingController(text: widget.request.reason);
  }

  TimeOfDay? _parseTime(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    return hour < 24 && minute < 60
        ? TimeOfDay(hour: hour, minute: minute)
        : null;
  }

  String? _formatTime(TimeOfDay? value) => value == null
      ? null
      : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missingAttendanceViewModelProvider);
    return RequestEditDialog(
      title: 'Edit attendance report',
      formKey: _formKey,
      loading: state.isLoading,
      onSave: _save,
      errorMessage:
          _validationError ?? (_submitted ? state.failureMessage : null),
      children: [
        AppDateField(
          label: 'Missing date',
          date: _date,
          enabled: !state.isLoading,
          onTap: () async {
            final date = await showAppDatePicker(
              context,
              selectedDate: _date,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              helpText: 'Select missing date',
            );
            if (date != null && mounted) {
              setState(() {
                _date = date;
                _validationError = null;
              });
            }
          },
        ),
        const SizedBox(height: 18),
        _EditTimeField(
          label: 'Requested check-in',
          value: _checkIn,
          enabled: !state.isLoading,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
          onChanged: (time) => setState(() {
            _checkIn = time;
            _validationError = null;
          }),
        ),
        const SizedBox(height: 18),
        _EditTimeField(
          label: 'Requested check-out',
          value: _checkOut,
          enabled: !state.isLoading,
          initialTime: const TimeOfDay(hour: 17, minute: 0),
          onChanged: (time) => setState(() {
            _checkOut = time;
            _validationError = null;
          }),
        ),
        const SizedBox(height: 10),
        const Text(
          'Provide at least one time. Check-out must be after check-in.',
          style: TextStyle(color: requestMuted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 18),
        const RequestLabel('Reason'),
        TextFormField(
          controller: _reasonController,
          enabled: !state.isLoading,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: requestInput('Briefly explain the missing entry'),
          validator: (value) => (value?.trim().length ?? 0) < 5
              ? 'Please provide a little more detail.'
              : null,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (ref.read(missingAttendanceViewModelProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    String? error;
    if (_date == null) {
      error = 'Select the missing date.';
    } else if (DateUtils.dateOnly(_date!)
        .isAfter(DateUtils.dateOnly(DateTime.now()))) {
      error = 'Missing date cannot be in the future.';
    } else if (_checkIn == null && _checkOut == null) {
      error = 'Provide at least one check-in or check-out time.';
    } else if (_checkIn != null &&
        _checkOut != null &&
        _checkOut!.hour * 60 + _checkOut!.minute <=
            _checkIn!.hour * 60 + _checkIn!.minute) {
      error = 'Check-out must be after check-in.';
    }
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }
    setState(() {
      _submitted = true;
      _validationError = null;
    });
    final saved = await ref
        .read(missingAttendanceViewModelProvider.notifier)
        .editMissingAttendance(
          requestId: widget.request.id.toString(),
          missingDate: DateTimeUtils.dateOnly(_date!),
          requestedCheckIn: _formatTime(_checkIn),
          requestedCheckOut: _formatTime(_checkOut),
          reason: _reasonController.text.trim(),
        );
    if (saved && mounted) Navigator.pop(context);
  }
}

class _EditTimeField extends StatelessWidget {
  const _EditTimeField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.initialTime,
    required this.onChanged,
  });
  final String label;
  final TimeOfDay? value;
  final bool enabled;
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RequestLabel(label),
      TextFormField(
        key: ValueKey('$label-${value?.hour}:${value?.minute}'),
        readOnly: true,
        enabled: enabled,
        initialValue: value?.format(context),
        decoration: requestInput('Select time', icon: Icons.schedule_outlined)
            .copyWith(
              suffixIcon: value == null
                  ? const Icon(Icons.expand_more)
                  : IconButton(
                      tooltip: 'Clear $label',
                      onPressed: enabled ? () => onChanged(null) : null,
                      icon: const Icon(Icons.close, size: 18),
                    ),
            ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: value ?? initialTime,
          );
          if (time != null && context.mounted) onChanged(time);
        },
      ),
    ],
  );
}
