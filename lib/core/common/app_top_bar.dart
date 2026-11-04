import 'package:flutter/material.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.subtitle = 'GBN Store HRMS',
    this.leading,
    this.actions = const [],
    this.showBrand = false,
    this.automaticallyImplyLeading = false,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.ink,
    this.height = 76,
    this.bottom,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool showBrand;
  final bool automaticallyImplyLeading;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: height,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leading: leading,
    titleSpacing: 20,
    bottom: bottom,
    shape: const Border(bottom: BorderSide(color: AppColors.border)),
    title: Row(
      children: [
        if (showBrand && leading == null) ...[
          Image.asset(
            'assets/images/gadgetbyte_logo.jpg',
            width: 40,
            height: 40,
            semanticLabel: 'GBN Store',
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
    actions: [...actions, const SizedBox(width: 12)],
  );
}
