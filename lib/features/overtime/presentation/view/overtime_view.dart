import 'package:attendance_flutter/core/common/request_list_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
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
      if (previous?.errorMessage != next.errorMessage &&
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
      request: _RequestForm(
        state: overtimeState,
        formKey: _formKey,
        startTimeController: _startTimeController,
        endTimeController: _endTimeController,
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

class _RequestForm extends ConsumerWidget {
  const _RequestForm({
    required this.state,
    required this.formKey,
    required this.startTimeController,
    required this.endTimeController,
    required this.reasonController,
    required this.onSubmit,
  });

  final OvertimeState state;
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
                decoration: requestInput(
                  'Choose a date',
                  icon: LucideIcons.calendar,
                ),
                validator: (_) =>
                    state.workDate == null ? 'Select a work date.' : null,
                onTap: () async {
                  final date = await showAppDatePicker(
                    context,
                    selectedDate: state.workDate,
                    lastDate: DateTime.now(),
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
              const RequestLabel('Overtime start time'),
              TextFormField(
                controller: startTimeController,
                readOnly: true,
                enabled: !state.isLoading,
                decoration: requestInput(
                  'Choose start time',
                  icon: LucideIcons.clock,
                ),
                onTap: () => _pickTime(context, startTimeController),
                validator: (value) => value == null || value.isEmpty
                    ? 'Select an overtime start time.'
                    : null,
              ),
              const SizedBox(height: 22),
              const RequestLabel('Overtime end time'),
              TextFormField(
                controller: endTimeController,
                readOnly: true,
                enabled: !state.isLoading,
                decoration: requestInput(
                  'Choose end time',
                  icon: LucideIcons.clock,
                ),
                onTap: () => _pickTime(context, endTimeController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select an overtime end time.';
                  }
                  if (startTimeController.text.isNotEmpty &&
                      value.compareTo(startTimeController.text) <= 0) {
                    return 'End time must be later than start time.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the start and end time for the same day.',
                style: TextStyle(
                  color: requestMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              const RequestLabel('Reason for overtime', newText: "*"),
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
