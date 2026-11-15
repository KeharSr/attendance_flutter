import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';

class LeaveHistoryCardWidget extends StatelessWidget {
  const LeaveHistoryCardWidget({
    required this.request,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final LeaveEntity request;
  final VoidCallback? onEdit, onDelete;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) => StyledRequestCard(
    title: styledRequestDate(request.startDate.toIso8601String()),
    reason: request.reason,
    status: request.status,
    icon: LucideIcons.calendarCheck,
    onEdit: onEdit,
    onDelete: onDelete,
    actionsEnabled: actionsEnabled,
    metrics: RequestMetricPair(
      first: RequestMetric(
        label: 'From',
        value: styledRequestDate(request.startDate.toIso8601String()),
        icon: LucideIcons.calendar,
        boxed: false,
      ),
      second: RequestMetric(
        label: 'To',
        value: styledRequestDate(request.endDate.toIso8601String()),
        icon: LucideIcons.calendar,
        boxed: false,
      ),
    ),
    summary: RequestMetric(
      label: 'Requested Days',
      value: leaveDaysLabel(request.startDate, request.endDate),
      icon: LucideIcons.hourglass,
      boxed: false,
    ),
  );
}
