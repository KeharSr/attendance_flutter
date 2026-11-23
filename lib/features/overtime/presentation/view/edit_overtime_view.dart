import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/overtime_request_form.dart';

class EditOvertimeView extends ConsumerStatefulWidget {
  const EditOvertimeView({required this.request, super.key});
  final OvertimeEntity request;

  @override
  ConsumerState<EditOvertimeView> createState() => _EditOvertimeViewState();
}

class _EditOvertimeViewState extends ConsumerState<EditOvertimeView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _reasonController;
  late final DateTime _originalDate;
  late DateTime _workDate;

  @override
  void initState() {
    super.initState();
    _originalDate =
        DateTime.tryParse(widget.request.workDate) ?? DateTime.now();
    _workDate = _originalDate;
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
          next.successMessage == 'Overtime edit successfully.') {
        AppSnackBar.hide(context);
        Navigator.of(context).pop();
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final isLoading = ref.watch(overtimeViewModelProvider).isLoading;
    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: const AppTopBar(
          title: 'Overtime',
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: OvertimeRequestForm(
                  editing: true,
                  workDate: _workDate,
                  firstDate: _originalDate,
                  onDateChanged: (date) => setState(() => _workDate = date),
                  isLoading: isLoading,
                  formKey: _formKey,
                  startTimeController: _startTimeController,
                  endTimeController: _endTimeController,
                  reasonController: _reasonController,
                  onSubmit: _submit,
                ),
              ),
            ),
          ),
        ),
      ),
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

  void _submit() {
    if (ref.read(overtimeViewModelProvider).isLoading ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    ref
        .read(overtimeViewModelProvider.notifier)
        .editOvertimeRequest(
          overtimeId: widget.request.id,
          workDate: DateTimeUtils.dateOnly(_workDate),
          overtimeStartTime: _startTimeController.text,
          overtimeEndTime: _endTimeController.text,
          reason: _reasonController.text.trim(),
        );
  }
}
