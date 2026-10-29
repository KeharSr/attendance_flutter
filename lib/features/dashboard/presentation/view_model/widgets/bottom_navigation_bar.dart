import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF1769E0);
    return BottomAppBar(
      height: 76,
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x22102A43),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Destination(
            icon: Icons.more_time_outlined,
            selectedIcon: Icons.more_time_rounded,
            label: 'Overtime',
            selected: currentIndex == 1,
            color: selectedColor,
            onTap: () => onDestinationSelected(1),
          ),
          _Destination(
            icon: Icons.event_outlined,
            selectedIcon: Icons.event_rounded,
            label: 'Leave',
            selected: currentIndex == 2,
            color: selectedColor,
            onTap: () => onDestinationSelected(2),
          ),
          const SizedBox(width: 64),
          _Destination(
            icon: Icons.report_problem_outlined,
            selectedIcon: Icons.report_problem_rounded,
            label: 'Missing',
            selected: currentIndex == 3,
            color: selectedColor,
            onTap: () => onDestinationSelected(3),
          ),
          _Destination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
            selected: currentIndex == 4,
            color: selectedColor,
            onTap: () => onDestinationSelected(4),
          ),
        ],
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = selected ? color : const Color(0xFF98A2B3);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: itemColor, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
