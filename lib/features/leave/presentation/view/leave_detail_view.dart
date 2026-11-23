import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/clean_request_detail.dart';
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
    for (final request in requests) {
      if (request.id == requestId) {
        report = request;
        break;
      }
    }

    return CleanRequestDetail(
      title: 'Leave details',
      found: report != null,
      dateLabel: 'Leave dates',
      dateValue: report == null
          ? ''
          : '${styledRequestDate(report.startDate.toIso8601String())} \u2013 ${styledRequestDate(report.endDate.toIso8601String())}',
      status: report?.status ?? '',
      reason: report?.reason ?? '',
      rejectionReason: report?.rejectionReason,
      fields: report == null
          ? []
          : [
              RequestDetailRow(
                label: 'Start date',
                value: styledRequestDate(report.startDate.toIso8601String()),
              ),
              RequestDetailRow(
                label: 'End date',
                value: styledRequestDate(report.endDate.toIso8601String()),
              ),
              RequestDetailRow(
                label: 'Requested Days',
                value: leaveDaysLabel(report.startDate, report.endDate),
                emphasis: true,
              ),
            ],
    );
  }
}
