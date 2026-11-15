import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/empty_widget.dart';

const requestInk = AppColors.ink;
const requestMuted = AppColors.muted;
const requestAccent = AppColors.accent;

const _surface = Colors.white;
const _subtle = Color(0xFFF5FAFD); // soft panel background
const _hairline = AppColors.border;

InputDecoration requestInput(String hint, {IconData? icon, String? suffix}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
    filled: true,
    fillColor: _subtle,
    prefixIcon: icon == null ? null : Icon(icon, size: 20, color: requestMuted),
    suffixText: suffix,
    suffixStyle: const TextStyle(color: requestMuted, fontSize: 13),
    border: border(_hairline),
    enabledBorder: border(_hairline),
    focusedBorder: border(requestAccent, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    errorMaxLines: 2,
  );
}

class RequestLabel extends StatelessWidget {
  const RequestLabel(this.label, {this.newText, super.key});
  final String label;
  final String? newText;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: requestInk,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (newText != null)
            TextSpan(
              text: ' $newText',
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    ),
  );
}

class RequestSubmitButton extends StatelessWidget {
  const RequestSubmitButton({
    required this.loading,
    required this.onPressed,
    this.label = 'Submit request',
    super.key,
  });
  final bool loading;
  final VoidCallback onPressed;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: requestAccent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: requestAccent.withValues(alpha: .6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: loading
          ? const AppLoadingIndicator(size: 20, strokeWidth: 2)
          : Text(label),
    ),
  );
}

// ---------------------------------------------------------------------------
// Form card + intro
// ---------------------------------------------------------------------------

class RequestFormCard extends StatelessWidget {
  const RequestFormCard({
    required this.formKey,
    required this.child,
    super.key,
  });
  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEDF0F5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D1A2942),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Form(key: formKey, child: child),
  );
}

class RequestIntro extends StatelessWidget {
  const RequestIntro(this.title, this.description, {this.icon, super.key});
  final String title;
  final String description;

  /// Optional badge icon shown beside the title.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: requestAccent.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: requestAccent, size: 22),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: requestInk,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: requestMuted,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RequestHistoryTile extends StatelessWidget {
  const RequestHistoryTile({
    required this.title,
    required this.detail,
    required this.reason,
    required this.status,
    this.typeLabel = 'Request',
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    this.icon,
    this.footer,
    this.startLabel = 'Start',
    this.endLabel = 'End',
    this.startValue,
    this.endValue,
    this.durationLabel,
    super.key,
  });
  final String title, detail, reason, status, typeLabel, startLabel, endLabel;
  final String? startValue, endValue, durationLabel, footer;
  final VoidCallback? onView, onEdit, onDelete;
  final bool actionsEnabled;
  final IconData? icon;

  Widget _value(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF102C4F),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final canAct =
        normalized == 'pending' && (onEdit != null || onDelete != null);
    final color = switch (normalized) {
      'approved' => const Color(0xFF007D83),
      'rejected' => const Color(0xFFCC3E24),
      'pending' => const Color(0xFF9A5B00),
      _ => requestMuted,
    };
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: switch (normalized) {
          'approved' => const Color(0xFFE0F2EF),
          'rejected' => const Color(0xFFFBE5DE),
          'pending' => const Color(0xFFFFF0D0),
          _ => const Color(0xFFF0F2F6),
        },
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        normalized.isEmpty
            ? 'Unknown'
            : '${normalized[0].toUpperCase()}${normalized.substring(1)}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081D3557),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final heading = Text(
                      reason.trim().isEmpty ? typeLabel : reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF102C4F),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    );
                    if (MediaQuery.textScalerOf(context).scale(13) > 19 ||
                        constraints.maxWidth < 230) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [heading, const SizedBox(height: 6), badge],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: heading),
                        const SizedBox(width: 8),
                        badge,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF52668D),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
                if (startValue != null && endValue != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FC),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final start = _value(
                          startLabel,
                          startValue!,
                          const Color(0xFF007D83),
                        );
                        final end = _value(
                          endLabel,
                          endValue!,
                          const Color(0xFFCB402A),
                        );
                        final duration = durationLabel == null
                            ? null
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.skyPale,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  durationLabel!,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                        if (constraints.maxWidth < 250 ||
                            MediaQuery.textScalerOf(context).scale(14) > 20) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                spacing: 18,
                                runSpacing: 12,
                                children: [start, end],
                              ),
                              if (duration != null) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: duration,
                                ),
                              ],
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(child: start),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Icon(
                                      LucideIcons.arrowRight,
                                      color: Color(0xFF7A88A4),
                                      size: 14,
                                    ),
                                  ),
                                  Flexible(child: end),
                                ],
                              ),
                            ),
                            if (duration != null) ...[
                              const SizedBox(width: 8),
                              duration,
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    footer!,
                    style: const TextStyle(color: requestMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (canAct || onView != null) ...[
            const Divider(height: 1, color: Color(0xFFF0F1F7)),
            IntrinsicHeight(
              child: Row(
                children: [
                  if (onView != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onView,
                        icon: const Icon(LucideIcons.eye, size: 14),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                  if (canAct && onEdit != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: actionsEnabled ? onEdit : null,
                        icon: const Icon(LucideIcons.pencil, size: 14),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                  if (canAct && onEdit != null && onDelete != null)
                    const VerticalDivider(width: 1, color: Color(0xFFF0F1F7)),
                  if (canAct && onDelete != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: actionsEnabled ? onDelete : null,
                        icon: const Icon(LucideIcons.trash2, size: 14),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFD42621),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RequestHistoryList extends StatelessWidget {
  const RequestHistoryList({
    required this.count,
    required this.itemBuilder,
    required this.loading,
    required this.emptyText,
    this.summary,
    this.error,
    this.onRefresh,
    super.key,
  });
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  final bool loading;
  final String emptyText;
  final Widget? summary;
  final String? error;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!loading && count == 0 && error == null) {
      final empty = CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (summary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: summary,
              ),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyWidget(
              message: emptyText,
              description: 'Requests you submit will show up here.',
            ),
          ),
        ],
      );
      return onRefresh == null
          ? empty
          : RefreshIndicator(onRefresh: onRefresh!, child: empty);
    }
    final list = ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: count + 1,
      itemBuilder: (context, index) {
        if (index > 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: itemBuilder(context, index - 1),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: summary,
              ),
            if (count > 0 || onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request history',
                            style: const TextStyle(
                              color: requestInk,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count ${count == 1 ? 'request' : 'requests'}',
                            style: const TextStyle(
                              color: requestMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRefresh != null)
                      IconButton(
                        tooltip: 'Refresh history',
                        visualDensity: VisualDensity.compact,
                        onPressed: loading ? null : () => onRefresh!(),
                        icon: const Icon(
                          LucideIcons.refreshCw,
                          size: 20,
                          color: requestMuted,
                        ),
                      ),
                  ],
                ),
              ),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: AppLoadingIndicator(size: 24)),
              ),
            if (error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: .25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
                      color: AppColors.danger,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unable to load history',
                            style: TextStyle(
                              color: requestInk,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            error!,
                            style: const TextStyle(
                              color: requestMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (onRefresh != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextButton(
                                onPressed: loading ? null : () => onRefresh!(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: AppColors.danger,
                                ),
                                child: const Text('Try again'),
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
    );
    return list;
  }
}
