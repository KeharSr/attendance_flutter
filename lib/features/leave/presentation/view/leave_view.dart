import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/edit_leave_dialog.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _editLeave(LeaveEntity request) {
    if (ref.read(leaveViewModelProvider).isLoading) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditLeaveDialog(request: request),
    );
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
        AppSnackBar.success(context, next.successMessage!);
        if (next.successMessage == 'Leave request submitted for review.') {
          _formKey.currentState?.reset();
          _reasonController.clear();
          ref.read(leaveViewModelProvider.notifier).clearSelectedDates();
        }
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    return RequestTabs(
      onHistory: () {
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
      request: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const RequestIntro(
            'Request leave',
            'Choose your dates and provide a reason for your time off.',
          ),
          RequestFormCard(
            formKey: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDateField(
                  label: 'Start date',
                  date: state.startDate,
                  onTap: () async {
                    if (state.isLoading) return;
                    final date = await showAppDatePicker(
                      context,
                      selectedDate: state.startDate,
                      helpText: 'Select start date',
                    );
                    if (date != null && mounted) {
                      ref
                          .read(leaveViewModelProvider.notifier)
                          .setStartDate(date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                AppDateField(
                  label: 'End date',
                  date: state.endDate,
                  onTap: () async {
                    if (state.isLoading) return;
                    final date = await showAppDatePicker(
                      context,
                      selectedDate: state.endDate ?? state.startDate,
                      firstDate: state.startDate,
                      helpText: 'Select end date',
                    );
                    if (date != null && mounted) {
                      ref
                          .read(leaveViewModelProvider.notifier)
                          .setEndDate(date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                const RequestLabel('Reason', newText: '*'),
                TextFormField(
                  controller: _reasonController,
                  enabled: !state.isLoading,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: requestInk,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  decoration: requestInput('Briefly explain your request'),
                  validator: (value) => (value?.trim().length ?? 0) < 5
                      ? 'Please provide a little more detail.'
                      : null,
                ),
                const SizedBox(height: 26),
                RequestSubmitButton(
                  loading: state.isLoading,
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (state.startDate == null || state.endDate == null) {
                      AppSnackBar.error(
                        context,
                        'Select a start date and end date.',
                      );
                      return;
                    }
                    if (state.endDate!.isBefore(state.startDate!)) {
                      AppSnackBar.error(
                        context,
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
