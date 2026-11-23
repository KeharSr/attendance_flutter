import 'package:attendance_flutter/core/common/app_top_bar.dart';

import '../widgets/leave_request_form.dart';

import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLeaveView extends ConsumerStatefulWidget {
  const EditLeaveView({required this.request, super.key});
  final LeaveEntity request;
  @override
  ConsumerState<EditLeaveView> createState() => _EditLeaveViewState();
}

class _EditLeaveViewState extends ConsumerState<EditLeaveView> {
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
    return PopScope(
      canPop: !state.isLoading,
      child: Scaffold(
        appBar: const AppTopBar(
          title: 'Leave',
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
                child: LeaveRequestForm(
                  editing: true,
                  formKey: _formKey,
                  reasonController: _reasonController,
                  loading: state.isLoading,
                  onSubmit: _save,
                  errorMessage:
                      _validationError ??
                      (_submitted ? state.errorMessage : null),
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartDateChanged: (date) => setState(() {
                    _startDate = date;
                    if (_endDate.isBefore(date)) _endDate = date;
                    _validationError = null;
                  }),
                  onEndDateChanged: (date) => setState(() {
                    _endDate = date;
                    _validationError = null;
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
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
