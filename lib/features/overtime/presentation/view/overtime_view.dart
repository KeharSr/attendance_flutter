import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/widgets/edit_overtime_dialog.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OvertimeView extends ConsumerStatefulWidget {
  const OvertimeView({super.key});

  @override
  ConsumerState<OvertimeView> createState() => _OvertimeViewState();
}

class _OvertimeViewState extends ConsumerState<OvertimeView> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _hoursController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overtimeState = ref.watch(overtimeViewModelProvider);
    ref.listen(overtimeViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(context, next.successMessage!);
        if (next.successMessage == 'Overtime request submitted for review.') {
          _formKey.currentState?.reset();
          _hoursController.clear();
          _reasonController.clear();
          ref.read(overtimeViewModelProvider.notifier).clearWorkDate();
        }
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });

    return RequestTabs(
      onHistory: () {
        if (!overtimeState.isLoading) {
          ref.read(overtimeViewModelProvider.notifier).getAllOvertimeRequest();
        }
      },
      request: _RequestForm(
        state: overtimeState,
        formKey: _formKey,
        hoursController: _hoursController,
        reasonController: _reasonController,
        onSubmit: _submit,
      ),
      history: OvertimeHistoryView(
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

  void _editOvertime(OvertimeEntity request) {
    showDialog<void>(
      context: context,
      builder: (_) => EditOvertimeDialog(request: request),
    );
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
    final state = ref.read(overtimeViewModelProvider);
    if (state.workDate == null) {
      AppSnackBar.error(context, 'Select a work date.');
      return;
    }
    final hours = double.tryParse(_hoursController.text.trim());
    if (hours == null || !hours.isFinite || hours <= 0) {
      AppSnackBar.error(context, 'Enter a valid overtime duration.');
      return;
    }
    ref
        .read(overtimeViewModelProvider.notifier)
        .createOvertimeRequest(
          workDate: DateTimeUtils.dateOnly(state.workDate!),
          overtimeHours: hours,
          reason: _reasonController.text.trim(),
        );
  }
}

class _RequestForm extends ConsumerWidget {
  const _RequestForm({
    required this.state,
    required this.formKey,
    required this.hoursController,
    required this.reasonController,
    required this.onSubmit,
  });

  final OvertimeState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController hoursController;
  final TextEditingController reasonController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const RequestIntro(
          'Request overtime',
          'Record extra hours worked and submit them for approval.',
        ),
        RequestFormCard(
          formKey: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RequestLabel('Work date'),
              TextFormField(
                key: ValueKey(state.workDate),
                readOnly: true,
                enabled: !state.isLoading,
                initialValue: state.workDate == null
                    ? ''
                    : DateTimeUtils.formatDate(state.workDate!),
                style: const TextStyle(color: requestInk, fontSize: 14),
                decoration:
                    requestInput(
                      'Choose a date',
                      icon: Icons.calendar_today_outlined,
                    ).copyWith(
                      suffixIcon: const Icon(
                        Icons.expand_more_rounded,
                        color: requestMuted,
                        size: 20,
                      ),
                    ),
                validator: (_) =>
                    state.workDate == null ? 'Select a work date.' : null,
                onTap: () async {
                  final date = await showAppDatePicker(
                    context,
                    selectedDate: state.workDate,
                    helpText: 'Select work date',
                  );
                  if (date != null && context.mounted) {
                    ref
                        .read(overtimeViewModelProvider.notifier)
                        .setWorkDate(date);
                  }
                },
              ),
              const SizedBox(height: 22),
              const RequestLabel('Extra hours'),
              TextFormField(
                controller: hoursController,
                enabled: !state.isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: requestInk, fontSize: 14),
                decoration: requestInput(
                  'e.g. 2.5',
                  icon: Icons.schedule_rounded,
                  suffix: 'hours',
                ),
                validator: (value) {
                  final hours = double.tryParse(value?.trim() ?? '');
                  return hours == null || !hours.isFinite || hours <= 0
                      ? 'Enter a duration greater than zero.'
                      : null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Use decimals for partial hours: 1.5 = 1 hr 30 min.',
                style: TextStyle(
                  color: requestMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              const RequestLabel('Reason for overtime'),
              TextFormField(
                controller: reasonController,
                enabled: !state.isLoading,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: requestInk,
                  fontSize: 14,
                  height: 1.6,
                ),
                decoration: requestInput(
                  'Briefly describe the work you completed...',
                ),
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
              RequestSubmitButton(
                loading: state.isLoading,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
