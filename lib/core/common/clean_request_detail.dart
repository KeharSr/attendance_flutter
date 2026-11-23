import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_theme.dart';
import 'app_top_bar.dart';
import 'compact_request_card.dart';

class CleanRequestDetail extends StatelessWidget {
  const CleanRequestDetail({
    required this.title,
    required this.dateLabel,
    required this.dateValue,
    required this.status,
    required this.reason,
    required this.fields,
    this.rejectionReason,
    this.found = true,
    super.key,
  });
  final String title, dateLabel, dateValue, status, reason;
  final String? rejectionReason;
  final List<Widget> fields;
  final bool found;
  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final rejected = normalized == 'rejected';
    final decision = switch (normalized) {
      'approved' => 'Your request has been approved.',
      'rejected' => 'Your request has been rejected.',
      'pending' => 'Awaiting administrator review.',
      'cancelled' || 'canceled' => 'This request has been cancelled.',
      _ => 'No administrator decision is available.',
    };
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppTopBar(title: title, automaticallyImplyLeading: true),
      body: !found
          ? const Center(child: Text('Request not found.'))
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
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
                              dateValue,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            RequestStatusPill(status),
                          ],
                        ),
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
                                  icon: LucideIcons.fileText,
                                ),
                                const SizedBox(height: 12),
                                ...fields,
                                const SizedBox(height: 12),
                                RequestDetailNote(
                                  label: 'Reason',
                                  value: reason.trim().isEmpty
                                      ? 'No reason provided'
                                      : reason,
                                ),
                                const Divider(
                                  height: 32,
                                  color: Color(0xFFEAECF0),
                                ),
                                RequestDetailSectionTitle(
                                  rejected ||
                                          normalized == 'cancelled' ||
                                          normalized == 'canceled'
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
                                if (rejected) ...[
                                  const SizedBox(height: 16),
                                  RequestDetailNote(
                                    label: 'Rejection reason',
                                    value:
                                        rejectionReason?.trim().isNotEmpty ==
                                            true
                                        ? rejectionReason!
                                        : 'No rejection reason provided.',
                                  ),
                                ],
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

class RequestDetailSectionTitle extends StatelessWidget {
  const RequestDetailSectionTitle(this.title, {required this.icon, super.key});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: 16, color: AppColors.muted),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class RequestDetailRow extends StatelessWidget {
  const RequestDetailRow({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.small = false,
    this.color = AppColors.ink,
    this.icon,
    super.key,
  });
  final String label, value;
  final bool emphasis, small;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelText = Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.muted),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: small ? 11 : 12,
                ),
              ),
            ),
          ],
        );
        final valueStyle = TextStyle(
          color: small ? AppColors.muted : color,
          fontSize: small ? 11 : 13,
          fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
          height: 1.4,
        );
        if (constraints.maxWidth < 280 ||
            MediaQuery.textScalerOf(context).scale(13) > 18) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelText,
              const SizedBox(height: 4),
              Text(value, style: valueStyle),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: labelText),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Text(value, textAlign: TextAlign.end, style: valueStyle),
            ),
          ],
        );
      },
    ),
  );
}

class RequestDetailNote extends StatelessWidget {
  const RequestDetailNote({
    required this.label,
    required this.value,
    super.key,
  });
  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          height: 1.55,
        ),
      ),
    ],
  );
}
