import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      border: Border(top: BorderSide(color: AppColors.border)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0D1C96C5),
          blurRadius: 24,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accentLight,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            selectedIcon: Icon(LucideIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clockPlus),
            selectedIcon: Icon(LucideIcons.clockPlus),
            label: 'Overtime',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.calendarCheck),
            selectedIcon: Icon(LucideIcons.calendarCheck),
            label: 'Leave',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clipboardCheck),
            selectedIcon: Icon(LucideIcons.clipboardCheck),
            label: 'Missing',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}
