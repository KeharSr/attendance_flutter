import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:flutter/material.dart';

class MissingAttendanceDetailView extends StatelessWidget {
  const MissingAttendanceDetailView({
    required this.requestId,
    required this.requests,
    super.key,
  });

  final String requestId;
  final List<MissingAttendanceEntity> requests;

  @override
  Widget build(BuildContext context) {
    MissingAttendanceEntity? request;
    for (final item in requests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }
    final report = request;
    return RequestDetailPage(
      title: 'Missing attendance',
      requestId: requestId.toString(),
      found: report != null,
      status: report?.status ?? '',
      icon: Icons.pending_actions_rounded,
      reason: report?.reason ?? '',
      rejectionReason: report?.rejectReason ?? 'This is rejected',
      fields: report == null
          ? []
          : [
              (
                label: 'Employee ID',
                value: '${report.userId}',
                icon: Icons.person_outline_rounded,
              ),
              (
                label: 'Attendance date',
                value: DateTime.tryParse(report.missingDate) == null
                    ? report.missingDate
                    : DateTimeUtils.formatDate(
                        DateTime.parse(report.missingDate),
                      ),
                icon: Icons.calendar_today_outlined,
              ),
              (
                label: 'Requested check-in',
                value: requestDisplayTime(report.requestedCheckIn),
                icon: Icons.schedule_rounded,
              ),
              (
                label: 'Requested check-out',
                value: requestDisplayTime(report.requestCheckOut),
                icon: Icons.schedule_rounded,
              ),
            ],
    );
  }
}
