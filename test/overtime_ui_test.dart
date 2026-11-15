import 'package:attendance_flutter/features/overtime/presentation/widgets/overtime_history_card_widget.dart';
import 'package:attendance_flutter/features/overtime/presentation/widgets/overtime_ui.dart';
import 'package:attendance_flutter/features/overtime/data/model/overtime_api_model.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_detail_view.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/view_model/overtime_view_model.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:attendance_flutter/features/overtime/presentation/widgets/edit_overtime_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOvertime extends OvertimeViewModel {
  int fetches = 0;
  String? submittedWorkDate;
  String? startTime;
  String? endTime;
  @override
  Future<void> createOvertimeRequest({
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    submittedWorkDate = workDate;
    startTime = overtimeStartTime;
    endTime = overtimeEndTime;
    state = state.copyWith(
      successMessage: 'Overtime request submitted for review.',
      overtime: [
        OvertimeEntity(
          id: 'new',
          userId: '1',
          workDate: workDate,
          overtimeStartTime: overtimeStartTime,
          overtimeEndTime: overtimeEndTime,
          reason: reason,
          status: 'pending',
        ),
      ],
    );
  }

  String? editedId;
  @override
  Future<void> editOvertimeRequest({
    required String overtimeId,
    required String workDate,
    required String overtimeStartTime,
    required String overtimeEndTime,
    required String reason,
  }) async {
    editedId = overtimeId;
    submittedWorkDate = workDate;
    startTime = overtimeStartTime;
    endTime = overtimeEndTime;
  }

  @override
  OvertimeState build() => OvertimeState.initial();
  @override
  Future<void> getAllOvertimeRequest() async {
    fetches++;
  }
}

void main() {
  test('approval metadata survives API and entity conversion', () {
    final model = OvertimeApiModel.fromJson({
      'id': '7',
      'user_id': '1',
      'work_date': '2026-11-11',
      'reason': 'Need to work',
      'status': 'approved',
      'overtime_start_time': '08:00:00',
      'overtime_end_time': '10:00:00',
      'overtime_approve_start_time': '08:00:00',
      'overtime_approve_end_time': '09:00:00',
      'overtime_requested_hours': 2,
      'overtime_accepted_hours': 1,
      'admin_comment': 'okay this is it',
      'created_at': '2026-11-15T06:54:00',
      'updated_at': '2026-11-15T07:06:00',
    });
    final restored = OvertimeApiModel.fromEntity(model.toEntity()).toJson();
    expect(restored['overtime_approve_end_time'], '09:00:00');
    expect(restored['overtime_requested_hours'], 2);
    expect(restored['overtime_accepted_hours'], 1);
    expect(model.toEntity().overtimeAcceptedHours, 1);
    expect(restored['admin_comment'], 'okay this is it');
    expect(restored['created_at'], '2026-11-15T06:54:00');
  });

  test('hours use API totals and support fractional and zero hours', () {
    expect(overtimeHours('08:00', '10:00', hours: 1.5), '1.5 hours');
    expect(overtimeHours(null, null, hours: 0), '0 hours');
    expect(overtimeHours(null, null, hours: 1), '1 hour');
    expect(overtimeHours('08:00', '10:00'), '2 hours');
  });

  testWidgets('API response fills the card and detail approval fields', (
    tester,
  ) async {
    final request = OvertimeApiModel.fromJson({
      'id': '7',
      'user_id': '1',
      'work_date': '2026-11-11T18:15:00.000Z',
      'reason': 'Need to work',
      'status': 'approved',
      'overtime_start_time': '08:00:00',
      'overtime_end_time': '10:00:00',
      'overtime_approve_start_time': '08:00:00',
      'overtime_approve_end_time': '09:00:00',
      'overtime_requested_hours': 2.5,
      'overtime_accepted_hours': 0.5,
      'admin_comment': 'okay this is it',
      'created_at': '2026-11-15T06:54:00.424Z',
      'updated_at': '2026-11-15T07:06:35.272Z',
    }).toEntity();
    for (final page in [
      Scaffold(body: OvertimeHistoryCardWidget(request: request)),
      OvertimeDetailView(requestId: '7', requests: [request]),
    ]) {
      await tester.pumpWidget(MaterialApp(home: page));
      expect(find.text('2.5 hours'), findsOneWidget);
      expect(find.text('0.5 hours'), findsOneWidget);
      expect(find.text('Not provided'), findsNothing);
      if (page is OvertimeDetailView) {
        expect(find.text('okay this is it'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('details distinguish requested and accepted hours', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: OvertimeDetailView(
          requestId: '7',
          requests: [
            OvertimeEntity(
              id: '7',
              userId: '1',
              workDate: '2026-11-11',
              reason: 'Need to work',
              status: 'approved',
              overtimeStartTime: '08:00:00',
              overtimeEndTime: '10:00:00',
              overtimeApproveStartTime: '08:00:00',
              overtimeApproveEndTime: '09:00:00',
              adminComment: 'okay this is it',
            ),
          ],
        ),
      ),
    );
    expect(find.text('Employee Request'), findsOneWidget);
    expect(find.text('Administrator Approval'), findsOneWidget);
    expect(find.text('2 hours'), findsOneWidget);
    expect(find.text('1 hour'), findsOneWidget);
    expect(find.text('okay this is it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('request list loads on opening without tabs', (tester) async {
    final fake = FakeOvertime();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [overtimeViewModelProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: OvertimeView())),
      ),
    );
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.pumpAndSettle();
    expect(fake.fetches, 1);
    expect(find.text('No overtime requests found'), findsOneWidget);
  });

  testWidgets('request requires a work date and both overtime times', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [overtimeViewModelProvider.overrideWith(FakeOvertime.new)],
        child: const MaterialApp(home: Scaffold(body: OvertimeView())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(find.text('Select a work date.'), findsOneWidget);
    expect(find.text('Select an overtime start time.'), findsOneWidget);
    expect(find.text('Select an overtime end time.'), findsOneWidget);
  });

  testWidgets(
    'time requests validate the range and submit the date and times',
    (tester) async {
      final fake = FakeOvertime();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [overtimeViewModelProvider.overrideWith(() => fake)],
          child: const MaterialApp(home: Scaffold(body: OvertimeView())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      fake.setWorkDate(DateTime(2026, 11, 1));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields.length, 4);
      final inputs = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(inputs[0].readOnly, isTrue);
      expect(inputs[1].readOnly, isTrue);
      fields[1].controller!.text = '18:00';
      fields[2].controller!.text = '17:00';
      fields[3].controller!.text = 'Complete inventory review';
      await tester.ensureVisible(find.text('Submit request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit request'));
      await tester.pumpAndSettle();
      expect(
        find.text('End time must be later than start time.'),
        findsOneWidget,
      );
      expect(fake.startTime, isNull);
      fields[2].controller!.text = '20:30';
      await tester.ensureVisible(find.text('Submit request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit request'));
      await tester.pumpAndSettle();
      expect(fake.submittedWorkDate, '2026-11-01');
      expect(fake.startTime, '18:00');
      expect(fake.endTime, '20:30');
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Complete inventory review'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).last)
            .controller!
            .text,
        isEmpty,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets(
    'edit prefills times, validates the range and saves date and times',
    (tester) async {
      final fake = FakeOvertime();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [overtimeViewModelProvider.overrideWith(() => fake)],
          child: const MaterialApp(
            home: Scaffold(
              body: EditOvertimeDialog(
                request: OvertimeEntity(
                  id: "7",
                  userId: "1",
                  workDate: '2026-11-01',
                  overtimeStartTime: '18:00:00',
                  overtimeEndTime: '20:30:00',
                  reason: 'Complete inventory review',
                  status: 'pending',
                ),
              ),
            ),
          ),
        ),
      );
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields.length, 4);
      expect(fields[0].initialValue, 'Nov 1, 2026');
      expect(fields[1].controller!.text, '18:00');
      expect(fields[2].controller!.text, '20:30');
      fields[2].controller!.text = '17:00';
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(
        find.text('End time must be later than start time.'),
        findsOneWidget,
      );
      expect(fake.editedId, isNull);
      fields[2].controller!.text = '21:15';
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(fake.editedId, '7');
      expect(fake.submittedWorkDate, '2026-11-01');
      expect(fake.startTime, '18:00');
      expect(fake.endTime, '21:15');
    },
  );

  testWidgets('history accommodates long reasons and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.8),
          ),
          child: Scaffold(
            body: OvertimeHistoryView(
              isLoading: false,
              requests: [
                OvertimeEntity(
                  id: " 1",
                  userId: "1",
                  workDate: '2026-11-01',
                  overtimeStartTime: '18:00:00',
                  overtimeEndTime: '20:30:00',
                  reason: 'Completed the inventory review and prepared the monthly report for the team.',
                  status: 'approved',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Completed the inventory'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
