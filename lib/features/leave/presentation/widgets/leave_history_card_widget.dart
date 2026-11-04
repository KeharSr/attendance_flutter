import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:flutter/material.dart';

class LeaveHistoryCardWidget extends StatelessWidget {
  const LeaveHistoryCardWidget({required this.request, super.key});
  final LeaveEntity request;
  @override
  Widget build(BuildContext context) {
    return RequestHistoryTile(
      title: DateTimeUtils.formatDate(request.startDate),
      detail: 'Through ${DateTimeUtils.formatDate(request.endDate)}',
      reason: request.reason,
      status: request.status,
    );
  }
}
