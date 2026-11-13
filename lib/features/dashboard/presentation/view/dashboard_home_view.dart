import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/attendance_clock.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ink = Color(0xFF182230);
const _muted = Color(0xFF667085);

class DashboardHomeView extends ConsumerStatefulWidget {
  const DashboardHomeView({super.key});

  @override
  ConsumerState<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends ConsumerState<DashboardHomeView> {
  late final AppLifecycleListener _lifecycle;
  bool _refreshAfterCurrentRequest = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() =>
      ref.read(attendanceViewModelProvider.notifier).todayAttendance();

  void _refreshForNewDay() {
    final attendance = ref.read(attendanceViewModelProvider);
    if (attendance.isLoading || attendance.isFetchingToday) {
      _refreshAfterCurrentRequest = true;
    } else {
      _refresh();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = ref.watch(attendanceViewModelProvider);
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final name = ref.read(appSharedPrefsProvider).getUserName()?.trim();
    ref.listen(currentTimeProvider, (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (before != null &&
          after != null &&
          !DateUtils.isSameDay(before, after)) {
        _refreshForNewDay();
      }
    });
    ref.listen<AttendanceState>(attendanceViewModelProvider, (previous, next) {
      if (_refreshAfterCurrentRequest &&
          !next.isLoading &&
          !next.isFetchingToday) {
        _refreshAfterCurrentRequest = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshForNewDay();
        });
      }
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(context, next.successMessage!);
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final record = attendance.attendance;
    final isToday = record?.isForDate(now) ?? false;
    final todayRecord = isToday ? record : null;
    final start = DateTimeUtils.parseBackendDateTime(todayRecord?.checkIn);
    final end = DateTimeUtils.parseBackendDateTime(todayRecord?.checkout);
    final completedToday = todayRecord?.checkout != null;
    final working = start != null && !completedToday;
    final duration = start == null
        ? Duration.zero
        : (end ?? now).difference(start);
    final elapsed = duration.isNegative ? Duration.zero : duration;
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.blue,
                        AppColors.blueDeep,
                        AppColors.accent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2420A7DB),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateTimeUtils.formatDate(now),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name == null || name.isEmpty
                            ? '$greeting.'
                            : '$greeting, ${name.split(' ').first}.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your workday, all in one place.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (attendance.todayErrorMessage != null) ...[
                  _Surface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Unable to refresh today's attendance",
                          style: TextStyle(
                            color: _ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          attendance.todayErrorMessage!,
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: attendance.isFetchingToday
                              ? null
                              : _refresh,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const _SectionTitle(
                  "Today's attendance",
                  subtitle: 'Track your time at work',
                ),
                const SizedBox(height: 12),
                AttendanceClock(
                  now: now,
                  working: working,
                  completed: completedToday,
                  loading: attendance.isLoading || attendance.isFetchingToday,
                  loadingMessage: attendance.isFetchingToday
                      ? "Loading today's attendance..."
                      : 'Verifying location...',
                  elapsed: elapsed,
                  checkIn: start,
                  onToggle:
                      !attendance.hasLoadedToday ||
                          completedToday ||
                          (record != null && !isToday)
                      ? null
                      : () {
                          final notifier = ref.read(
                            attendanceViewModelProvider.notifier,
                          );
                          if (working) {
                            notifier.clockOutAttendance();
                          } else {
                            notifier.clockInAttendance();
                          }
                        },
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  'Attendance summary',
                  subtitle: 'Your latest recorded session',
                ),
                const SizedBox(height: 12),
                _Surface(
                  child: Column(
                    children: [
                      _SessionRow(
                        icon: Icons.login_rounded,
                        label: 'Clock in',
                        value: start == null
                            ? 'Not recorded'
                            : DateTimeUtils.formatTime(start),
                        date: start,
                      ),
                      const Divider(height: 25, color: Color(0xFFF0F3F7)),
                      _SessionRow(
                        icon: Icons.logout_rounded,
                        label: 'Clock out',
                        value: end == null
                            ? (working ? 'In progress' : 'Not recorded')
                            : DateTimeUtils.formatTime(end),
                        date: end,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  'Quick access',
                  subtitle: 'Everything you need for your workday',
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 560 ? 3 : 2;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                                _Shortcut(
                                  icon: Icons.event_available_rounded,
                                  title: 'Leave request',
                                  subtitle: 'Plan your time off',
                                  color: AppColors.accent,
                                  onTap: () => ref
                                      .read(
                                        dashboardNavigationProvider.notifier,
                                      )
                                      .select(DashboardTab.leave),
                                ),
                                _Shortcut(
                                  icon: Icons.more_time_rounded,
                                  title: 'Overtime request',
                                  subtitle: 'Submit extra working hours',
                                  color: const Color(0xFF94601B),
                                  onTap: () => ref
                                      .read(
                                        dashboardNavigationProvider.notifier,
                                      )
                                      .select(DashboardTab.overtime),
                                ),
                                _Shortcut(
                                  icon: Icons.fact_check_rounded,
                                  title: 'Attendance correction',
                                  subtitle: 'Report a missing entry',
                                  color: const Color(0xFF6C59AA),
                                  onTap: () => ref
                                      .read(
                                        dashboardNavigationProvider.notifier,
                                      )
                                      .select(DashboardTab.missing),
                                ),
                                _Shortcut(
                                  icon: Icons.person_rounded,
                                  title: 'My profile',
                                  subtitle: 'Your employee details',
                                  color: AppColors.accent,
                                  onTap: () => ref
                                      .read(
                                        dashboardNavigationProvider.notifier,
                                      )
                                      .select(DashboardTab.profile),
                                ),
                              ]
                              .map(
                                (tile) => SizedBox(width: width, child: tile),
                              )
                              .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x061C96C5),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: _ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -.3,
        ),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
    ],
  );
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.icon,
    required this.label,
    required this.value,
    this.date,
  });
  final IconData icon;
  final String label;
  final String value;
  final DateTime? date;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent, size: 19),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (date != null)
              Text(
                DateTimeUtils.formatDate(date!),
                textAlign: TextAlign.right,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
          ],
        ),
      ),
    ],
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 160),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .09),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
