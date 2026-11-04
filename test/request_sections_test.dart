import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/leave/presentation/view_model/view_model/leave_view_model.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/leave_history_card_widget.dart';
import 'package:attendance_flutter/features/leave/domain/entity/leave_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view_model/view_model/missing_attendance_view_model.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Leave extends LeaveViewModel {
  int fetches = 0;
  @override
  Future<void> getAllLeaves() async {
    fetches++;
  }
}

class _Missing extends MissingAttendanceViewModel {
  int fetches = 0;
  @override
  Future<void> fetchMissingAttendance() async {
    fetches++;
  }
}

void main() {
  testWidgets('leave and missing history tabs trigger their providers', (
    tester,
  ) async {
    final leave = _Leave();
    final missing = _Missing();
    for (final view in [const LeaveView(), const MissingAttendanceView()]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            leaveViewModelProvider.overrideWith(() => leave),
            missingAttendanceViewModelProvider.overrideWith(() => missing),
          ],
          child: MaterialApp(home: Scaffold(body: view)),
        ),
      );
      await tester.tap(find.text('History').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
    expect(leave.fetches, 1);
    expect(missing.fetches, 1);
  });
  testWidgets('leave card displays the returned status at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: Scaffold(
            body: ListView(
              children: [
                LeaveHistoryCardWidget(
                  request: LeaveEntity(
                    id: '1',
                    userId: '1',
                    startDate: DateTime(2026, 11, 1),
                    endDate: DateTime(2026, 11, 3),
                    reason:
                        'A family event with relatives visiting from abroad.',
                    status: 'approved',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('bottom bar keeps labels and dispatches the tapped destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentIndex: 0,
            onDestinationSelected: (index) => selected = index,
          ),
        ),
      ),
    );
    for (final label in ['Home', 'Overtime', 'Leave', 'Missing', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Leave'));
    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });
}
