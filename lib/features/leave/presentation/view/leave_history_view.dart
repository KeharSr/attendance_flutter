import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/leave_history_card_widget.dart';
import 'package:flutter/material.dart';

class LeaveHistoryView extends StatelessWidget {
  const LeaveHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
  });
  final List<LeaveEntity> requests;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  @override
  Widget build(BuildContext context) => RequestHistoryList(
    count: requests.length,
    loading: isLoading,
    error: errorMessage,
    onRefresh: onRefresh,
    emptyText: 'No leave requests yet',
    itemBuilder: (_, index) => LeaveHistoryCardWidget(request: requests[index]),
  );
}
