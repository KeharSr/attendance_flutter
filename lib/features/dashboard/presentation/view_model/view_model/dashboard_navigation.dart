import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardTab { home, overtime, leave, missing, profile }

final dashboardNavigationProvider =
    NotifierProvider.autoDispose<DashboardNavigation, DashboardTab>(
      DashboardNavigation.new,
    );

class DashboardNavigation extends Notifier<DashboardTab> {
  @override
  DashboardTab build() => DashboardTab.home;

  void select(DashboardTab tab) => state = tab;
}
