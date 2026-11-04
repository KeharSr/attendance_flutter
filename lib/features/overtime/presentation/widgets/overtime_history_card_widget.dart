import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';

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
    final hours = request.overtimeHours
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return RequestHistoryTile(
      title: date == null ? request.workDate : DateTimeUtils.formatDate(date),
      detail: '$hours hours',
      reason: request.reason,
      status: request.status,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
