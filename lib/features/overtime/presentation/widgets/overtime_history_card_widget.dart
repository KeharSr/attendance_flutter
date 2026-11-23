import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/compact_request_card.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';

import 'overtime_ui.dart';

class OvertimeHistoryCardWidget extends StatelessWidget {
  const OvertimeHistoryCardWidget({
    required this.request,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final OvertimeEntity request;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;
  @override
  Widget build(BuildContext context) {
    final accepted = overtimeHours(
      request.overtimeApproveStartTime,
      request.overtimeApproveEndTime,
      hours: request.overtimeAcceptedHours,
    );
    return CompactRequestCard(
      title: overtimeDate(request.workDate),
      reason: request.reason,
      status: request.status,
      icon: LucideIcons.calendarClock,
      onView: onView,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
      details: [
        CompactRequestInfo(
          overtimeRange(request.overtimeStartTime, request.overtimeEndTime),
          icon: LucideIcons.clock,
        ),
        CompactRequestInfo(
          overtimeHours(
            request.overtimeStartTime,
            request.overtimeEndTime,
            hours: request.overtimeRequestedHours,
          ),
          emphasis: true,
          color: AppColors.ink,
          semanticLabel: 'Requested hours',
        ),
        if (request.status.trim().toLowerCase() == 'approved' &&
            accepted != 'Not provided')
          CompactRequestInfo(
            accepted,
            icon: LucideIcons.circleCheck,
            color: AppColors.success,
            semanticLabel: 'Accepted hours',
          ),
      ],
    );
  }
}
