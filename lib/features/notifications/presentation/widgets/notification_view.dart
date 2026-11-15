import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:attendance_flutter/core/common/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/presentation/providers/notification_providers.dart';
import 'package:attendance_flutter/features/notifications/presentation/view_model/view_model/notification_inbox.dart';

class NotificationView extends ConsumerStatefulWidget {
  const NotificationView({super.key});

  @override
  ConsumerState<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends ConsumerState<NotificationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationInboxProvider.notifier).reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(notificationInboxProvider);
    Future<void> refresh() =>
        ref.read(notificationInboxProvider.notifier).reload();
    return Scaffold(
      appBar: const AppTopBar(
        automaticallyImplyLeading: true,
        title: 'Notifications',
        subtitle: 'Your latest workplace updates',
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              onRefresh: refresh,
              child: inbox.when(
                loading: () => _status(
                  const CircularProgressIndicator.adaptive(),
                  'Loading notifications...',
                ),
                error: (_, _) => _status(
                  const Icon(
                    LucideIcons.circleAlert,
                    color: AppColors.danger,
                    size: 36,
                  ),
                  'Unable to load notifications',
                  action: TextButton(
                    onPressed: refresh,
                    child: const Text('Try again'),
                  ),
                ),
                data: (messages) => messages.isEmpty
                    ? const CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyWidget(
                              message: 'No notifications yet',
                              description: 'Your received workplace updates will appear here.',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                        itemCount: messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 28),
                        itemBuilder: (_, index) => _NotificationRow(
                          messages[index],
                          onTap: messages[index].destination == null
                              ? null
                              : () => ref
                                    .read(
                                      notificationViewModelProvider.notifier,
                                    )
                                    .handleTap(messages[index]),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(
    Widget icon,
    String title, {
    String? description,
    Widget? action,
  }) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
    children: [
      Center(child: icon),
      const SizedBox(height: 20),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (description != null) ...[
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
      if (action != null) Center(child: action),
    ],
  );
}

String _relativeTime(DateTime? sentAt) {
  if (sentAt == null) return '';
  final elapsed = DateTime.now().difference(sentAt);
  if (elapsed.inMinutes < 1) return 'Just now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes} min ago';
  if (elapsed.inDays < 1) {
    return '${elapsed.inHours} ${elapsed.inHours == 1 ? 'hour' : 'hours'} ago';
  }
  if (elapsed.inDays == 1) return 'Yesterday';
  if (elapsed.inDays < 7) return '${elapsed.inDays} days ago';
  return DateFormat('MMM d, yyyy').format(sentAt.toLocal());
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow(this.item, {this.onTap});

  final AppNotification item;
  final VoidCallback? onTap;

  Color get color {
    if (item.status == 'rejected' ||
        (item.type?.endsWith('_rejected') ?? false)) {
      return AppColors.danger;
    }
    if (item.status == 'approved' ||
        (item.type?.endsWith('_approved') ?? false)) {
      return AppColors.success;
    }
    return AppColors.accent;
  }

  IconData get icon => switch (item.type) {
    'login_success' => LucideIcons.logIn,
    'clock_in' => LucideIcons.alarmClock,
    'clock_out' => LucideIcons.clock,
    'leave_approved' || 'leave_rejected' => LucideIcons.calendarCheck,
    'overtime_approved' || 'overtime_rejected' => LucideIcons.clockPlus,
    'missing_attendance_approved' ||
    'missing_attendance_rejected' => LucideIcons.clipboardCheck,
    _ => LucideIcons.bell,
  };

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackTime =
                  constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(13) > 18;
              final title = Text(
                item.title?.trim().isNotEmpty == true
                    ? item.title!
                    : 'Notification',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              );
              final time = Text(
                _relativeTime(item.sentAt),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  height: 1.8,
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stackTime) ...[
                    title,
                    const SizedBox(height: 2),
                    time,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 10),
                        time,
                      ],
                    ),
                  const SizedBox(height: 5),
                  Text(
                    item.body ?? '',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.65,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
