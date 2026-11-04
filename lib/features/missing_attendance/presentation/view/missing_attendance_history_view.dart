import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:flutter/material.dart';

class MissingAttendanceHistoryView extends StatelessWidget {
  const MissingAttendanceHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
  });
  final List<MissingAttendanceEntity> requests;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  @override
  Widget build(BuildContext context) => RequestHistoryList(
    count: requests.length,
    loading: isLoading,
    error: errorMessage,
    onRefresh: onRefresh,
    emptyText: 'No attendance reports yet',
    itemBuilder: (_, index) => _MissingAttendanceCard(request: requests[index]),
  );
}

class _MissingAttendanceCard extends StatelessWidget {
  const _MissingAttendanceCard({required this.request});
  final MissingAttendanceEntity request;
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(request.missingDate);
    return RequestHistoryTile(
      title: date == null
          ? request.missingDate
          : DateTimeUtils.formatDate(date),
      detail: '${request.requestedCheckIn} - ${request.requestCheckOut}',
      reason: request.reason,
      status: request.status,
    );
  }
}
