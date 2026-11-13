import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLeaveDialog extends ConsumerStatefulWidget {
  const EditLeaveDialog({required this.request, super.key});
  final LeaveEntity request;
  @override
  ConsumerState<EditLeaveDialog> createState() => _EditLeaveDialogState();
}

class _EditLeaveDialogState extends ConsumerState<EditLeaveDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _submitted = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _startDate = DateUtils.dateOnly(widget.request.startDate);
    _endDate = DateUtils.dateOnly(widget.request.endDate);
    _reasonController = TextEditingController(text: widget.request.reason);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveViewModelProvider);
    final tomorrow = DateUtils.dateOnly(DateTime.now())
        .add(const Duration(days: 1));
    return RequestEditDialog(
      title: 'Edit leave request',
      formKey: _formKey,
      loading: state.isLoading,
      onSave: _save,
      errorMessage:
          _validationError ?? (_submitted ? state.errorMessage : null),
      children: [
        AppDateField(
          label: 'Start date',
          date: _startDate,
          enabled: !state.isLoading,
          onTap: () async {
            final date = await showAppDatePicker(
              context,
              selectedDate: _startDate,
              firstDate: tomorrow,
              helpText: 'Select start date',
            );
            if (date == null || !mounted) return;
            setState(() {
              _startDate = date;
              if (_endDate.isBefore(date)) _endDate = date;
              _validationError = null;
            });
          },
        ),
        const SizedBox(height: 18),
        AppDateField(
          label: 'End date',
          date: _endDate,
          enabled: !state.isLoading,
          onTap: () async {
            final date = await showAppDatePicker(
              context,
              selectedDate: _endDate,
              firstDate: _startDate.isBefore(tomorrow) ? tomorrow : _startDate,
              helpText: 'Select end date',
            );
            if (date != null && mounted) {
              setState(() {
                _endDate = date;
                _validationError = null;
              });
            }
          },
        ),
        const SizedBox(height: 18),
        const RequestLabel('Reason', newText: '*'),
        TextFormField(
          controller: _reasonController,
          enabled: !state.isLoading,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: requestInput('Briefly explain your request'),
          validator: (value) => (value?.trim().length ?? 0) < 5
              ? 'Please provide a little more detail.'
              : null,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (ref.read(leaveViewModelProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_startDate.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      setState(() => _validationError = 'Start date must be after today.');
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      setState(
        () => _validationError = 'End date must be on or after start date.',
      );
      return;
    }
    setState(() {
      _submitted = true;
      _validationError = null;
    });
    final saved = await ref
        .read(leaveViewModelProvider.notifier)
        .editLeave(
          leaveRequestId: widget.request.id,
          startDate: _startDate,
          endDate: _endDate,
          reason: _reasonController.text.trim(),
        );
    if (saved && mounted) Navigator.pop(context);
  }
}
