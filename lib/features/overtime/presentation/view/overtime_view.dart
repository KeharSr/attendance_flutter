import 'package:attendance_flutter/core/common/request_list_page.dart';
import 'package:attendance_flutter/core/common/request_history_filters.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';

import 'edit_overtime_view.dart';
import '../widgets/overtime_request_form.dart';

import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OvertimeView extends ConsumerStatefulWidget {
  const OvertimeView({super.key});

  @override
  ConsumerState<OvertimeView> createState() => _OvertimeViewState();
}

class _OvertimeViewState extends ConsumerState<OvertimeView> {
  bool _editing = false;
  final _pageKey = GlobalKey<RequestListPageState>();
  BuildContext get _feedbackContext =>
      _pageKey.currentState?.feedbackContext ?? context;
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overtimeState = ref.watch(overtimeViewModelProvider);
    ref.listen(overtimeViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(_feedbackContext, next.successMessage!);
        if (next.successMessage == 'Overtime request submitted for review.') {
          _pageKey.currentState?.showHistory();
          _formKey.currentState?.reset();
          _startTimeController.clear();
          _endTimeController.clear();
          _reasonController.clear();
          ref.read(overtimeViewModelProvider.notifier).clearWorkDate();
        }
      }
      if (!_editing &&
          previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(_feedbackContext, next.errorMessage!);
      }
    });

    return RequestListPage(
      key: _pageKey,
      addLabel: 'Add overtime request',
      loading: overtimeState.isLoading,
      onLoad: () {
        if (!overtimeState.isLoading) {
          ref.read(overtimeViewModelProvider.notifier).getAllOvertimeRequest();
        }
      },
      request: OvertimeRequestForm(
        workDate: overtimeState.workDate,
        onDateChanged: (date) =>
            ref.read(overtimeViewModelProvider.notifier).setWorkDate(date),
        isLoading: overtimeState.isLoading,
        lastDate: DateTime.now(),
        formKey: _formKey,
        startTimeController: _startTimeController,
        endTimeController: _endTimeController,
        reasonController: _reasonController,
        onSubmit: _submit,
      ),
      history: OvertimeHistoryView(
        summary: overtimeState.summary,
        filters: RequestHistoryFilters(
          keyPrefix: 'overtime',
          year: overtimeState.selectedYear,
          month: overtimeState.selectedMonth,
          loading: overtimeState.isLoading,
          onYearChanged: (year) =>
              ref.read(overtimeViewModelProvider.notifier).selectYear(year),
          onMonthChanged: (month) =>
              ref.read(overtimeViewModelProvider.notifier).selectMonth(month),
        ),
        requests: overtimeState.overtime,
        isLoading: overtimeState.isLoading,
        errorMessage: overtimeState.errorMessage,
        onRefresh: () => ref
            .read(overtimeViewModelProvider.notifier)
            .getAllOvertimeRequest(),
        onEdit: _editOvertime,
        onDelete: _deleteOvertime,
      ),
    );
  }

  Future<void> _editOvertime(OvertimeEntity request) async {
    _editing = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => EditOvertimeView(request: request)),
      );
    } finally {
      _editing = false;
    }
  }

  Future<void> _deleteOvertime(OvertimeEntity request) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete overtime request?'),
        content: const Text(
          'This pending request will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBD5D63),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await ref
        .read(overtimeViewModelProvider.notifier)
        .deleteOvertime(overtimeId: request.id.toString());
  }

  void _submit() {
    if (ref.read(overtimeViewModelProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(overtimeViewModelProvider.notifier)
        .createOvertimeRequest(
          workDate: DateTimeUtils.dateOnly(
            ref.read(overtimeViewModelProvider).workDate!,
          ),
          overtimeStartTime: _startTimeController.text,
          overtimeEndTime: _endTimeController.text,
          reason: _reasonController.text.trim(),
        );
  }
}
