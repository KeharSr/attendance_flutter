import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.subtitle = 'GBN Store HRMS',
    this.leading,
    this.actions = const [],
    this.showBrand = false,
    this.automaticallyImplyLeading = false,
    this.backgroundColor = AppColors.skyPale,
    this.foregroundColor = AppColors.ink,
    this.height = 56,
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
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    elevation: 0,
    scrolledUnderElevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
    ),
    clipBehavior: Clip.antiAlias,
    flexibleSpace: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5FCFF),
            backgroundColor,
            AppColors.skyLight,
          ],
        ),
      ),
    ),
    titleSpacing: leading == null && !automaticallyImplyLeading ? 20 : 8,
    bottom: bottom,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    ),
    actions: [...actions, const SizedBox(width: 12)],
  );
}
