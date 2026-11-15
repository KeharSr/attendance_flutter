import 'helpers/attendance_repository_stub.dart';

import 'package:attendance_flutter/features/dashboard/domain/usecase/today_attendance_usecase.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:attendance_flutter/features/leave/presentation/view_model/view_model/leave_view_model.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/view_model/overtime_view_model.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/view_model/missing_attendance_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Leave extends LeaveViewModel {
  @override
  Future<void> getAllLeaves() async {}
}

class _Overtime extends OvertimeViewModel {
  @override
  Future<void> getAllOvertimeRequest() async {}
}

class _Missing extends MissingAttendanceViewModel {
  @override
  Future<void> fetchMissingAttendance() async {}
}

void main() {
  testWidgets('all dashboard pages fit a narrow screen with enlarged text', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsKeys.userNameKey: 'Test Employee',
      SharedPrefsKeys.userPhoneKey: '9800000000',
      SharedPrefsKeys.userIdKey: '42',
    });
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        leaveViewModelProvider.overrideWith(_Leave.new),
        overtimeViewModelProvider.overrideWith(_Overtime.new),
        missingAttendanceViewModelProvider.overrideWith(_Missing.new),
        todayAttendanceUsecaseProvider.overrideWithValue(
          TodayAttendanceUsecase(
            iAttendanceRepository: StubAttendanceRepository(),
          ),
        ),
        currentTimeProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 11, 4, 10)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!,
          ),
          home: const DashboardView(),
        ),
      ),
    );
    for (final tab in DashboardTab.values) {
      container.read(dashboardNavigationProvider.notifier).select(tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab.name);
    }
    expect(find.text('Test Employee'), findsWidgets);
    expect(find.text('9800000000'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
