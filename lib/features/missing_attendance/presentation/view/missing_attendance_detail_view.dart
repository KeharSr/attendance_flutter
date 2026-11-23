import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/clean_request_detail.dart';
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
    for (final request in requests) {
      if (request.id == requestId) {
        report = request;
        break;
      }
    }
    final corrections = report == null
        ? 0
        : [
            report.requestedCheckIn,
            report.requestCheckOut,
          ].where((time) => time.trim().isNotEmpty).length;
    return CleanRequestDetail(
      title: 'Attendance details',
      found: report != null,
      dateLabel: 'Attendance date',
      dateValue: report == null ? '' : styledRequestDate(report.missingDate),
      status: report?.status ?? '',
      reason: report?.reason ?? '',
      rejectionReason: report?.rejectReason,
      fields: report == null
          ? []
          : [
              RequestDetailRow(
                label: 'Check-in',
                value: requestDisplayTime(report.requestedCheckIn),
              ),
              RequestDetailRow(
                label: 'Check-out',
                value: requestDisplayTime(report.requestCheckOut),
              ),
              RequestDetailRow(
                label: 'Corrections',
                value:
                    '$corrections ${corrections == 1 ? 'update' : 'updates'}',
                emphasis: true,
              ),
            ],
    );
  }
}
