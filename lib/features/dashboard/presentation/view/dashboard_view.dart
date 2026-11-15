import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_top_bar.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_home_view.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_view.dart';
import 'package:attendance_flutter/features/notifications/presentation/widgets/notification_view.dart';
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
      appBar: AppTopBar(
        title: _titles[tab.index],
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const NotificationView()),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accent,
            ),
            icon: const Icon(LucideIcons.bell),
          ),
        ],
      ),
      // Mount the selected feature only; hidden request screens need not fetch on startup.
      body: SafeArea(
        top: false,
        child: switch (tab) {
          DashboardTab.home => const DashboardHomeView(),
          DashboardTab.overtime => const OvertimeView(),
          DashboardTab.leave => const LeaveView(),
          DashboardTab.missing => const MissingAttendanceView(),
          DashboardTab.profile => const ProfileView(),
        },
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
