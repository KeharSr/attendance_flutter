import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_theme.dart';

class RequestStatusPill extends StatelessWidget {
  const RequestStatusPill(this.status, {this.compact = false, super.key});
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final colors = switch (normalized) {
      'pending' => (
        background: const Color(0xFFFFF4CC),
        foreground: const Color(0xFF854D0E),
      ),
      'approved' => (
        background: const Color(0xFFECFDF3),
        foreground: AppColors.success,
      ),
      'rejected' => (
        background: const Color(0xFFFEF3F2),
        foreground: AppColors.danger,
      ),
      _ => (
        background: const Color(0xFFF2F4F7),
        foreground: const Color(0xFF475467),
      ),
    };
    final icon = switch (normalized) {
      'approved' => LucideIcons.circleCheck,
      'rejected' => LucideIcons.circleX,
      'pending' => LucideIcons.clock,
      _ => LucideIcons.circleMinus,
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 9,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.foreground.withValues(alpha: .16)),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              normalized.isEmpty
                  ? 'Unknown'
                  : '${normalized[0].toUpperCase()}${normalized.substring(1)}',
              style: TextStyle(
                color: colors.foreground,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactRequestCard extends StatelessWidget {
  const CompactRequestCard({
    required this.title,
    required this.reason,
    required this.status,
    required this.icon,
    required this.details,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    super.key,
  });
  final String title, reason, status;
  final IconData icon;
  final List<Widget> details;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final canAct =
        status.trim().toLowerCase() == 'pending' &&
        (onEdit != null || onDelete != null);
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x26163449),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFDFE3E8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: AppColors.muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        RequestStatusPill(status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reason.trim().isEmpty ? 'No reason provided' : reason,
                      maxLines: MediaQuery.textScalerOf(context).scale(12) > 17
                          ? 2
                          : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: details,
                    ),
                  ],
                ),
              ),
              if (canAct)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit request',
                        onPressed: actionsEnabled ? onEdit : null,
                        icon: const Icon(LucideIcons.pencil, size: 17),
                        color: AppColors.accent,
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete request',
                        onPressed: actionsEnabled ? onDelete : null,
                        icon: const Icon(LucideIcons.trash2, size: 17),
                        color: AppColors.danger,
                      ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 14, left: 8, right: 6),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompactRequestInfo extends StatelessWidget {
  const CompactRequestInfo(
    this.value, {
    this.icon,
    this.emphasis = false,
    this.color = AppColors.muted,
    this.semanticLabel,
    super.key,
  });
  final String value;
  final IconData? icon;
  final bool emphasis;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: emphasis ? 11 : 10,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}
