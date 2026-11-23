import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/compact_request_card.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';

class LeaveHistoryCardWidget extends StatelessWidget {
  const LeaveHistoryCardWidget({
    required this.request,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final LeaveEntity request;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;
  @override
  Widget build(BuildContext context) {
    return CompactRequestCard(
      title: styledRequestDate(request.startDate.toIso8601String()),
      reason: request.reason,
      status: request.status,
      icon: LucideIcons.calendarCheck,
      onView: onView,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
      details: [
        CompactRequestInfo(
          'To ${styledRequestDate(request.endDate.toIso8601String())}',
          icon: LucideIcons.calendar,
        ),
        CompactRequestInfo(
          leaveDaysLabel(request.startDate, request.endDate),
          emphasis: true,
          color: AppColors.ink,
        ),
      ],
    );
  }
}
