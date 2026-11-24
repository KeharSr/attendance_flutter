import 'package:attendance_flutter/core/common/request_list_page.dart';
import 'package:attendance_flutter/core/common/request_history_filters.dart';
import 'package:attendance_flutter/core/common/request_dialogs.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';

import 'edit_missing_attendance_view.dart';
import '../widgets/missing_attendance_request_form.dart';

import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissingAttendanceView extends ConsumerStatefulWidget {
  const MissingAttendanceView({super.key});

  @override
  ConsumerState<MissingAttendanceView> createState() =>
      _MissingAttendanceViewState();
}

class _MissingAttendanceViewState extends ConsumerState<MissingAttendanceView> {
  bool _editing = false;
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

  Future<void> _editMissingAttendance(MissingAttendanceEntity request) async {
    if (ref.read(missingAttendanceViewModelProvider).isLoading) return;
    _editing = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => EditMissingAttendanceView(request: request),
        ),
      );
    } finally {
      _editing = false;
    }
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
      if (!_editing &&
          previous?.failureMessage != next.failureMessage &&
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
      request: MissingAttendanceRequestForm(
        loading: state.isLoading,
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
        summary: state.summary,
        filters: RequestHistoryFilters(
          keyPrefix: 'missing-attendance',
          year: state.selectedYear,
          month: state.selectedMonth,
          loading: state.isLoading,
          onYearChanged: (year) => ref
              .read(missingAttendanceViewModelProvider.notifier)
              .selectYear(year),
          onMonthChanged: (month) => ref
              .read(missingAttendanceViewModelProvider.notifier)
              .selectMonth(month),
        ),
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
