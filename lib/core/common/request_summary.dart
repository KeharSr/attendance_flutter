import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class RequestSummary extends StatelessWidget {
  const RequestSummary({
    this.summary,
    this.loading = false,
    this.unavailable = false,
    this.compact = false,
    super.key,
  });

  final RequestSummaryEntity? summary;
  final bool loading;
  final bool unavailable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    String value(num? total) =>
        loading || unavailable || total == null ? '\u2014' : '$total';

    final metrics = [
      (
        label: 'Total applied',
        value: value(summary?.totalApplied),
        color: AppColors.blue,
      ),
      (
        label: 'Approved',
        value: value(summary?.totalApproved),
        color: AppColors.success,
      ),
      (
        label: 'Pending',
        value: value(summary?.totalPending),
        color: AppColors.accent,
      ),
      (
        label: 'Rejected',
        value: value(summary?.totalRejected),
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
