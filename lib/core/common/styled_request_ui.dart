import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_top_bar.dart';

import 'package:intl/intl.dart';
import 'package:attendance_flutter/core/common/request_detail_ui.dart';

const requestBlue = Color(0xFF0876CC);
const requestGreen = Color(0xFF208D2D);
const requestInk = Color(0xFF101828);

String styledRequestDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null
      ? (value.isEmpty ? 'Not provided' : value)
      : DateFormat('dd MMM yyyy').format(date);
}

String styledRequestRange(String? start, String? end) {
  if (start == null || start.isEmpty || end == null || end.isEmpty) {
    return 'Not provided';
  }
  return '${requestDisplayTime(start)} – ${requestDisplayTime(end)}';
}

String styledRequestHours(String? start, String? end, {double? hours}) {
  if (hours != null && hours.isFinite && hours >= 0) {
    return '${NumberFormat('0.##').format(hours)} ${hours == 1 ? 'hour' : 'hours'}';
  }
  final duration = requestDisplayDuration(start, end);
  if (duration == null) return 'Not provided';
  return duration
      .replaceAllMapped(
        RegExp(r'(\d+)h'),
        (m) => '${m[1]} ${m[1] == '1' ? 'hour' : 'hours'}',
      )
      .replaceAll('m', ' min');
}

class RequestPanel extends StatelessWidget {
  const RequestPanel({
    required this.child,
    this.green = false,
    this.padding = const EdgeInsets.all(12),
    super.key,
  });
  final Widget child;
  final bool green;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: green ? const Color(0xFFDFF0E4) : const Color(0xFFDFEBFC),
      ),
      boxShadow: [
        BoxShadow(
          color: requestBlue.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class RequestMetric extends StatelessWidget {
  const RequestMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.green = false,
    this.boxed = true,
    this.highlight = false,
    super.key,
  });
  final String label, value;
  final IconData icon;
  final bool green, boxed, highlight;
  @override
  Widget build(BuildContext context) {
    final color = green ? requestGreen : requestBlue;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(boxed ? 8 : 3),
          decoration: BoxDecoration(
            color: boxed ? color.withValues(alpha: .09) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF475467)),
              ),
              const SizedBox(height: 2),
              Container(
                padding: highlight
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: highlight
                      ? color.withValues(alpha: .09)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: requestInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RequestMetricPair extends StatelessWidget {
  const RequestMetricPair({
    required this.first,
    required this.second,
    super.key,
  });
  final Widget first, second;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(13) > 18) {
        return Column(children: [first, const SizedBox(height: 12), second]);
      }
      return IntrinsicHeight(
        child: Row(
          children: [
            Expanded(flex: 6, child: first),
            const VerticalDivider(width: 20, color: Color(0xFFDDE9F8)),
            Expanded(flex: 5, child: second),
          ],
        ),
      );
    },
  );
}

String leaveDaysLabel(DateTime start, DateTime end) {
  final days =
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;
  if (days < 1) return 'Invalid date range';
  return '$days ${days == 1 ? 'day' : 'days'}';
}

class StyledRequestCard extends StatelessWidget {
  const StyledRequestCard({
    required this.title,
    required this.reason,
    required this.status,
    required this.icon,
    required this.metrics,
    required this.summary,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final String title, reason, status;
  final IconData icon;
  final Widget metrics, summary;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 330 ||
          MediaQuery.textScalerOf(context).scale(13) > 18;
      final canAct = status.trim().toLowerCase() == 'pending';
      return GestureDetector(
        onTap: onView,
        behavior: HitTestBehavior.opaque,
        child: RequestPanel(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: requestBlue.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: requestBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: requestInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reason.trim().isEmpty ? 'No reason provided' : reason,
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
                    RequestStatusBadge(status),
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
                  child: RequestStatusBadge(status),
                ),
              ],
              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Divider(height: 22, color: Color(0xFFF0F3F7)),
              ),
              metrics,
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: summary,
              ),
              if (canAct && (onEdit != null || onDelete != null)) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: actionsEnabled ? onEdit : null,
                          icon: const Icon(LucideIcons.pencil, size: 15),
                          label: const Text('Edit'),
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: actionsEnabled ? onDelete : null,
                          icon: const Icon(LucideIcons.trash2, size: 15),
                          label: const Text('Delete'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class StyledRequestSection extends StatelessWidget {
  const StyledRequestSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.child,
    this.green = false,
    super.key,
  });
  final String title, subtitle, status;
  final IconData icon;
  final Widget child;
  final bool green;
  @override
  Widget build(BuildContext context) {
    final color = green ? requestGreen : requestBlue;
    return RequestPanel(
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: requestInk,
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
                      const SizedBox(height: 2),
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
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class StyledRequestNote extends StatelessWidget {
  const StyledRequestNote({
    required this.label,
    required this.value,
    this.green = false,
    this.icon = LucideIcons.fileText,
    super.key,
  });
  final String label, value;
  final bool green;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: (green ? requestGreen : requestBlue).withValues(alpha: .05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: RequestMetric(label: label, value: value, icon: icon, green: green),
  );
}

class StyledRequestDetail extends StatelessWidget {
  const StyledRequestDetail({
    required this.title,
    required this.dateLabel,
    required this.dateValue,
    required this.status,
    required this.reason,
    required this.metrics,
    required this.summary,
    this.rejectionReason,
    this.found = true,
    super.key,
  });
  final String title, dateLabel, dateValue, status, reason;
  final String? rejectionReason;
  final Widget metrics, summary;
  final bool found;
  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final rejected = normalized == 'rejected';
    final pending = normalized == 'pending';
    final decision = switch (normalized) {
      'approved' => 'Your request has been approved.',
      'rejected' => 'Your request has been rejected.',
      'pending' => 'Awaiting administrator review.',
      'cancelled' || 'canceled' => 'This request has been cancelled.',
      _ => 'No administrator decision is available.',
    };
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFF),
      appBar: AppTopBar(title: title, automaticallyImplyLeading: true),
      body: !found
          ? const Center(child: Text('Request not found.'))
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RequestPanel(
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
                                    child: RequestMetric(
                                      label: dateLabel,
                                      value: dateValue,
                                      icon: LucideIcons.calendar,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.calendarDays,
                                    size: 48,
                                    color: Color(0xFF8BC1FB),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        StyledRequestSection(
                          title: 'Employee Request',
                          subtitle: 'Details of your request.',
                          icon: LucideIcons.user,
                          status: status,
                          child: Column(
                            children: [
                              metrics,
                              const SizedBox(height: 14),
                              summary,
                              const SizedBox(height: 14),
                              StyledRequestNote(
                                label: 'Reason',
                                value: reason.trim().isEmpty
                                    ? 'No reason provided'
                                    : reason,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        StyledRequestSection(
                          title: rejected
                              ? 'Administrator Decision'
                              : 'Administrator Approval',
                          subtitle: pending
                              ? 'Awaiting administrator review.'
                              : 'Decision and details from administrator.',
                          icon: LucideIcons.shieldCheck,
                          status: status,
                          green: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StyledRequestNote(
                                label: 'Decision',
                                value: decision,
                                icon: LucideIcons.shieldCheck,
                                green: true,
                              ),
                              if (rejected) ...[
                                const SizedBox(height: 12),
                                StyledRequestNote(
                                  label: 'Rejection reason',
                                  value:
                                      rejectionReason?.trim().isNotEmpty == true
                                      ? rejectionReason!
                                      : 'No rejection reason provided.',
                                  icon: LucideIcons.messageSquare,
                                  green: true,
                                ),
                              ],
                            ],
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
