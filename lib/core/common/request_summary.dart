import 'package:flutter/material.dart';

import 'app_theme.dart';

class RequestSummary extends StatelessWidget {
  const RequestSummary({
    required this.statuses,
    this.loading = false,
    this.unavailable = false,
    this.compact = false,
    super.key,
  }) : _durations = null;

  const RequestSummary.hours({
    required Iterable<({String status, Duration? duration})> entries,
    this.loading = false,
    this.unavailable = false,
    this.compact = false,
    super.key,
  }) : statuses = const [],
       _durations = entries;

  final Iterable<String> statuses;
  final bool loading;
  final bool unavailable;
  final bool compact;
  final Iterable<({String status, Duration? duration})>? _durations;

  @override
  Widget build(BuildContext context) {
    final entries =
        (_durations ??
                statuses.map((status) => (status: status, duration: null)))
            .map(
              (entry) => (
                status: entry.status.trim().toLowerCase(),
                duration: entry.duration,
              ),
            )
            .toList();
    final unknown = entries.isEmpty && (loading || unavailable);

    String valueFor(bool Function(String status) matches) {
      if (unknown) return '\u2014';
      final matching = entries.where((entry) => matches(entry.status));
      if (_durations == null) return '${matching.length}';
      if (matching.any((entry) => entry.duration == null)) return '\u2014';
      final seconds = matching.fold<int>(
        0,
        (total, entry) => total + entry.duration!.inSeconds,
      );
      final hours = (seconds / 3600)
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'\.?0+$'), '');
      return '$hours ${hours == '1' ? 'hr' : 'hrs'}';
    }

    final metrics = [
      (
        label: 'Total applied',
        value: valueFor((_) => true),
        color: AppColors.blue,
      ),
      (
        label: 'Approved',
        value: valueFor((s) => s == 'approved'),
        color: AppColors.success,
      ),
      (
        label: 'Pending',
        value: valueFor((s) => s == 'pending'),
        color: AppColors.accent,
      ),
      (
        label: 'Cancelled',
        value: valueFor((s) => s == 'cancelled' || s == 'canceled'),
        color: AppColors.danger,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 560 ||
                (compact &&
                    constraints.maxWidth >= 340 &&
                    MediaQuery.textScalerOf(context).scale(12) <= 14)
            ? 4
            : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: Semantics(
                  container: true,
                  child: Container(
                    padding: compact
                        ? const EdgeInsets.symmetric(vertical: 6)
                        : const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                    decoration: compact
                        ? null
                        : BoxDecoration(
                            color: metric.color.withValues(alpha: .04),
                            border: Border.all(
                              color: metric.color.withValues(alpha: .4),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.label,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.value,
                          style: TextStyle(
                            color: compact ? AppColors.ink : metric.color,
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
