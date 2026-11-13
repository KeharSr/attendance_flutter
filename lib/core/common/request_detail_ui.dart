import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_top_bar.dart';

const historyBlue = AppColors.accent;

String requestDisplayTime(String? value, {String fallback = 'Not requested'}) {
  if (value == null || value.trim().isEmpty) return fallback;
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2}(?:\.\d+)?)?$')
      .firstMatch(value.trim());
  if (match == null) return value;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  if (hour > 23 || minute > 59) return value;
  return '${hour % 12 == 0 ? 12 : hour % 12}:${match[2]} ${hour < 12 ? 'AM' : 'PM'}';
}

String? requestDisplayDuration(String? start, String? end) {
  int? minutes(String? value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2}(?:\.\d+)?)?$')
        .firstMatch(value ?? '');
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    return hour < 24 && minute < 60 ? hour * 60 + minute : null;
  }

  final from = minutes(start);
  final to = minutes(end);
  if (from == null || to == null) return null;
  final total = (to - from + 1440) % 1440;
  final hours = total ~/ 60;
  final remainder = total % 60;
  return [
    if (hours > 0) '${hours}h',
    if (remainder > 0 || hours == 0) '${remainder}m',
  ].join(' ');
}

class RequestStatusBadge extends StatelessWidget {
  const RequestStatusBadge(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final color = switch (normalized) {
      'approved' => AppColors.success,
      'rejected' => AppColors.danger,
      'pending' => const Color(0xFF92400E),
      _ => AppColors.muted,
    };
    final icon = switch (normalized) {
      'approved' => Icons.check_circle_outline_rounded,
      'rejected' => Icons.highlight_off_rounded,
      _ => Icons.schedule_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              normalized.isEmpty
                  ? 'Unknown'
                  : '${normalized[0].toUpperCase()}${normalized.substring(1)}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({
    required this.title,
    required this.requestId,
    required this.status,
    required this.icon,
    required this.fields,
    required this.reason,
    required this.rejectionReason,
    this.found = true,
    super.key,
  });
  final String title;
  final String requestId;
  final String status;
  final IconData icon;
  final List<({String label, String value, IconData icon})> fields;
  final String reason;
  final String rejectionReason;
  final bool found;

  Widget _section(String title, Widget child, {bool rejection = false}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: rejection ? const Color(0xFFFFF7F6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: rejection
                ? const Color(0xFFF9DDD8)
                : const Color(0xFFE8EDF3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: rejection ? AppColors.danger : AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppTopBar(title: '$title details', automaticallyImplyLeading: true),
    body: !found
        ? const Center(child: Text('Request not found.'))
        : SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.skyPale, Color(0xFFF2FAFE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD9ECF9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(icon, color: historyBlue, size: 26),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Request #$requestId',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RequestStatusBadge(status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _section(
                        'Request information',
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns =
                                constraints.maxWidth >= 440 &&
                                    MediaQuery.textScalerOf(context).scale(14) <
                                        22
                                ? 2
                                : 1;
                            return Wrap(
                              spacing: 20,
                              runSpacing: 24,
                              children: [
                                for (final field in fields)
                                  SizedBox(
                                    width:
                                        (constraints.maxWidth -
                                            (columns - 1) * 20) /
                                        columns,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          field.icon,
                                          size: 18,
                                          color: const Color(0xFF7D91A7),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                field.label,
                                                style: const TextStyle(
                                                  color: AppColors.muted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                field.value,
                                                style: const TextStyle(
                                                  color: AppColors.ink,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        'Reason',
                        Text(
                          reason.trim().isEmpty ? 'No reason provided' : reason,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ),
                      if (status.trim().toLowerCase() == 'rejected') ...[
                        const SizedBox(height: 16),
                        _section(
                          'Rejection reason',
                          Text(
                            rejectionReason,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                          rejection: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}
