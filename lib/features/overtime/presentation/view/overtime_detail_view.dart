import 'package:attendance_flutter/core/common/clean_request_detail.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  String? _timestamp(String? value) {
    final date = DateTime.tryParse(value ?? '');
    return date == null
        ? null
        : DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
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
    final request = report;
    if (request == null) {
      return Scaffold(
        appBar: const AppTopBar(
          title: 'Overtime details',
          automaticallyImplyLeading: true,
        ),
        body: const Center(child: Text('Request not found.')),
      );
    }
    final status = request.status.trim().toLowerCase();
    final decision = switch (status) {
      'approved' => 'Your overtime request has been approved.',
      'rejected' => 'Your overtime request has been rejected.',
      'pending' => 'Awaiting administrator review.',
      'cancelled' || 'canceled' => 'This request has been cancelled.',
      _ => 'No administrator decision is available.',
    };
    final hasApproval =
        status == 'approved' ||
        request.overtimeAcceptedHours != null ||
        request.overtimeApproveStartTime?.trim().isNotEmpty == true ||
        request.overtimeApproveEndTime?.trim().isNotEmpty == true;
    final created = _timestamp(request.createdAt);
    final updated = _timestamp(request.updatedAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppTopBar(
        title: 'Overtime details',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Work date',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        overtimeDate(request.workDate),
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      OvertimeStatusBadge(request.status),
                    ],
                  ),
                  if (created != null || updated != null) ...[
                    const SizedBox(height: 12),
                    if (created != null)
                      RequestDetailRow(
                        label: 'Created at',
                        value: created,
                        small: true,
                        icon: LucideIcons.calendarPlus,
                      ),
                    if (updated != null)
                      RequestDetailRow(
                        label: 'Updated at',
                        value: updated,
                        small: true,
                        icon: LucideIcons.refreshCw,
                      ),
                  ],
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.white,
                    elevation: 1,
                    shadowColor: const Color(0x14163449),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE4E7EC)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RequestDetailSectionTitle(
                            'Employee Request',
                            icon: LucideIcons.clock,
                          ),
                          const SizedBox(height: 12),
                          RequestDetailRow(
                            label: 'Requested Time',
                            value: overtimeRange(
                              request.overtimeStartTime,
                              request.overtimeEndTime,
                            ),
                          ),
                          RequestDetailRow(
                            label: 'Requested Hours',
                            value: overtimeHours(
                              request.overtimeStartTime,
                              request.overtimeEndTime,
                              hours: request.overtimeRequestedHours,
                            ),
                            emphasis: true,
                          ),
                          const SizedBox(height: 12),
                          RequestDetailNote(
                            label: 'Reason',
                            value: request.reason.trim().isEmpty
                                ? 'No reason provided'
                                : request.reason,
                          ),
                          const Divider(height: 32, color: Color(0xFFEAECF0)),
                          RequestDetailSectionTitle(
                            status == 'rejected' ||
                                    status == 'cancelled' ||
                                    status == 'canceled'
                                ? 'Administrator Decision'
                                : 'Administrator Approval',
                            icon: LucideIcons.shieldCheck,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            decision,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          if (hasApproval) ...[
                            const SizedBox(height: 8),
                            RequestDetailRow(
                              label: 'Approved Time',
                              value: overtimeRange(
                                request.overtimeApproveStartTime,
                                request.overtimeApproveEndTime,
                              ),
                            ),
                            RequestDetailRow(
                              label: 'Accepted Hours',
                              value: overtimeHours(
                                request.overtimeApproveStartTime,
                                request.overtimeApproveEndTime,
                                hours: request.overtimeAcceptedHours,
                              ),
                              emphasis: true,
                              color: status == 'approved'
                                  ? AppColors.success
                                  : AppColors.ink,
                            ),
                          ],
                          const SizedBox(height: 16),
                          RequestDetailNote(
                            label: 'Admin Comment',
                            value:
                                request.adminComment?.trim().isNotEmpty == true
                                ? request.adminComment!
                                : 'No comment provided.',
                          ),
                        ],
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
