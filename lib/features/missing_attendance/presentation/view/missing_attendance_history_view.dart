import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:flutter/material.dart';

class MissingAttendanceHistoryView extends StatelessWidget {
  const MissingAttendanceHistoryView({
    super.key,
    required this.requests,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<MissingAttendanceEntity> requests;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
        ),
      );
    }

    if (requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                color: Color(0xFF98A2B3),
                size: 46,
              ),
              SizedBox(height: 12),
              Text(
                'No missing attendance reports yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Your submitted reports will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) =>
          _MissingAttendanceCard(request: requests[index]),
    );
  }
}

class _MissingAttendanceCard extends StatelessWidget {
  const _MissingAttendanceCard({required this.request});

  final MissingAttendanceEntity request;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(request.missingDate);
    final statusColor = _statusColor(request.status);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6EBF2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: const Color(0xFFD97706).withValues(alpha: .1),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFFD97706),
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date == null
                        ? request.missingDate
                        : DateTimeUtils.formatDate(date),
                    style: const TextStyle(
                      color: Color(0xFF102A43),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${request.requestedCheckIn} - ${request.requestCheckOut}',
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    request.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(label: request.status, color: statusColor),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF14804A);
      case 'rejected':
        return const Color(0xFFD92D20);
      default:
        return const Color(0xFFB54708);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
