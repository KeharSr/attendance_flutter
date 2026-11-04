import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:attendance_flutter/core/common/app_page_background.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_home_view.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/profile_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/bottom_navigation_bar.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key, this.message});

  final String? message;

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  static const _titles = [
    'Overview',
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
    final tab = ref.watch(dashboardNavigationProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppTopBar(
        title: _titles[tab.index],
        actions: [
          IconButton(
            tooltip: tab == DashboardTab.profile ? 'Go to home' : 'My profile',
            onPressed: () => ref
                .read(dashboardNavigationProvider.notifier)
                .select(
                  tab == DashboardTab.profile
                      ? DashboardTab.home
                      : DashboardTab.profile,
                ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF5F6F8),
              foregroundColor: const Color(0xFF344054),
            ),
            icon: Icon(
              tab == DashboardTab.profile
                  ? Icons.home_outlined
                  : Icons.account_circle_outlined,
            ),
          ),
        ],
      ),
      // Mount the selected feature only; hidden request screens need not fetch on startup.
      body: AppPageBackground(
        child: SafeArea(
          top: false,
          child: switch (tab) {
            DashboardTab.home => const DashboardHomeView(),
            DashboardTab.overtime => const OvertimeView(),
            DashboardTab.leave => const LeaveView(),
            DashboardTab.missing => const MissingAttendanceView(),
            DashboardTab.profile => const ProfileView(),
          },
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: tab.index,
        onDestinationSelected: (index) => ref
            .read(dashboardNavigationProvider.notifier)
            .select(DashboardTab.values[index]),
      ),
    );
  }
}
