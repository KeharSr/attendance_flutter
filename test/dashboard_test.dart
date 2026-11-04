import 'helpers/attendance_repository_stub.dart';

import 'package:attendance_flutter/features/dashboard/domain/usecase/today_attendance_usecase.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_home_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/state/attendance_state.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/attendance_view_model.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/view_model/dashboard_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LoadingAttendance extends AttendanceViewModel {
  @override
  AttendanceState build() => const AttendanceState(isLoading: true);
}

void main() {
  test('dashboard navigation selects all destinations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      dashboardNavigationProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    expect(container.read(dashboardNavigationProvider), DashboardTab.home);
    for (final tab in DashboardTab.values) {
      container.read(dashboardNavigationProvider.notifier).select(tab);
      expect(container.read(dashboardNavigationProvider), tab);
    }
  });

  testWidgets('home adapts to enlarged text and shortcuts update Riverpod', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsKeys.userNameKey: 'Test Employee',
    });
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        todayAttendanceUsecaseProvider.overrideWithValue(
          TodayAttendanceUsecase(
            iAttendanceRepository: StubAttendanceRepository(),
          ),
        ),
        currentTimeProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 11, 1, 10)),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      dashboardNavigationProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.8),
            ),
            child: Scaffold(body: DashboardHomeView()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Good morning, Test.'), findsOneWidget);
    expect(find.text('Clock in'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Plan your time off'), 150);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.text('Plan your time off')),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan your time off'));
    await tester.pump();
    expect(container.read(dashboardNavigationProvider), DashboardTab.leave);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('attendance action is disabled while verifying location', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todayAttendanceUsecaseProvider.overrideWithValue(
            TodayAttendanceUsecase(
              iAttendanceRepository: StubAttendanceRepository(),
            ),
          ),
          attendanceViewModelProvider.overrideWith(_LoadingAttendance.new),
        ],
        child: const MaterialApp(home: Scaffold(body: DashboardHomeView())),
      ),
    );
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Please wait'),
    );
    expect(button.onPressed, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
