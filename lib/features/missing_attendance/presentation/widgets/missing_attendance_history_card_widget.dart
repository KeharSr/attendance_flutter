import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:flutter/material.dart';

class MissingAttendanceHistoryCardWidget extends StatelessWidget {
  const MissingAttendanceHistoryCardWidget({
    required this.request,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final MissingAttendanceEntity request;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool actionsEnabled;
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(request.missingDate);
    final checkIn = request.requestedCheckIn.isEmpty
        ? 'Not requested'
        : request.requestedCheckIn;
    final checkOut = request.requestCheckOut.isEmpty
        ? 'Not requested'
        : request.requestCheckOut;
    return RequestHistoryTile(
      title: date == null
          ? request.missingDate
          : DateTimeUtils.formatDate(date),
      detail: '$checkIn - $checkOut',
      reason: request.reason,
      status: request.status,
      onEdit: onEdit,
      onDelete: onDelete,
      actionsEnabled: actionsEnabled,
    );
  }
}
