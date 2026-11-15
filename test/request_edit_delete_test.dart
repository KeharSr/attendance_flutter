import 'dart:async';

import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/date_time_utils.dart';
import 'package:attendance_flutter/core/common/request_ui.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/leave/presentation/widgets/edit_leave_dialog.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/widgets/edit_missing_attendance_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Backend {
  final client = ApiClient();
  final calls = <RequestOptions>[];
  late final Map<String, dynamic> leave;
  late final Map<String, dynamic> missing;
  bool deletedLeave = false;
  bool deletedMissing = false;
  bool failMutation = false;
  Completer<void>? pendingMutation;

  _Backend() {
    final today = DateUtils.dateOnly(DateTime.now());
    leave = {
      'id': '1',
      'user_id': '7',
      'start_date': DateTimeUtils.dateOnly(today.add(const Duration(days: 3))),
      'end_date': DateTimeUtils.dateOnly(today.add(const Duration(days: 4))),
      'reason': 'A planned family commitment.',
      'status': 'pending',
    };
    missing = {
      'id': 2,
      'user_id': 7,
      'missing_date': DateTimeUtils.dateOnly(
        today.subtract(const Duration(days: 2)),
      ),
      'requested_check_in': '09:00:00',
      'requested_check_out': '17:00:00',
      'reason': 'The attendance device was unavailable.',
      'status': 'pending',
    };
    client.dio.interceptors.clear();
    client.dio.interceptors.add(InterceptorsWrapper(onRequest: _respond));
  }

  void _respond(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    calls.add(options);
    if (options.method == 'GET') {
      final isLeave = options.path == ApiEndpoints.allLeaveRequest;
      final item = isLeave ? leave : missing;
      final deleted = isLeave ? deletedLeave : deletedMissing;
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': [
              if (!deleted) {...item},
              {...item, 'id': isLeave ? '9' : 9, 'status': 'approved'},
            ],
          },
        ),
      );
      return;
    }
    if (pendingMutation != null) await pendingMutation!.future;
    if (failMutation) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 409,
            data: {'message': 'Only pending requests can be edited or deleted'},
          ),
        ),
      );
      return;
    }
    final isLeave = options.path.contains('/leave/request/');
    final item = isLeave ? leave : missing;
    if (options.method == 'DELETE') {
      if (isLeave) {
        deletedLeave = true;
      } else {
        deletedMissing = true;
      }
    } else {
      final body = options.data as Map;
      if (isLeave) {
        item['start_date'] = body['startDate'];
        item['end_date'] = body['endDate'];
      } else {
        item['missing_date'] = body['missingDate'];
        item['requested_check_in'] = body['requestedCheckIn'];
        item['requested_check_out'] = body['requestedCheckOut'];
      }
      item['reason'] = body['reason'];
    }
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {...item},
        },
      ),
    );
  }

  Iterable<RequestOptions> get mutations =>
      calls.where((call) => call.method != 'GET');
}

void main() {
  for (final isLeave in [true, false]) {
    final feature = isLeave ? 'leave' : 'missing attendance';
    final dialogType = isLeave ? EditLeaveDialog : EditMissingAttendanceDialog;

    Future<_Backend> mount(WidgetTester tester, {double textScale = 1}) async {
      final backend = _Backend();
      addTearDown(() => backend.client.dio.close(force: true));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(backend.client)],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: isLeave ? const LeaveView() : const MissingAttendanceView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return backend;
    }

    testWidgets(
      '$feature edits through all architecture layers and preserves the new-request draft',
      (tester) async {
        final backend = await mount(tester);
        // Only the pending card has actions; the approved card has none.
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).last,
          'An unfinished new request.',
        );
        await tester.tap(find.text('Back to requests'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        final reason = find
            .descendant(
              of: find.byType(dialogType),
              matching: find.byType(TextFormField),
            )
            .last;
        final expectedReason = isLeave
            ? backend.leave['reason']
            : backend.missing['reason'];
        expect(
          tester.widget<TextFormField>(reason).controller!.text,
          expectedReason,
        );
        await tester.enterText(reason, 'Updated request explanation.');
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();
        expect(find.byType(dialogType), findsNothing);
        expect(find.text('Updated request explanation.'), findsOneWidget);
        final mutation = backend.mutations.single;
        expect(mutation.method, 'PATCH');
        expect(
          mutation.path,
          isLeave
              ? ApiEndpoints.editLeave('1')
              : ApiEndpoints.editMissingAttendance('2'),
        );
        expect(
          (mutation.data as Map)['reason'],
          'Updated request explanation.',
        );
        if (isLeave) {
          expect(
            (mutation.data as Map)['startDate'],
            backend.leave['start_date'],
          );
          expect((mutation.data as Map)['endDate'], backend.leave['end_date']);
        } else {
          expect((mutation.data as Map)['requestedCheckIn'], '09:00');
          expect((mutation.data as Map)['requestedCheckOut'], '17:00');
        }
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).last)
              .controller!
              .text,
          'An unfinished new request.',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '$feature deletion requires confirmation and removes only the selected record',
      (tester) async {
        final backend = await mount(tester);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(backend.mutations, isEmpty);
        expect(find.text('2 requests'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pumpAndSettle();
        expect(backend.mutations.single.method, 'DELETE');
        expect(
          backend.mutations.single.path,
          isLeave
              ? ApiEndpoints.deleteLeave('1')
              : ApiEndpoints.deleteMissingAttendance('2'),
        );
        expect(find.byType(RequestHistoryTile), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(RequestHistoryTile),
            matching: find.text('Approved'),
          ),
          findsOneWidget,
        );
        expect(find.text('Edit'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('$feature failed edit keeps the dialog and entered values', (
      tester,
    ) async {
      final backend = await mount(tester)
        ..failMutation = true;
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final reason = find
          .descendant(
            of: find.byType(dialogType),
            matching: find.byType(TextFormField),
          )
          .last;
      await tester.enterText(reason, 'Keep these unsaved changes.');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.byType(dialogType), findsOneWidget);
      expect(
        tester.widget<TextFormField>(reason).controller!.text,
        'Keep these unsaved changes.',
      );
      expect(
        find.text('Only pending requests can be edited or deleted'),
        findsWidgets,
      );
      expect(backend.mutations.length, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('$feature failed delete preserves the list', (tester) async {
      final backend = await mount(tester)
        ..failMutation = true;
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 requests'), findsOneWidget);
      expect(backend.mutations.length, 1);
      expect(
        find.text('Only pending requests can be edited or deleted'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      '$feature actions and edit dialog fit a narrow screen with enlarged text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await mount(tester, textScale: 1.8);
        await tester.ensureVisible(find.text('Edit'));
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        expect(find.byType(dialogType), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '$feature disables duplicate saves while the update is pending',
      (tester) async {
        final backend = await mount(tester);
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        backend.pendingMutation = Completer<void>();
        await tester.tap(find.text('Save changes'));
        for (
          var attempt = 0;
          attempt < 10 && backend.mutations.isEmpty;
          attempt++
        ) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final buttons = tester.widgetList<FilledButton>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(FilledButton),
          ),
        );
        expect(buttons.single.onPressed, isNull);
        expect(backend.mutations.length, 1);
        backend.pendingMutation!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(dialogType), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'missing attendance validates time order and requires at least one corrected time',
    (tester) async {
      final backend = _Backend();
      backend.missing['requested_check_out'] = '08:00:00';
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(backend.client)],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: MissingAttendanceView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Check-out must be after check-in.'), findsOneWidget);
      expect(backend.mutations, isEmpty);
      await tester.tap(find.byTooltip('Clear Requested check-out'));
      await tester.tap(find.byTooltip('Clear Requested check-in'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(
        find.text('Provide at least one check-in or check-out time.'),
        findsOneWidget,
      );
      expect(backend.mutations, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      backend.client.dio.close(force: true);
    },
  );
  testWidgets(
    'missing attendance can save a check-in correction without a check-out',
    (tester) async {
      final backend = _Backend();
      backend.missing['requested_check_out'] = null;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(backend.client)],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: MissingAttendanceView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.byType(EditMissingAttendanceDialog), findsNothing);
      expect(
        (backend.mutations.single.data as Map)['requestedCheckIn'],
        '09:00',
      );
      expect(
        (backend.mutations.single.data as Map)['requestedCheckOut'],
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      backend.client.dio.close(force: true);
    },
  );
}
