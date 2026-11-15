import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';

import 'overtime_ui.dart';

class OvertimeHistoryCardWidget extends StatelessWidget {
  const OvertimeHistoryCardWidget({
    required this.request,
    this.onEdit,
    this.onDelete,
    super.key,
  });
  final OvertimeEntity request;
  final VoidCallback? onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final stacked =
        MediaQuery.sizeOf(context).width < 350 ||
        MediaQuery.textScalerOf(context).scale(13) > 18;
    final pending = request.status.trim().toLowerCase() == 'pending';
    return OvertimePanel(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: overtimeBlue.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: overtimeBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overtimeDate(request.workDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: overtimeInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.reason.trim().isEmpty
                          ? 'No reason provided'
                          : request.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ],
                ),
              ),
              if (!stacked) ...[
                const SizedBox(width: 6),
                RequestStatusBadge(request.status),
              ],
              const SizedBox(width: 4),
              const Icon(
                LucideIcons.chevronRight,
                size: 19,
                color: Color(0xFF667085),
              ),
            ],
          ),
          if (stacked) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: RequestStatusBadge(request.status),
            ),
          ],
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Divider(height: 22, color: Color(0xFFF0F3F7)),
          ),
          OvertimePair(
            first: OvertimeMetric(
              label: 'Requested Time',
              value: overtimeRange(
                request.overtimeStartTime,
                request.overtimeEndTime,
              ),
              icon: LucideIcons.clock,
              boxed: false,
            ),
            second: OvertimeMetric(
              label: 'Approved Time',
              value: overtimeRange(
                request.overtimeApproveStartTime,
                request.overtimeApproveEndTime,
              ),
              icon: LucideIcons.clock,
              green: true,
              boxed: false,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: OvertimePair(
              first: OvertimeMetric(
                label: 'Requested Hours',
                value: overtimeHours(
                  request.overtimeStartTime,
                  request.overtimeEndTime,
                  hours: request.overtimeRequestedHours,
                ),
                icon: LucideIcons.hourglass,
                boxed: false,
              ),
              second: OvertimeMetric(
                label: 'Accepted Hours',
                value: overtimeHours(
                  request.overtimeApproveStartTime,
                  request.overtimeApproveEndTime,
                  hours: request.overtimeAcceptedHours,
                ),
                icon: LucideIcons.circleCheck,
                green: true,
                boxed: false,
              ),
            ),
          ),
          if (pending && (onEdit != null || onDelete != null)) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.pencil, size: 15),
                    label: const Text('Edit'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(LucideIcons.trash2, size: 15),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
