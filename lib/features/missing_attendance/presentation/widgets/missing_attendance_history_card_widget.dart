import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';

class MissingAttendanceHistoryCardWidget extends StatelessWidget {
  const MissingAttendanceHistoryCardWidget({
    required this.request,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final MissingAttendanceEntity request;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final corrections = [
      request.requestedCheckIn,
      request.requestCheckOut,
    ].where((time) => time.trim().isNotEmpty).length;
    return StyledRequestCard(
      title: styledRequestDate(request.missingDate),
      reason: request.reason,
      status: request.status,
      icon: LucideIcons.clipboardClock,
      onView: onView,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
      metrics: RequestMetricPair(
        first: RequestMetric(
          label: 'Check-in',
          value: requestDisplayTime(request.requestedCheckIn),
          icon: LucideIcons.clock,
          boxed: false,
        ),
        second: RequestMetric(
          label: 'Check-out',
          value: requestDisplayTime(request.requestCheckOut),
          icon: LucideIcons.clock,
          boxed: false,
        ),
      ),
      summary: RequestMetric(
        label: 'Requested Corrections',
        value: '$corrections ${corrections == 1 ? 'update' : 'updates'}',
        icon: LucideIcons.clipboardClock,
        boxed: false,
      ),
    );
  }
}
