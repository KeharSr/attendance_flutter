import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missingAttendanceViewModelProvider);
    ref.listen(missingAttendanceViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(context, next.successMessage!);
        _formKey.currentState?.reset();
        _reasonController.clear();
        setState(() {
          _missingDate = null;
          _checkIn = null;
          _checkOut = null;
        });
      }
      if (previous?.failureMessage != next.failureMessage &&
          next.failureMessage != null) {
        AppSnackBar.error(context, next.failureMessage!);
      }
    });

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEF9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              onTap: (index) {
                if (index == 1) {
                  ref
                      .read(missingAttendanceViewModelProvider.notifier)
                      .fetchMissingAttendance();
                }
              },
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              indicator: const BoxDecoration(
                color: Color(0xFF1769E0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFF344054),
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Report missing'),
                Tab(text: 'Report history'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ReportForm(
                  state: state,
                  formKey: _formKey,
                  reasonController: _reasonController,
                  missingDate: _missingDate,
                  checkIn: _checkIn,
                  checkOut: _checkOut,
                  onDateSelected: (date) => setState(() => _missingDate = date),
                  onCheckInSelected: (time) => setState(() => _checkIn = time),
                  onCheckOutSelected: (time) =>
                      setState(() => _checkOut = time),
                  onSubmit: _submit,
                ),
                MissingAttendanceHistoryView(
                  requests: state.missingAttendance,
                  isLoading: state.isLoading,
                  errorMessage: state.failureMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_missingDate == null || _checkIn == null || _checkOut == null) {
      AppSnackBar.error(context, 'Select the date, check-in, and check-out.');
      return;
    }
    if (_toMinutes(_checkOut!) <= _toMinutes(_checkIn!)) {
      AppSnackBar.error(context, 'Check-out must be after check-in.');
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
        const Text(
          'Report missing attendance',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tell us when you worked so your attendance can be corrected.',
          style: TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
        const SizedBox(height: 22),
        Form(
          key: formKey,
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
                    context: context,
                    initialTime:
                        checkOut ?? const TimeOfDay(hour: 17, minute: 0),
                  );
                  if (time != null && context.mounted) onCheckOutSelected(time);
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: reasonController,
                minLines: 5,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Write here',
                  alignLabelWithHint: true,
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: state.isLoading ? null : onSubmit,
                  child: state.isLoading
                      ? const AppLoadingIndicator(color: Colors.white)
                      : const Text('Submit missing attendance'),
                ),
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
    return TextFormField(
      key: ValueKey('$label-${value?.hour}:${value?.minute}'),
      readOnly: true,
      onTap: onTap,
      initialValue: value?.format(context),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select $label',
        prefixIcon: const Icon(
          Icons.schedule_rounded,
          color: Color(0xFF1769E0),
          size: 19,
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF667085),
        ),
      ),
    );
  }
}
