import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/leave/presentation/view/leave_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_view.dart';
import 'package:attendance_flutter/features/missing_attendance/presentation/view/missing_attendance_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final feature in [
    (
      prefix: 'leave',
      path: '/leave/all',
      view: const LeaveView(),
      empty: 'No leave requests found',
    ),
    (
      prefix: 'overtime',
      path: '/overtime/getAllOvertime',
      view: const OvertimeView(),
      empty: 'No overtime requests found',
    ),
    (
      prefix: 'missing-attendance',
      path: '/missing-attendance/get-all-request',
      view: const MissingAttendanceView(),
      empty: 'No missing attendance requests found',
    ),
  ]) {
    for (final narrow in [false, true]) {
      testWidgets(
        '${feature.prefix} filters reach the API and survive errors (narrow: $narrow)',
        (tester) async {
          if (narrow) {
            tester.view.physicalSize = const Size(320, 640);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
          }
          final client = ApiClient();
          addTearDown(() => client.dio.close(force: true));
          final calls = <Uri>[];
          var fail = false;
          var summary = {
            'total_applied': 40,
            'total_approved': 20,
            'total_pending': 10,
            'total_rejected': 10,
          };
          client.dio.interceptors.clear();
          client.dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                calls.add(options.uri);
                if (fail) {
                  handler.reject(
                    DioException(
                      requestOptions: options,
                      response: Response(
                        requestOptions: options,
                        statusCode: 500,
                      ),
                      type: DioExceptionType.badResponse,
                    ),
                  );
                } else {
                  handler.resolve(
                    Response(
                      requestOptions: options,
                      statusCode: 200,
                      data: {'data': <dynamic>[], 'summary': summary},
                    ),
                  );
                }
              },
            ),
          );
          await tester.pumpWidget(
            ProviderScope(
              overrides: [apiClientProvider.overrideWithValue(client)],
              child: MaterialApp(
                theme: buildAppTheme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(narrow ? 1.8 : 1)),
                  child: child!,
                ),
                home: Scaffold(body: feature.view),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final now = DateTime.now();
          expect(calls.single.path, endsWith(feature.path));
          expect(calls.single.queryParameters, {
            'year': '${now.year}',
            'month': '${now.month}',
          });

          if (!narrow) {
            expect(find.text('40'), findsOneWidget);
            expect(find.text('20'), findsOneWidget);
          }
          summary = {
            'total_applied': 4,
            'total_approved': 2,
            'total_pending': 1,
            'total_rejected': 1,
          };
          final month = now.month == 1 ? 2 : 1;
          await tester.tap(
            find.byKey(ValueKey('${feature.prefix}-month-${now.month}')),
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text(month == 1 ? 'January' : 'February').hitTestable(),
            -200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(month == 1 ? 'January' : 'February').last);
          await tester.pumpAndSettle();
          expect(calls.last.queryParameters, {
            'year': '${now.year}',
            'month': '$month',
          });
          if (!narrow) {
            expect(find.text(feature.empty), findsOneWidget);
            expect(find.text('4'), findsOneWidget);
            expect(find.text('2'), findsOneWidget);
            expect(find.text('Rejected'), findsOneWidget);
          }

          // A failed selection must keep its selected period available for retry.
          fail = true;
          await tester.tap(
            find.byKey(ValueKey('${feature.prefix}-year-${now.year}')),
          );
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('${now.year - 1}').hitTestable(),
            100,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('${now.year - 1}').last);
          await tester.pumpAndSettle();
          final expected = {'year': '${now.year - 1}', 'month': '$month'};
          expect(calls.last.queryParameters, expected);
          expect(
            find.byKey(ValueKey('${feature.prefix}-year-${now.year - 1}')),
            findsOneWidget,
          );
          fail = false;
          // Let the error snackbar dismiss before tapping the underlying retry.
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Try again').hitTestable(),
            150,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Try again'));
          await tester.pumpAndSettle();
          expect(calls.length, 4);
          expect(calls.last.queryParameters, expected);
          expect(find.text('Unable to load history'), findsNothing);

          // Pull-to-refresh uses the same period rather than resetting to today.
          final container = ProviderScope.containerOf(
            tester.element(find.byWidget(feature.view)),
          );
          final refresh = switch (feature.prefix) {
            'leave' =>
              container.read(leaveViewModelProvider.notifier).getAllLeaves(),
            'overtime' =>
              container
                  .read(overtimeViewModelProvider.notifier)
                  .getAllOvertimeRequest(),
            _ =>
              container
                  .read(missingAttendanceViewModelProvider.notifier)
                  .fetchMissingAttendance(),
          };
          await tester.pumpAndSettle();
          await refresh;
          expect(calls.last.queryParameters, expected);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
