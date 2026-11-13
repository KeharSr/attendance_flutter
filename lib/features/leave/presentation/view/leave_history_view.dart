import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/leave_history_card_widget.dart';
import 'package:flutter/material.dart';

import 'leave_detail_view.dart';

class LeaveHistoryView extends StatelessWidget {
  const LeaveHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
  });
  final List<LeaveEntity> requests;
  final ValueChanged<LeaveEntity>? onEdit;
  final ValueChanged<LeaveEntity>? onDelete;
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
    itemBuilder: (context, index) => GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LeaveDetailView(
            requestId: requests[index].id,
            requests: requests,
          ),
        ),
      ),
      child: LeaveHistoryCardWidget(
        request: requests[index],
        actionsEnabled: !isLoading,
        onEdit: onEdit == null ? null : () => onEdit!(requests[index]),
        onDelete: onDelete == null ? null : () => onDelete!(requests[index]),
      ),
    ),
  );
}
