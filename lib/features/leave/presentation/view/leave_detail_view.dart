import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';

class LeaveDetailView extends StatelessWidget {
  const LeaveDetailView({
    required this.requestId,
    required this.requests,
    super.key,
  });
  final String requestId;
  final List<LeaveEntity> requests;

  @override
  Widget build(BuildContext context) {
    LeaveEntity? report;
    for (final item in requests) {
      if (item.id == requestId) {
        report = item;
        break;
      }
    }
    return StyledRequestDetail(
      title: 'Leave Details',
      found: report != null,
      status: report?.status ?? '',
      reason: report?.reason ?? '',
      rejectionReason: report?.rejectionReason,
      dateLabel: 'Leave Dates',
      dateValue: report == null
          ? ''
          : '${styledRequestDate(report.startDate.toIso8601String())} - ${styledRequestDate(report.endDate.toIso8601String())}',
      metrics: report == null
          ? const SizedBox.shrink()
          : RequestMetricPair(
              first: RequestMetric(
                label: 'Start date',
                value: styledRequestDate(report.startDate.toIso8601String()),
                icon: LucideIcons.calendar,
              ),
              second: RequestMetric(
                label: 'End date',
                value: styledRequestDate(report.endDate.toIso8601String()),
                icon: LucideIcons.calendar,
              ),
            ),
      summary: report == null
          ? const SizedBox.shrink()
          : RequestMetric(
              label: 'Requested Days',
              value: leaveDaysLabel(report.startDate, report.endDate),
              icon: LucideIcons.hourglass,
              highlight: true,
            ),
    );
  }
}
