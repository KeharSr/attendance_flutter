import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/widgets/missing_attendance_history_card_widget.dart';
import 'package:flutter/material.dart';

class MissingAttendanceHistoryView extends StatelessWidget {
  const MissingAttendanceHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
  });
  final List<MissingAttendanceEntity> requests;
  final ValueChanged<MissingAttendanceEntity>? onEdit;
  final ValueChanged<MissingAttendanceEntity>? onDelete;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  @override
  Widget build(BuildContext context) => RequestHistoryList(
    count: requests.length,
    loading: isLoading,
    error: errorMessage,
    onRefresh: onRefresh,
    emptyText: 'No attendance reports yet',
    itemBuilder: (_, index) => MissingAttendanceHistoryCardWidget(
      request: requests[index],
      actionsEnabled: !isLoading,
      onEdit: onEdit == null ? null : () => onEdit!(requests[index]),
      onDelete: onDelete == null ? null : () => onDelete!(requests[index]),
    ),
  );
}
