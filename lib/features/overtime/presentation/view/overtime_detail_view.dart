import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';

import '../widgets/overtime_ui.dart';

class OvertimeDetailView extends StatelessWidget {
  const OvertimeDetailView({
    required this.requestId,
    required this.requests,
    super.key,
  });
  final String requestId;
  final List<OvertimeEntity> requests;

  String _timestamp(String? value) {
    final date = DateTime.tryParse(value ?? '');
    return date == null
        ? 'Not provided'
        : DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  Widget _section({
    required String title,
    required String status,
    required String subtitle,
    required IconData icon,
    required Widget metrics,
    required String noteLabel,
    required String note,
    required IconData noteIcon,
    bool green = false,
  }) {
    final color = green ? overtimeGreen : overtimeBlue;
    return OvertimePanel(
      green: green,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .025),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: .8)],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: overtimeInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: RequestStatusBadge(status),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDF2F8)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                metrics,
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: OvertimeMetric(
                    label: noteLabel,
                    value: note,
                    icon: noteIcon,
                    green: green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    OvertimeEntity? report;
    for (final request in requests) {
      if (request.id == requestId) {
        report = request;
        break;
      }
    }
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Overtime Details')),
        body: const Center(child: Text('Request not found.')),
      );
    }
    final request = report;
    final rejected = request.status.trim().toLowerCase() == 'rejected';
    final pending = request.status.trim().toLowerCase() == 'pending';
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFF),
      appBar: AppTopBar(
        automaticallyImplyLeading: true,
        title: 'Overtime Details View',
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OvertimePanel(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFF2F8FF),
                              Color(0xFFD4E9FF),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OvertimeMetric(
                                label: 'Work Date',
                                value: overtimeDate(request.workDate),
                                icon: LucideIcons.calendar,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 66,
                              height: 50,
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    child: Icon(
                                      LucideIcons.calendarDays,
                                      size: 48,
                                      color: Color(0xFF8BC1FB),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Icon(
                                      LucideIcons.clock,
                                      size: 28,
                                      color: overtimeBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Employee Request',
                    status: request.status,
                    subtitle: 'Overtime details you requested.',
                    icon: LucideIcons.user,
                    metrics: OvertimePair(
                      first: OvertimeMetric(
                        label: 'Requested Time',
                        value: overtimeRange(
                          request.overtimeStartTime,
                          request.overtimeEndTime,
                        ),
                        icon: LucideIcons.clock,
                      ),
                      second: OvertimeMetric(
                        label: 'Requested Hours',
                        value: overtimeHours(
                          request.overtimeStartTime,
                          request.overtimeEndTime,
                          hours: request.overtimeRequestedHours,
                        ),
                        icon: LucideIcons.hourglass,
                        highlight: true,
                      ),
                    ),
                    noteLabel: 'Reason',
                    note: request.reason.trim().isEmpty
                        ? 'No reason provided'
                        : request.reason,
                    noteIcon: LucideIcons.fileText,
                  ),
                  const SizedBox(height: 16),
                  _section(
                    status: request.status,
                    title: rejected
                        ? 'Administrator Decision'
                        : 'Administrator Approval',
                    subtitle: pending
                        ? 'Awaiting administrator review.'
                        : 'Decision and details from administrator.',
                    icon: LucideIcons.shieldCheck,
                    green: true,
                    metrics: OvertimePair(
                      first: OvertimeMetric(
                        label: 'Approved Time',
                        value: overtimeRange(
                          request.overtimeApproveStartTime,
                          request.overtimeApproveEndTime,
                        ),
                        icon: LucideIcons.clock,
                        green: true,
                      ),
                      second: OvertimeMetric(
                        label: 'Accepted Hours',
                        value: overtimeHours(
                          request.overtimeApproveStartTime,
                          request.overtimeApproveEndTime,
                          hours: request.overtimeAcceptedHours,
                        ),
                        icon: LucideIcons.hourglass,
                        green: true,
                        highlight: true,
                      ),
                    ),
                    noteLabel: 'Admin Comment',
                    note: request.adminComment?.trim().isNotEmpty == true
                        ? request.adminComment!
                        : 'Not provided',
                    noteIcon: LucideIcons.messageSquare,
                  ),
                  const SizedBox(height: 16),
                  OvertimePanel(
                    child: OvertimePair(
                      first: OvertimeMetric(
                        label: 'Created',
                        value: _timestamp(request.createdAt),
                        icon: LucideIcons.calendar,
                        boxed: false,
                      ),
                      second: OvertimeMetric(
                        label: 'Updated',
                        value: _timestamp(request.updatedAt),
                        icon: LucideIcons.calendar,
                        boxed: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
