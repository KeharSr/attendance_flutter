import 'dart:async';

import 'package:attendance_flutter/core/api/api_client.dart';
import 'package:attendance_flutter/core/api/api_endpoints.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/error/failure.dart';
import 'package:attendance_flutter/features/dashboard/data/data_source/attendance_data_source.dart';
import 'package:attendance_flutter/features/dashboard/data/repository/attendance_repository_impl.dart';
import 'package:attendance_flutter/features/dashboard/domain/entity/attendance_entity.dart';
import 'package:attendance_flutter/features/dashboard/domain/usecase/today_attendance_usecase.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_home_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/attendance_clock.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/attendance_repository_stub.dart';

AttendanceEntity session({String? checkout}) => AttendanceEntity(
  id: 1,
  userId: 7,
  checkIn: '2026-11-04T08:00:00',
  checkout: checkout,
  workDate: '2026-11-04',
  checkInLatitude: 27.7,
  checkInLongitude: 85.3,
  checkInAccuracyM: 5,
);

void main() {
  test(
    'today endpoint handles both no record and a completed session',
    () async {
      Object? data;
      final apiClient = ApiClient();
      final dio = apiClient.dio;
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'GET');
            expect(options.path, ApiEndpoints.todayAttendance);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': data},
              ),
            );
          },
        ),
      );
      final repository = AttendanceRepositoryImpl(
        attendanceDataSource: AttendanceDataSource(apiClient: apiClient),
      );
      expect(
        await repository.getTodayAttendance(),
        const Right<Failure, AttendanceEntity?>(null),
      );
      data = {
        'id': 1,
        'user_id': 7,
        'check_in': '2026-11-04T08:00:00',
        'check_out': '2026-11-04T12:00:00',
        'work_date': '2026-11-04',
        'check_in_latitude': 27.7,
        'check_in_longitude': 85.3,
        'check_in_accuracy_m': 5,
      };
      expect(
        await repository.getTodayAttendance(),
        Right<Failure, AttendanceEntity?>(
          session(checkout: '2026-11-04T12:00:00'),
        ),
      );
    },
  );

  test(
    'refresh retains the session on failure and clears it for an empty day',
    () async {
      final repo = StubAttendanceRepository()..result = Right(session());
      final container = ProviderContainer(
        overrides: [
          todayAttendanceUsecaseProvider.overrideWithValue(
            TodayAttendanceUsecase(iAttendanceRepository: repo),
          ),
        ],
      );
      addTearDown(container.dispose);
      final vm = container.read(attendanceViewModelProvider.notifier);
      await vm.todayAttendance();
      expect(container.read(attendanceViewModelProvider).attendance, session());
      expect(
        container.read(attendanceViewModelProvider).successMessage,
        isNull,
      );
      repo.result = const Left(ServerFailure(message: 'Offline'));
      await vm.todayAttendance();
      final failed = container.read(attendanceViewModelProvider);
      expect(failed.attendance, session());
      expect(failed.hasLoadedToday, isTrue);
      expect(failed.todayErrorMessage, 'Offline');
      repo.result = const Right(null);
      await vm.todayAttendance();
      expect(container.read(attendanceViewModelProvider).attendance, isNull);
      expect(
        container.read(attendanceViewModelProvider).todayErrorMessage,
        isNull,
      );
    },
  );

  test(
    'duplicate refreshes are ignored and disposal ignores an in-flight result',
    () async {
      final pending = Completer<Either<Failure, AttendanceEntity?>>();
      final repo = StubAttendanceRepository()..onFetch = () => pending.future;
      final container = ProviderContainer(
        overrides: [
          todayAttendanceUsecaseProvider.overrideWithValue(
            TodayAttendanceUsecase(iAttendanceRepository: repo),
          ),
        ],
      );
      final vm = container.read(attendanceViewModelProvider.notifier);
      final request = vm.todayAttendance();
      await vm.todayAttendance();
      expect(repo.fetches, 1);
      expect(
        container.read(attendanceViewModelProvider).isFetchingToday,
        isTrue,
      );
      container.dispose();
      pending.complete(Right(session()));
      await request;
    },
  );

  testWidgets(
    'home restores the running timer, refreshes on resume and freezes a checkout',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ticks = StreamController<DateTime>();
      addTearDown(ticks.close);
      final repo = StubAttendanceRepository()..result = Right(session());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            todayAttendanceUsecaseProvider.overrideWithValue(
              TodayAttendanceUsecase(iAttendanceRepository: repo),
            ),
            currentTimeProvider.overrideWith((ref) => ticks.stream),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: DashboardHomeView()),
          ),
        ),
      );
      ticks.add(DateTime(2026, 11, 4, 10));
      await tester.pumpAndSettle();
      expect(repo.fetches, 1);
      expect(find.widgetWithText(OutlinedButton, 'Clock out'), findsOneWidget);
      expect(find.text('02:00:00'), findsOneWidget);
      ticks.add(DateTime(2026, 11, 4, 10, 0, 1));
      await tester.pumpAndSettle();
      expect(find.text('02:00:01'), findsOneWidget);
      expect(repo.fetches, 1);

      repo.result = Right(session(checkout: '2026-11-04T12:00:00'));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repo.fetches, 2);
      expect(find.text('04:00:00'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Completed for today'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Completed for today'),
            )
            .onPressed,
        isNull,
      );
      final clock = tester.widget<AttendanceClock>(
        find.byType(AttendanceClock),
      );
      expect(clock.completed, isTrue);
      ticks.add(DateTime(2026, 11, 4, 15));
      await tester.pumpAndSettle();
      expect(find.text('04:00:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'initial fetch failure disables the clock action and can be retried',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = StubAttendanceRepository()
        ..result = const Left(ServerFailure(message: 'Offline'));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            todayAttendanceUsecaseProvider.overrideWithValue(
              TodayAttendanceUsecase(iAttendanceRepository: repo),
            ),
            currentTimeProvider.overrideWith(
              (ref) => Stream.value(DateTime(2026, 11, 4, 10)),
            ),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: DashboardHomeView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Unable to refresh today's attendance"), findsOneWidget);
      expect(
        tester.widget<AttendanceClock>(find.byType(AttendanceClock)).onToggle,
        isNull,
      );
      repo.result = const Right(null);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AttendanceClock>(find.byType(AttendanceClock)).onToggle,
        isNotNull,
      );
      expect(find.text("Unable to refresh today's attendance"), findsNothing);
      expect(repo.fetches, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  test('completed work date blocks a second clock-in and clock-out before API/location access', () async {
    final completed = session(checkout: '2026-11-04T12:00:00');
    final repo = StubAttendanceRepository()..result = Right(completed);
    var clockApiReads = 0;
    final container = ProviderContainer(
      overrides: [
        todayAttendanceUsecaseProvider.overrideWithValue(
          TodayAttendanceUsecase(iAttendanceRepository: repo),
        ),
        currentTimeProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 11, 4, 15)),
        ),
        clockInUseCaseProvider.overrideWith((ref) {
          clockApiReads++;
          throw StateError('Clock-in must not run');
        }),
        clockOutUseCaseProvider.overrideWith((ref) {
          clockApiReads++;
          throw StateError('Clock-out must not run');
        }),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(currentTimeProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(currentTimeProvider.future);
    final vm = container.read(attendanceViewModelProvider.notifier);
    await vm.todayAttendance();
    await vm.clockInAttendance();
    expect(
      container.read(attendanceViewModelProvider).errorMessage,
      'Attendance is completed for today. You can clock in tomorrow.',
    );
    await vm.clockOutAttendance();
    expect(
      container.read(attendanceViewModelProvider).errorMessage,
      'You have already clocked out today.',
    );
    expect(container.read(attendanceViewModelProvider).attendance, completed);
    expect(clockApiReads, 0);
  });

  test(
    'work dates compare calendar fields without shifting UTC date-only values',
    () {
      final completed = session(checkout: '2026-11-04T12:00:00');
      expect(completed.isForDate(DateTime(2026, 11, 4, 23, 59)), isTrue);
      expect(completed.isForDate(DateTime(2026, 11, 5)), isFalse);
      final timestampWorkDate = AttendanceEntity(
        id: 1,
        userId: 7,
        checkIn: completed.checkIn,
        checkout: completed.checkout,
        workDate: '2026-11-04T00:00:00.000Z',
        checkInLatitude: 27.7,
        checkInLongitude: 85.3,
        checkInAccuracyM: 5,
      );
      expect(timestampWorkDate.isForDate(DateTime(2026, 11, 4)), isTrue);
      expect(timestampWorkDate.isForDate(DateTime(2026, 11, 5)), isFalse);
    },
  );

  testWidgets(
    'completed attendance stays disabled until tomorrow has been refreshed',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ticks = StreamController<DateTime>();
      addTearDown(ticks.close);
      final repo = StubAttendanceRepository()
        ..result = Right(session(checkout: '2026-11-04T12:00:00'));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            todayAttendanceUsecaseProvider.overrideWithValue(
              TodayAttendanceUsecase(iAttendanceRepository: repo),
            ),
            currentTimeProvider.overrideWith((ref) => ticks.stream),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: DashboardHomeView()),
          ),
        ),
      );
      ticks.add(DateTime(2026, 11, 4, 23, 59, 59));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Completed for today'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<AttendanceClock>(find.byType(AttendanceClock)).onToggle,
        isNull,
      );
      final tomorrow = Completer<Either<Failure, AttendanceEntity?>>();
      repo.onFetch = () => tomorrow.future;
      ticks.add(DateTime(2026, 11, 5));
      await tester.pump();
      await tester.pump();
      expect(repo.fetches, 2);
      expect(
        tester
            .widget<OutlinedButton>(find.byType(OutlinedButton).first)
            .onPressed,
        isNull,
      );
      tomorrow.complete(const Right(null));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(OutlinedButton, 'Completed for today'),
        findsNothing,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Clock in'),
            )
            .onPressed,
        isNotNull,
      );
      final clock = tester.widget<AttendanceClock>(
        find.byType(AttendanceClock),
      );
      expect(clock.completed, isFalse);
      expect(clock.elapsed, Duration.zero);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a failed next-day refresh does not reenable a stale completed session',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ticks = StreamController<DateTime>();
      addTearDown(ticks.close);
      final repo = StubAttendanceRepository()
        ..result = Right(session(checkout: '2026-11-04T12:00:00'));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            todayAttendanceUsecaseProvider.overrideWithValue(
              TodayAttendanceUsecase(iAttendanceRepository: repo),
            ),
            currentTimeProvider.overrideWith((ref) => ticks.stream),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: DashboardHomeView()),
          ),
        ),
      );
      ticks.add(DateTime(2026, 11, 4, 23, 59));
      await tester.pumpAndSettle();
      repo.result = const Left(ServerFailure(message: 'Offline'));
      ticks.add(DateTime(2026, 11, 5));
      await tester.pumpAndSettle();
      expect(find.text("Unable to refresh today's attendance"), findsOneWidget);
      expect(
        tester.widget<AttendanceClock>(find.byType(AttendanceClock)).onToggle,
        isNull,
      );
      repo.result = const Right(null);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AttendanceClock>(find.byType(AttendanceClock)).onToggle,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
