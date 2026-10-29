import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_home_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/missing_attendance_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/overtime_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/profile_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, this.message});

  final String? message;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  static const _titles = [
    'Dashboard',
    'Overtime',
    'Leave',
    'Missing attendance',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppSnackBar.success(context, widget.message!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardHomeView(),
      const OvertimeView(),
      const LeaveView(),
      const MissingAttendanceView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                AppSnackBar.info(context, 'You are all caught up.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _currentIndex = 0);
        },
        backgroundColor: const Color(0xFF1769E0),
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Attendance',
        child: const Icon(Icons.access_time_rounded, size: 25),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
