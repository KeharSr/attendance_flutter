import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveViewModelProvider);
    ref.listen(leaveViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(context, next.successMessage!);
        _formKey.currentState?.reset();
        _reasonController.clear();
        ref.read(leaveViewModelProvider.notifier).clearSelectedDates();
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
              indicatorPadding: EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Color(0xFF1769E0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFF344054),
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Apply leave'),
                Tab(text: 'Leave history'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    const Text(
                      'Apply leave',
                      style: TextStyle(
                        color: Color(0xFF102A43),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose your dates and tell us why you need time off.',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                    ),
                    const SizedBox(height: 22),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppDateField(
                            label: 'Start date',
                            date: leaveState.startDate,
                            onTap: () async {
                              final date = await showAppDatePicker(
                                context,
                                selectedDate: leaveState.startDate,
                                helpText: 'Select start date',
                              );
                              if (date != null && mounted) {
                                ref
                                    .read(leaveViewModelProvider.notifier)
                                    .setStartDate(date);
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          AppDateField(
                            label: 'End date',
                            date: leaveState.endDate,
                            onTap: () async {
                              final date = await showAppDatePicker(
                                context,
                                selectedDate:
                                    leaveState.endDate ?? leaveState.startDate,
                                firstDate: leaveState.startDate,
                                helpText: 'Select end date',
                              );
                              if (date != null && mounted) {
                                ref
                                    .read(leaveViewModelProvider.notifier)
                                    .setEndDate(date);
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Reason',
                            style: const TextStyle(
                              color: Color(0xFF344054),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _reasonController,
                            minLines: 5,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Write here',
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.fromLTRB(
                                14,
                                15,
                                14,
                                15,
                              ),
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
                              onPressed: leaveState.isLoading
                                  ? null
                                  : () {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }
                                      if (leaveState.startDate == null ||
                                          leaveState.endDate == null) {
                                        AppSnackBar.error(
                                          context,
                                          'Select a start date and end date.',
                                        );
                                        return;
                                      }
                                      ref
                                          .read(leaveViewModelProvider.notifier)
                                          .submitLeave(
                                            startDate: leaveState.startDate!,
                                            endDate: leaveState.endDate!,
                                            reason: _reasonController.text
                                                .trim(),
                                          );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1769E0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: leaveState.isLoading
                                  ? AppLoadingIndicator()
                                  : const Text('Apply for leave'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                LeaveHistoryView(
                  requests: leaveState.requests,
                  isLoading: leaveState.isLoading,
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
      ref.read(leaveViewModelProvider.notifier).getAllLeaves();
    }
  }
}
