import 'package:attendance_flutter/core/common/request_summary.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder metric(String label, String value) => find.descendant(
  of: find
      .ancestor(of: find.text(label), matching: find.byType(Semantics))
      .first,
  matching: find.text(value),
);

void main() {
  test('overtime duration validates API times before totaling hours', () {
    OvertimeEntity request(String? start, String? end) => OvertimeEntity(
      id: '1',
      userId: '1',
      reason: 'Extra work',
      status: 'pending',
      overtimeStartTime: start,
      overtimeEndTime: end,
    );
    expect(request('18:00', '20:30:00').duration, const Duration(minutes: 150));
    expect(
      request('09:15:30', '10:15:45').duration,
      const Duration(hours: 1, seconds: 15),
    );
    expect(request(null, '20:30').duration, isNull);
    expect(request('invalid', '20:30').duration, isNull);
    expect(request('18:60', '20:30').duration, isNull);
    expect(request('20:30', '18:00').duration, isNull);
    expect(request('18:00', '18:00').duration, isNull);
  });

  testWidgets(
    'overtime history summarizes hours by status rather than request counts',
    (tester) async {
      OvertimeEntity request(String status, String start, String end) =>
          OvertimeEntity(
            id: status,
            userId: '1',
            reason: 'Extra work',
            status: status,
            overtimeStartTime: start,
            overtimeEndTime: end,
          );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OvertimeHistoryView(
              requests: [
                request('approved', '18:00:00', '20:30:00'),
                request('pending', '09:15', '10:45'),
                request('cancelled', '13:00', '13:30'),
                request('rejected', '14:00', '15:00'),
              ],
              isLoading: false,
            ),
          ),
        ),
      );
      expect(metric('Total applied', '5.5 hrs'), findsOneWidget);
      expect(metric('Approved', '2.5 hrs'), findsOneWidget);
      expect(metric('Pending', '1.5 hrs'), findsOneWidget);
      expect(metric('Cancelled', '0.5 hrs'), findsOneWidget);
    },
  );

  testWidgets(
    'missing overtime times show unavailable hours rather than zero',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestSummary.hours(
              entries: [(status: 'pending', duration: null)],
            ),
          ),
        ),
      );
      expect(metric('Total applied', '\u2014'), findsOneWidget);
      expect(metric('Pending', '\u2014'), findsOneWidget);
      expect(metric('Approved', '0 hrs'), findsOneWidget);
    },
  );

  testWidgets(
    'summary counts statuses without treating rejected as cancelled',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestSummary(
              statuses: [
                ' Approved ',
                'approved',
                'PENDING',
                'cancelled',
                'Canceled',
                'rejected',
                'unknown',
              ],
            ),
          ),
        ),
      );
      expect(metric('Total applied', '7'), findsOneWidget);
      expect(metric('Approved', '2'), findsOneWidget);
      expect(metric('Pending', '1'), findsOneWidget);
      expect(metric('Cancelled', '2'), findsOneWidget);
    },
  );

  testWidgets('summary distinguishes empty results from unavailable totals', (
    tester,
  ) async {
    for (final loading in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RequestSummary(statuses: const [], loading: loading),
          ),
        ),
      );
      expect(find.text(loading ? '—' : '0'), findsNWidgets(4));
    }
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RequestSummary(statuses: [], unavailable: true)),
      ),
    );
    expect(find.text('—'), findsNWidgets(4));
  });

  testWidgets(
    'summary fits narrow screens with enlarged text and updates totals',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final statuses = ValueNotifier<List<String>>(['pending']);
      addTearDown(statuses.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: statuses,
                builder: (_, value, _) => RequestSummary(statuses: value),
              ),
            ),
          ),
        ),
      );
      expect(metric('Pending', '1'), findsOneWidget);
      statuses.value = ['approved', 'pending'];
      await tester.pump();
      expect(metric('Total applied', '2'), findsOneWidget);
      expect(metric('Approved', '1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
