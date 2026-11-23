import 'package:attendance_flutter/core/common/styled_request_ui.dart';
import 'package:attendance_flutter/core/common/compact_request_card.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_history_view.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_detail_view.dart';
import 'package:attendance_flutter/features/missing_attendance/domain/entity/missing_attendance_entity.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_history_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_detail_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/widgets/missing_attendance_history_card_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  test(
    'leave days count calendar dates inclusively across month boundaries',
    () {
      expect(
        leaveDaysLabel(DateTime(2026, 11, 30), DateTime(2026, 12, 2)),
        '3 days',
      );
      expect(
        leaveDaysLabel(DateTime(2026, 11, 30), DateTime(2026, 11, 30)),
        '1 day',
      );
    },
  );

  testWidgets('leave and attendance cards open matching detail pages', (
    tester,
  ) async {
    final leave = LeaveEntity(
      id: 'leave',
      userId: '1',
      startDate: DateTime(2026, 11, 11),
      endDate: DateTime(2026, 11, 12),
      reason: 'Family event',
      status: 'approved',
    );
    const missing = MissingAttendanceEntity(
      id: 'missing',
      userId: '1',
      missingDate: '2026-11-11',
      requestedCheckIn: '08:00:00',
      requestCheckOut: '',
      reason: 'Forgot check-in',
      status: 'pending',
    );
    for (final history in [
      LeaveHistoryView(requests: [leave], isLoading: false),
      const MissingAttendanceHistoryView(requests: [missing], isLoading: false),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: history)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CompactRequestCard));
      await tester.pumpAndSettle();
      expect(find.text('Employee Request'), findsOneWidget);
      expect(find.text('Administrator Approval'), findsOneWidget);
      if (history is LeaveHistoryView) {
        expect(find.byType(LeaveDetailView), findsOneWidget);
        expect(find.text('2 days'), findsOneWidget);
      } else {
        expect(find.byType(MissingAttendanceDetailView), findsOneWidget);
        expect(find.text('Not requested'), findsOneWidget);
        expect(find.text('1 update'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'missing card supports enlarged text and disables pending actions while loading',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var edits = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: Scaffold(
              body: ListView(
                children: [
                  MissingAttendanceHistoryCardWidget(
                    request: const MissingAttendanceEntity(
                      id: '1',
                      userId: '1',
                      missingDate: '2026-11-11',
                      requestedCheckIn: '',
                      requestCheckOut: '17:00:00',
                      reason: 'Forgot to record check-out after completing the shift.',
                      status: 'pending',
                    ),
                    actionsEnabled: false,
                    onEdit: () => edits++,
                    onDelete: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('1 update'), findsOneWidget);
      expect(find.text('Not requested'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Edit request'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit request'));
      expect(edits, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'missing attendance calendar ends today and rejects future text input',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            missingAttendanceViewModelProvider.overrideWith(_Missing.new),
          ],
          child: const MaterialApp(
            home: Scaffold(body: MissingAttendanceView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      final today = DateUtils.dateOnly(DateTime.now());
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.lastDate, today);
      expect(picker.firstDate.isAfter(today), isFalse);
      await tester.tap(find.byIcon(LucideIcons.pencil));
      await tester.pumpAndSettle();
      final future = today.add(const Duration(days: 1));
      final field = find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(
        field,
        '${future.month}/${future.day}/${future.year}',
      );
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Out of range.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'leave and missing lists load immediately and Add opens their forms',
    (tester) async {
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
        await tester.pumpAndSettle();
        expect(find.byType(TabBar), findsNothing);
        expect(find.byType(TextFormField), findsNothing);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.byType(FloatingActionButton), findsNothing);
        await tester.tap(find.text('Back to requests'));
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
      expect(leave.fetches, 1);
      expect(missing.fetches, 1);
    },
  );
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
