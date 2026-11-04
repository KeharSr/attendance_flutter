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
    ref.listen<AttendanceState>(attendanceViewModelProvider, (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        AppSnackBar.success(context, next.successMessage!);
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final start = DateTimeUtils.parseBackendDateTime(
      attendance.attendance?.checkIn,
    );
    final end = DateTimeUtils.parseBackendDateTime(
      attendance.attendance?.checkout,
    );
    final working = start != null && end == null;
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                DateTimeUtils.formatDate(now),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name == null || name.isEmpty
                    ? '$greeting.'
                    : '$greeting, ${name.split(' ').first}.',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.9,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View your attendance and manage requests.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 26),
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
                        onPressed: attendance.isFetchingToday ? null : _refresh,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AttendanceClock(
                now: now,
                working: working,
                completed: end != null,
                loading: attendance.isLoading || attendance.isFetchingToday,
                loadingMessage: attendance.isFetchingToday
                    ? "Loading today's attendance..."
                    : 'Verifying location...',
                elapsed: elapsed,
                checkIn: start,
                onToggle: !attendance.hasLoadedToday
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
                'Requests',
                subtitle: 'Manage your work records',
              ),
              const SizedBox(height: 12),
              _Surface(
                child: Column(
                  children: [
                    _Shortcut(
                      icon: Icons.date_range_outlined,
                      title: 'Leave request',
                      subtitle: 'Plan your time off',
                      onTap: () => ref
                          .read(dashboardNavigationProvider.notifier)
                          .select(DashboardTab.leave),
                    ),
                    const Divider(height: 25),
                    _Shortcut(
                      icon: Icons.schedule_outlined,
                      title: 'Overtime request',
                      subtitle: 'Submit extra working hours',
                      onTap: () => ref
                          .read(dashboardNavigationProvider.notifier)
                          .select(DashboardTab.overtime),
                    ),
                    const Divider(height: 25),
                    _Shortcut(
                      icon: Icons.assignment_outlined,
                      title: 'Attendance correction',
                      subtitle: 'Report a missing entry',
                      onTap: () => ref
                          .read(dashboardNavigationProvider.notifier)
                          .select(DashboardTab.missing),
                    ),
                  ],
                ),
              ),
            ],
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
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE4E7EC)),
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
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF667085), size: 19),
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
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _muted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: _muted, size: 20),
        ],
      ),
    ),
  );
}
