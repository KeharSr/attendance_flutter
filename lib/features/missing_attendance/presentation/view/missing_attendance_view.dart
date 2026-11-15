import 'package:attendance_flutter/core/common/request_list_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/widgets/edit_missing_attendance_dialog.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_history_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/state/missing_attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissingAttendanceView extends ConsumerStatefulWidget {
  const MissingAttendanceView({super.key});

  @override
  ConsumerState<MissingAttendanceView> createState() =>
      _MissingAttendanceViewState();
}

class _MissingAttendanceViewState extends ConsumerState<MissingAttendanceView> {
  final _pageKey = GlobalKey<RequestListPageState>();
  BuildContext get _feedbackContext =>
      _pageKey.currentState?.feedbackContext ?? context;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _missingDate;
  TimeOfDay? _checkIn;
  TimeOfDay? _checkOut;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _editMissingAttendance(MissingAttendanceEntity request) {
    if (ref.read(missingAttendanceViewModelProvider).isLoading) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditMissingAttendanceDialog(request: request),
    );
  }

  Future<void> _deleteMissingAttendance(MissingAttendanceEntity request) async {
    if (ref.read(missingAttendanceViewModelProvider).isLoading) return;
    final confirmed = await showDeleteRequestDialog(
      context,
      title: 'Delete attendance report?',
    );
    if (!confirmed || !mounted) return;
    await ref
        .read(missingAttendanceViewModelProvider.notifier)
        .deleteMissingAttendance(requestId: request.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missingAttendanceViewModelProvider);
    ref.listen(missingAttendanceViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(_feedbackContext, next.successMessage!);
        if (next.successMessage == 'Missing Attendance Created Successfully') {
          _pageKey.currentState?.showHistory();
          _formKey.currentState?.reset();
          _reasonController.clear();
          setState(() {
            _missingDate = null;
            _checkIn = null;
            _checkOut = null;
          });
        }
      }
      if (previous?.failureMessage != next.failureMessage &&
          next.failureMessage != null) {
        AppSnackBar.error(_feedbackContext, next.failureMessage!);
      }
    });

    return RequestListPage(
      key: _pageKey,
      addLabel: 'Add missing attendance request',
      loading: state.isLoading,
      onLoad: () {
        if (!state.isLoading) {
          ref
              .read(missingAttendanceViewModelProvider.notifier)
              .fetchMissingAttendance();
        }
      },
      request: _ReportForm(
        state: state,
        formKey: _formKey,
        reasonController: _reasonController,
        missingDate: _missingDate,
        checkIn: _checkIn,
        checkOut: _checkOut,
        onDateSelected: (date) => setState(() => _missingDate = date),
        onCheckInSelected: (time) => setState(() => _checkIn = time),
        onCheckOutSelected: (time) => setState(() => _checkOut = time),
        onSubmit: _submit,
      ),
      history: MissingAttendanceHistoryView(
        onEdit: _editMissingAttendance,
        onDelete: _deleteMissingAttendance,
        requests: state.missingAttendance,
        isLoading: state.isLoading,
        errorMessage: state.failureMessage,
        onRefresh: () => ref
            .read(missingAttendanceViewModelProvider.notifier)
            .fetchMissingAttendance(),
      ),
    );
  }

  void _submit() {
    if (ref.read(missingAttendanceViewModelProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_missingDate == null || _checkIn == null || _checkOut == null) {
      AppSnackBar.error(
        _feedbackContext,
        'Select the date, check-in, and check-out.',
      );
      return;
    }
    if (DateUtils.dateOnly(_missingDate!)
        .isAfter(DateUtils.dateOnly(DateTime.now()))) {
      AppSnackBar.error(
        _feedbackContext,
        'Missing date cannot be in the future.',
      );
      return;
    }
    if (_toMinutes(_checkOut!) <= _toMinutes(_checkIn!)) {
      AppSnackBar.error(_feedbackContext, 'Check-out must be after check-in.');
      return;
    }

    ref
        .read(missingAttendanceViewModelProvider.notifier)
        .createMissingAttendance(
          missingDate: DateTimeUtils.dateOnly(_missingDate!),
          requestedCheckIn: _formatTime(_checkIn!),
          requestedCheckOut: _formatTime(_checkOut!),
          reason: _reasonController.text.trim(),
        );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;
}

class _ReportForm extends StatelessWidget {
  const _ReportForm({
    required this.state,
    required this.formKey,
    required this.reasonController,
    required this.missingDate,
    required this.checkIn,
    required this.checkOut,
    required this.onDateSelected,
    required this.onCheckInSelected,
    required this.onCheckOutSelected,
    required this.onSubmit,
  });

  final MissingAttendanceState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final DateTime? missingDate;
  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onCheckInSelected;
  final ValueChanged<TimeOfDay> onCheckOutSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const RequestIntro(
          'Report missing attendance',
          'Submit a correction for an unrecorded attendance entry.',
        ),
        RequestFormCard(
          formKey: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDateField(
                label: 'Missing date',
                date: missingDate,
                onTap: () async {
                  final date = await showAppDatePicker(
                    context,
                    selectedDate: missingDate,
                    lastDate: DateTime.now(),
                    helpText: 'Select missing date',
                  );
                  if (date != null && context.mounted) onDateSelected(date);
                },
              ),
              const SizedBox(height: 18),
              _TimeField(
                label: 'Requested check-in',
                value: checkIn,
                onTap: () async {
                  final time = await showTimePicker(
                    switchToInputEntryModeIcon: const Icon(
                      LucideIcons.keyboard,
                    ),
                    switchToTimerEntryModeIcon: const Icon(LucideIcons.clock),
                    context: context,
                    initialTime: checkIn ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null && context.mounted) onCheckInSelected(time);
                },
              ),
              const SizedBox(height: 18),
              _TimeField(
                label: 'Requested check-out',
                value: checkOut,
                onTap: () async {
                  final time = await showTimePicker(
                    switchToInputEntryModeIcon: const Icon(
                      LucideIcons.keyboard,
                    ),
                    switchToTimerEntryModeIcon: const Icon(LucideIcons.clock),
                    context: context,
                    initialTime:
                        checkOut ?? const TimeOfDay(hour: 17, minute: 0),
                  );
                  if (time != null && context.mounted) onCheckOutSelected(time);
                },
              ),
              const SizedBox(height: 18),
              const RequestLabel('Reason', newText: "*"),
              TextFormField(
                enabled: !state.isLoading,
                controller: reasonController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: requestInput('Briefly explain the missing entry'),
                style: const TextStyle(
                  color: requestInk,
                  fontSize: 14,
                  height: 1.6,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add a reason.';
                  }
                  if (value.trim().length < 5) {
                    return 'Please provide a little more detail.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 26),
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequestLabel(label),
        TextFormField(
          key: ValueKey('$label-${value?.hour}:${value?.minute}'),
          readOnly: true,
          onTap: onTap,
          initialValue: value?.format(context),
          style: const TextStyle(color: requestInk, fontSize: 14),
          decoration: requestInput('Select time', icon: LucideIcons.clock)
              .copyWith(
                suffixIcon: const Icon(
                  LucideIcons.chevronDown,
                  color: requestMuted,
                ),
              ),
        ),
      ],
    );
  }
}
