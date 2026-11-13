import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';

class OvertimeHistoryCardWidget extends StatelessWidget {
  const OvertimeHistoryCardWidget({
    required this.request,
    this.onEdit,
    this.onDelete,
    super.key,
  });
  final OvertimeEntity request;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(request.workDate);
    return RequestHistoryTile(
      typeLabel: 'Overtime request',
      icon: Icons.more_time_rounded,
      title: request.workDate.isEmpty
          ? 'Overtime request #${request.id}'
          : date == null
          ? request.workDate
          : DateTimeUtils.formatDate(date),
      detail:
          'Work date ${date == null ? request.workDate : DateTimeUtils.formatDate(date)}',
      startValue: requestDisplayTime(
        request.overtimeStartTime,
        fallback: 'Not provided',
      ),
      endValue: requestDisplayTime(
        request.overtimeEndTime,
        fallback: 'Not provided',
      ),
      durationLabel: requestDisplayDuration(
        request.overtimeStartTime,
        request.overtimeEndTime,
      ),
      reason: request.reason,
      status: request.status,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
