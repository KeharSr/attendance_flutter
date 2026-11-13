import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';

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
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool actionsEnabled;
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(request.missingDate);
    final checkIn = request.requestedCheckIn.isEmpty
        ? 'Not requested'
        : requestDisplayTime(request.requestedCheckIn);
    final checkOut = request.requestCheckOut.isEmpty
        ? 'Not requested'
        : requestDisplayTime(request.requestCheckOut);
    return RequestHistoryTile(
      typeLabel: 'Missing attendance',
      icon: Icons.pending_actions_rounded,
      title: date == null
          ? request.missingDate
          : DateTimeUtils.formatDate(date),
      detail:
          'Attendance ${date == null ? request.missingDate : DateTimeUtils.formatDate(date)}',
      startLabel: 'Check-in',
      endLabel: 'Check-out',
      startValue: checkIn,
      endValue: checkOut,
      reason: request.reason,
      status: request.status,
      // onView: onView,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
    );
  }
}
