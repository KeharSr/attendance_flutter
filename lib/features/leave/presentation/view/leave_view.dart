import 'package:attendance_flutter/core/common/request_list_page.dart';
import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';

import 'edit_leave_view.dart';
import '../widgets/leave_request_form.dart';

import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveView extends ConsumerStatefulWidget {
  const LeaveView({super.key});
  @override
  ConsumerState<LeaveView> createState() => _LeaveViewState();
}

class _LeaveViewState extends ConsumerState<LeaveView> {
  bool _editing = false;
  final _pageKey = GlobalKey<RequestListPageState>();
  BuildContext get _feedbackContext =>
      _pageKey.currentState?.feedbackContext ?? context;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _editLeave(LeaveEntity request) async {
    if (ref.read(leaveViewModelProvider).isLoading) return;
    _editing = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => EditLeaveView(request: request)),
      );
    } finally {
      _editing = false;
    }
  }

  Future<void> _deleteLeave(LeaveEntity request) async {
    if (ref.read(leaveViewModelProvider).isLoading) return;
    final confirmed = await showDeleteRequestDialog(
      context,
      title: 'Delete leave request?',
    );
    if (!confirmed || !mounted) return;
    await ref
        .read(leaveViewModelProvider.notifier)
        .deleteLeave(leaveRequestId: request.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveViewModelProvider);
    ref.listen(leaveViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(_feedbackContext, next.successMessage!);
        if (next.successMessage == 'Leave request submitted for review.') {
          _pageKey.currentState?.showHistory();
          _formKey.currentState?.reset();
          _reasonController.clear();
          ref.read(leaveViewModelProvider.notifier).clearSelectedDates();
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
      addLabel: 'Add leave request',
      loading: state.isLoading,
      onLoad: () {
        if (!state.isLoading) {
          ref.read(leaveViewModelProvider.notifier).getAllLeaves();
        }
      },
      history: LeaveHistoryView(
        onEdit: _editLeave,
        onDelete: _deleteLeave,
        requests: state.requests,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
        onRefresh: () =>
            ref.read(leaveViewModelProvider.notifier).getAllLeaves(),
      ),
      request: LeaveRequestForm(
        formKey: _formKey,
        reasonController: _reasonController,
        startDate: state.startDate,
        endDate: state.endDate,
        loading: state.isLoading,
        onSubmit: _submit,
        onStartDateChanged: (date) =>
            ref.read(leaveViewModelProvider.notifier).setStartDate(date),
        onEndDateChanged: (date) =>
            ref.read(leaveViewModelProvider.notifier).setEndDate(date),
      ),
    );
  }

  void _submit() {
    final state = ref.read(leaveViewModelProvider);
    if (state.isLoading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (state.startDate == null || state.endDate == null) {
      AppSnackBar.error(_feedbackContext, 'Select a start date and end date.');
      return;
    }
    if (state.endDate!.isBefore(state.startDate!)) {
      AppSnackBar.error(
        _feedbackContext,
        'End date must be on or after start date.',
      );
      return;
    }
    ref
        .read(leaveViewModelProvider.notifier)
        .submitLeave(
          startDate: state.startDate!,
          endDate: state.endDate!,
          reason: _reasonController.text.trim(),
        );
  }
}
