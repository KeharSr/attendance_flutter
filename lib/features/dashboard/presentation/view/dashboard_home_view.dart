import 'dart:async';

import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardHomeView extends ConsumerStatefulWidget {
  const DashboardHomeView({super.key});

  @override
  ConsumerState<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends ConsumerState<DashboardHomeView> {
  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceViewModelProvider);
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _PageIntro(date: now),
        const SizedBox(height: 22),
        _AttendanceCard(
          isClockedIn: _isClockedIn,
          clockInAt: DateTime.parse(attendanceState.attendance!.checkIn),
          elapsed: _elapsed,
          onToggle: () {
            ref
                .read(attendanceViewModelProvider.notifier)
                .clockInEvent(latitude: 17.06, longitude: 85.04, accuracy: 50);
          },
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Today'),
        const SizedBox(height: 10),
        const _TodayDetails(),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Overview'),
        const SizedBox(height: 10),
        const _OverviewGrid(),
      ],
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good afternoon, Kehar',
                style: TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage your workday in one place.',
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
        Text(
          _formatDate(date),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.isClockedIn,
    required this.clockInAt,
    required this.elapsed,
    required this.onToggle,
  });

  final bool isClockedIn;
  final DateTime? clockInAt;
  final Duration elapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final accent = isClockedIn
        ? const Color(0xFFB42318)
        : const Color(0xFF1769E0);
    final statusColor = isClockedIn
        ? const Color(0xFF14804A)
        : const Color(0xFF667085);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A102A43),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance',
                  style: TextStyle(
                    color: Color(0xFF102A43),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isClockedIn ? 'Working now' : 'Not clocked in',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .06),
                border: Border.all(
                  color: accent.withValues(alpha: .18),
                  width: 10,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: .25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isClockedIn
                          ? Icons.stop_circle_outlined
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isClockedIn ? 'Clock out' : 'Clock in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isClockedIn) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatDuration(elapsed),
                        style: const TextStyle(
                          color: Color(0xD9FFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isClockedIn
                ? 'You started at ${_formatTime(clockInAt!)}'
                : 'Tap the button when you start your workday',
            style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TodayDetails extends StatelessWidget {
  const _TodayDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          _DetailRow(
            icon: Icons.login_rounded,
            label: 'Scheduled shift',
            value: '09:00 AM – 05:00 PM',
          ),
          Divider(height: 1, indent: 58),
          _DetailRow(
            icon: Icons.free_breakfast_outlined,
            label: 'Break',
            value: '1 hour',
          ),
          Divider(height: 1, indent: 58),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Expected hours',
            value: '8 hours',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF102A43),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1769E0), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.more_time_rounded, 'Overtime', '02h 30m', Color(0xFF7C3AED)),
      (
        Icons.event_available_rounded,
        'Leave balance',
        '12 days',
        Color(0xFF14804A),
      ),
      (
        Icons.report_problem_outlined,
        'Missing attendance',
        '1 pending',
        Color(0xFFD97706),
      ),
      (
        Icons.calendar_month_rounded,
        'Present this month',
        '18 days',
        Color(0xFF1769E0),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.$1, color: item.$4, size: 21),
              const Spacer(),
              Text(
                item.$2,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                item.$3,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
