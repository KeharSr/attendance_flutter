import 'package:attendance_flutter/core/common/request_summary.dart';
import 'package:attendance_flutter/core/data/model/request_list_model.dart';
import 'package:attendance_flutter/core/domain/entity/request_summary_entity.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder metric(String label, String value) => find.descendant(
  of: find
      .ancestor(of: find.text(label), matching: find.byType(Semantics))
      .first,
  matching: find.text(value),
);

const serverSummary = RequestSummaryEntity(
  totalApplied: 4,
  totalApproved: 2,
  totalPending: 1,
  totalRejected: 1,
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

  test('list response maps server summary independently of list contents', () {
    final page = RequestListModel<String>.fromJson({
      'data': [
        {'id': 'only-one-record'},
      ],
      'summary': {
        'total_applied': 4,
        'total_approved': 2,
        'total_pending': 1,
        'total_rejected': 1,
      },
    }, (json) => json['id'] as String).toEntity((item) => item);
    expect(page.requests, ['only-one-record']);
    expect(page.summary, serverSummary);
    final missing = RequestListModel<String>.fromJson({
      'data': [],
    }, (json) => '').toEntity((item) => item);
    expect(missing.summary, isNull);
  });

  testWidgets('summary displays server totals and rejected label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RequestSummary(summary: serverSummary)),
      ),
    );
    expect(metric('Total applied', '4'), findsOneWidget);
    expect(metric('Approved', '2'), findsOneWidget);
    expect(metric('Pending', '1'), findsOneWidget);
    expect(metric('Rejected', '1'), findsOneWidget);
    expect(find.text('Cancelled'), findsNothing);
    expect(find.textContaining('hrs'), findsNothing);
  });

  testWidgets(
    'missing, loading, and failed summaries show unavailable values',
    (tester) async {
      for (final widget in [
        const RequestSummary(),
        const RequestSummary(summary: serverSummary, loading: true),
        const RequestSummary(summary: serverSummary, unavailable: true),
      ]) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.text('\u2014'), findsNWidgets(4));
      }
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestSummary(
              summary: RequestSummaryEntity(
                totalApplied: 0,
                totalApproved: 0,
                totalPending: 0,
                totalRejected: 0,
              ),
            ),
          ),
        ),
      );
      expect(find.text('0'), findsNWidgets(4));
    },
  );

  testWidgets('server summary updates fit narrow screens with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final summary = ValueNotifier<RequestSummaryEntity>(serverSummary);
    addTearDown(summary.dispose);
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
            child: ValueListenableBuilder<RequestSummaryEntity>(
              valueListenable: summary,
              builder: (_, value, _) => RequestSummary(summary: value),
            ),
          ),
        ),
      ),
    );
    expect(metric('Total applied', '4'), findsOneWidget);
    summary.value = const RequestSummaryEntity(
      totalApplied: 30,
      totalApproved: 20,
      totalPending: 7,
      totalRejected: 3,
    );
    await tester.pump();
    expect(metric('Total applied', '30'), findsOneWidget);
    expect(metric('Approved', '20'), findsOneWidget);
    expect(metric('Rejected', '3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
