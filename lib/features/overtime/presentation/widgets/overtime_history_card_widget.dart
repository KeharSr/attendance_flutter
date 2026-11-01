import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';

class OvertimeHistoryCardWidget extends StatelessWidget {
  const OvertimeHistoryCardWidget({super.key, required this.request});

  final OvertimeEntity request;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final date = DateTime.tryParse(request.workDate);
    final formattedDate = date == null
        ? request.workDate
        : DateTimeUtils.formatDate(date);

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
              backgroundColor: const Color(0xFF1769E0).withValues(alpha: .1),
              child: const Icon(
                Icons.more_time_rounded,
                color: Color(0xFF1769E0),
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF102A43),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${request.overtimeHours.toStringAsFixed(2)} hours',
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
