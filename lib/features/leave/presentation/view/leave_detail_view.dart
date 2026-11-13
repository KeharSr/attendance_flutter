import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:flutter/material.dart';

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
    LeaveEntity? request;
    for (final item in requests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }
    final report = request;
    final rejectionReason = report?.rejectionReason?.trim();
    final rejectReason = rejectionReason == null || rejectionReason.isEmpty
        ? 'No rejection reason provided.'
        : rejectionReason;
    return RequestDetailPage(
      title: 'Leave request',
      requestId: requestId.toString(),
      found: report != null,
      status: report?.status ?? '',
      icon: Icons.event_available_outlined,
      reason: report?.reason ?? '',
      rejectionReason:
          rejectReason,
      fields: report == null
          ? []
          : [
              (
                label: 'Employee ID',
                value: report.userId,
                icon: Icons.person_outline_rounded,
              ),
              (
                label: 'Start date',
                value: DateTimeUtils.formatDate(report.startDate),
                icon: Icons.calendar_today_outlined,
              ),
              (
                label: 'End date',
                value: DateTimeUtils.formatDate(report.endDate),
                icon: Icons.event_outlined,
              ),
            ],
    );
  }
}
