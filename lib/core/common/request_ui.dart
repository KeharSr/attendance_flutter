import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';

const requestInk = AppColors.ink;
const requestMuted = AppColors.muted;
const requestAccent = AppColors.accent;

const _surface = Colors.white;
const _subtle = Color(0xFFF8FAFC); // soft panel background
const _hairline = Color(0xFFE4E7EC);
const _warning = Color(0xFFB54708);

const _cardShadow = [
  BoxShadow(color: Color(0x0F101828), blurRadius: 12, offset: Offset(0, 4)),
  BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1)),
];

InputDecoration requestInput(String hint, {IconData? icon, String? suffix}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
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
  const RequestLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: requestInk,
        fontSize: 13,
        fontWeight: FontWeight.w600,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: loading
          ? const AppLoadingIndicator(size: 20, strokeWidth: 2)
          : Text(label),
    ),
  );
}

class RequestTabs extends StatefulWidget {
  const RequestTabs({
    required this.request,
    required this.history,
    required this.onHistory,
    super.key,
  });
  final Widget request;
  final Widget history;
  final VoidCallback onHistory;
  @override
  State<RequestTabs> createState() => _RequestTabsState();
}

class _RequestTabsState extends State<RequestTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _lastIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_lastIndex == _tabs.index) return;
        _lastIndex = _tabs.index;
        if (_lastIndex == 1) widget.onHistory();
      });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabs,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(9),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A101828),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: requestAccent,
                unselectedLabelColor: requestMuted,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'New request'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [widget.request, widget.history],
            ),
          ),
        ],
      ),
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
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: _cardShadow,
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
    this.onEdit,
    this.onDelete,
    this.actionsEnabled = true,
    this.icon,
    this.footer,
    super.key,
  });
  final String title;
  final String detail;
  final String reason;
  final String status;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool actionsEnabled;

  final IconData? icon;

  final String? footer;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final color = switch (normalized) {
      'approved' => AppColors.success,
      'rejected' => AppColors.danger,
      'pending' => _warning,
      _ => requestMuted,
    };
    final statusIcon = switch (normalized) {
      'approved' => Icons.check_circle_rounded,
      'rejected' => Icons.cancel_rounded,
      'pending' => Icons.schedule_rounded,
      _ => Icons.help_rounded,
    };
    final statusLabel = normalized.isEmpty
        ? 'Unknown'
        : normalized[0].toUpperCase() + normalized.substring(1);
    final canAct =
        normalized == 'pending' && (onEdit != null || onDelete != null);

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Keep the status beside the date when space permits, and wrap
                // it below the date on narrow screens or at large text sizes.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon ?? Icons.description_outlined,
                        color: color,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: requestInk,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(7, 4, 10, 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 14, color: color),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            detail,
                            style: const TextStyle(
                              color: requestMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Reason panel
                if (reason.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _subtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reason',
                          style: TextStyle(
                            color: requestMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason,
                          style: const TextStyle(
                            color: requestInk,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF98A2B3),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          footer!,
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (canAct) ...[
            const Divider(height: 1, color: _hairline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: actionsEnabled ? onDelete : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                    ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: actionsEnabled ? onEdit : null,
                      style: TextButton.styleFrom(
                        foregroundColor: requestAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ],
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
    this.error,
    this.onRefresh,
    super.key,
  });
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  final bool loading;
  final String emptyText;
  final String? error;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
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
            if (count > 0 || onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$count ${count == 1 ? 'request' : 'requests'}',
                        style: const TextStyle(
                          color: requestMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (onRefresh != null)
                      IconButton(
                        tooltip: 'Refresh history',
                        visualDensity: VisualDensity.compact,
                        onPressed: loading ? null : () => onRefresh!(),
                        icon: const Icon(
                          Icons.refresh_rounded,
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
                      Icons.error_outline_rounded,
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
            if (!loading && count == 0 && error == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: requestAccent.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          color: requestAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        emptyText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: requestInk,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Requests you submit will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: requestMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
    return onRefresh == null
        ? list
        : RefreshIndicator(
            onRefresh: onRefresh!,
            color: requestAccent,
            child: list,
          );
  }
}
