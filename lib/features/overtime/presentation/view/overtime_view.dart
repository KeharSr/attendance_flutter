import 'package:attendance_flutter/core/common/app_date_field.dart';
import 'package:attendance_flutter/core/common/app_date_picker.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';
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
        _formKey.currentState?.reset();
        _hoursController.clear();
        _reasonController.clear();
        ref.read(overtimeViewModelProvider.notifier).clearWorkDate();
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
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
              onTap: _handleTabChanged,
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
                Tab(text: 'Request overtime'),
                Tab(text: 'Overtime history'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RequestForm(
                  state: overtimeState,
                  formKey: _formKey,
                  hoursController: _hoursController,
                  reasonController: _reasonController,
                  onSubmit: _submit,
                ),
                OvertimeHistoryView(
                  requests: overtimeState.overtime,
                  isLoading: overtimeState.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabChanged(int index) {
    if (index == 1) {
      ref.read(overtimeViewModelProvider.notifier).getAllOvertimeRequest();
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = ref.read(overtimeViewModelProvider);
    if (state.workDate == null) {
      AppSnackBar.error(context, 'Select a work date.');
      return;
    }
    final hours = double.tryParse(_hoursController.text.trim());
    if (hours == null || hours <= 0) {
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const Text(
          'Request overtime',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add your extra working hours for manager approval.',
          style: TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
        const SizedBox(height: 22),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDateField(
                label: 'Work date',
                date: state.workDate,
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
              const SizedBox(height: 18),
              TextFormField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Overtime hours',
                  hintText: 'e.g. 2.5',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter overtime hours.'
                    : null,
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
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1769E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isLoading
                      ? AppLoadingIndicator()
                      : const Text('Submit overtime request'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
