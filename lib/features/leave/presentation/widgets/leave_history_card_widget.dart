import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:flutter/material.dart';

class LeaveHistoryCardWidget extends StatelessWidget {
  const LeaveHistoryCardWidget({
    required this.request,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final LeaveEntity request;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool actionsEnabled;
  @override
  Widget build(BuildContext context) {
    return RequestHistoryTile(
      typeLabel: 'Leave request',
      icon: LucideIcons.calendarCheck,
      title: DateTimeUtils.formatDate(request.startDate),
      detail: 'Leave request',
      startLabel: 'From',
      endLabel: 'To',
      startValue: DateTimeUtils.formatDate(request.startDate),
      endValue: DateTimeUtils.formatDate(request.endDate),
      reason: request.reason,
      status: request.status,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
    );
  }
}
