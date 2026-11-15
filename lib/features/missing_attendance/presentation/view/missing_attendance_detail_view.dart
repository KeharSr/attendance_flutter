import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';

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
    MissingAttendanceEntity? report;
    for (final item in requests) {
      if (item.id == requestId) {
        report = item;
        break;
      }
    }
    final corrections = report == null
        ? 0
        : [
            report.requestedCheckIn,
            report.requestCheckOut,
          ].where((time) => time.trim().isNotEmpty).length;
    return StyledRequestDetail(
      title: 'Missing Attendance Details',
      found: report != null,
      status: report?.status ?? '',
      reason: report?.reason ?? '',
      rejectionReason: report?.rejectReason,
      dateLabel: 'Attendance Date',
      dateValue: styledRequestDate(report?.missingDate ?? ''),
      metrics: report == null
          ? const SizedBox.shrink()
          : RequestMetricPair(
              first: RequestMetric(
                label: 'Requested check-in',
                value: requestDisplayTime(report.requestedCheckIn),
                icon: LucideIcons.clock,
              ),
              second: RequestMetric(
                label: 'Requested check-out',
                value: requestDisplayTime(report.requestCheckOut),
                icon: LucideIcons.clock,
              ),
            ),
      summary: report == null
          ? const SizedBox.shrink()
          : RequestMetric(
              label: 'Requested Corrections',
              value: '$corrections ${corrections == 1 ? 'update' : 'updates'}',
              icon: LucideIcons.clipboardClock,
              highlight: true,
            ),
    );
  }
}
