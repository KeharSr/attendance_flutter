import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';

class OvertimeDetailView extends StatelessWidget {
  const OvertimeDetailView({
    required this.requestId,
    required this.requests,
    super.key,
  });

  final String requestId;
  final List<OvertimeEntity> requests;

  @override
  Widget build(BuildContext context) {
    OvertimeEntity? request;
    for (final item in requests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }
    final report = request;
    final rejectionReason = report?.rejectReason?.trim();
    final rejectReason = rejectionReason == null || rejectionReason.isEmpty
        ? 'No rejection reason provided.'
        : rejectionReason;
    return RequestDetailPage(
      title: 'Overtime request',
      requestId: requestId.toString(),
      found: report != null,
      status: report?.status ?? '',
      icon: LucideIcons.clockPlus,
      reason: report?.reason ?? '',
      rejectionReason: rejectReason,
      fields: report == null
          ? []
          : [
              (
                label: 'Employee ID',
                value: '${report.userId}',
                icon: LucideIcons.user,
              ),
              (
                label: 'Work date',
                value: DateTime.tryParse(report.workDate) == null
                    ? report.workDate
                    : DateTimeUtils.formatDate(DateTime.parse(report.workDate)),
                icon: LucideIcons.calendar,
              ),
              (
                label: 'Start time',
                value: requestDisplayTime(report.overtimeStartTime),
                icon: LucideIcons.clock,
              ),
              (
                label: 'End time',
                value: requestDisplayTime(report.overtimeEndTime),
                icon: LucideIcons.clock,
              ),
            ],
    );
  }
}
