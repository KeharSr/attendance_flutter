import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/service/shared_prefs/app_shared_prefs.dart';
import 'package:attendance_flutter/features/notifications/data/data_source/notification_local_data_source.dart';
import 'package:attendance_flutter/features/notifications/data/model/notification_model.dart';
import 'package:attendance_flutter/features/notifications/domain/entity/app_notification.dart';
import 'package:attendance_flutter/features/notifications/presentation/view_model/view_model/notification_inbox.dart';
import 'package:attendance_flutter/features/notifications/presentation/widgets/notification_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'opening notifications refreshes an inbox cached before disk delivery',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.isUserLoggedIn: true,
        SharedPrefsKeys.userIdKey: 'employee-a',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authSessionProvider.notifier).markLoggedIn();
      expect(await container.read(notificationInboxProvider.future), isEmpty);
      await NotificationLocalDataSource(preferences: prefs).saveNotification(
        'employee-a',
        const AppNotification(
          id: 'background-event',
          title: 'Previously received update',
          body: 'Saved after the first inbox read.',
        ),
      );
      // State remains cached until the screen explicitly reloads from disk.
      expect(container.read(notificationInboxProvider).requireValue, isEmpty);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const NotificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Previously received update'), findsOneWidget);
      expect(find.text('No notifications yet'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'backend login and decision payloads preserve IDs, content and time',
    () {
      final sentAt = DateTime.utc(2026, 11, 13, 9);
      final message = NotificationModel.fromRemoteMessage(
        RemoteMessage(
          messageId: 'delivery-attempt',
          sentTime: sentAt,
          notification: const RemoteNotification(
            title: 'Login successful',
            body: 'Welcome to the HRMS app.',
          ),
          data: const {
            'type': 'login_success',
            'eventId': 'event-1',
            'entityId': 'session-1',
            'status': 'success',
          },
        ),
      );
      expect(message.id, 'event-1');
      expect(message.destination, NotificationDestination.attendance);
      final stored = NotificationModel.fromJson(
        NotificationModel.toJson(message),
      );
      expect(stored.displayText, 'Login successful\nWelcome to the HRMS app.');
      expect(stored.sentAt, sentAt);
      expect(stored.entityId, 'session-1');
      expect(stored.status, 'success');
    },
  );

  test('inbox deduplicates delivery retries, sorts newest first and isolates accounts', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = NotificationLocalDataSource(preferences: prefs);
    final older = AppNotification(
      id: 'old',
      title: 'Older update',
      sentAt: DateTime.utc(2026, 11, 12),
    );
    final newest = AppNotification(
      id: 'new',
      title: 'Real update',
      sentAt: DateTime.utc(2026, 11, 13),
    );
    await Future.wait([
      store.saveNotification('employee-a', older),
      store.saveNotification('employee-a', newest),
      store.saveNotification('employee-b', newest),
    ]);
    await store.saveNotification('employee-a', newest);
    await store.saveNotification(
      'employee-a',
      const AppNotification(type: 'clock_in'),
    );
    expect((await store.readInbox('employee-a')).map((e) => e.id), [
      'new',
      'old',
    ]);
    expect((await store.readInbox('employee-b')).length, 1);
    expect(await store.readInbox('employee-c'), isEmpty);
    final reopened = NotificationLocalDataSource(
      preferences: await SharedPreferences.getInstance(),
    );
    expect((await reopened.readInbox('employee-a')).first.title, 'Real update');
  });

  test(
    'live inbox clears on logout and loads only the next account history',
    () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.isUserLoggedIn: true,
        SharedPrefsKeys.userIdKey: 'employee-a',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authSessionProvider.notifier).markLoggedIn();
      final subscription = container.listen(
        notificationInboxProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      expect(await container.read(notificationInboxProvider.future), isEmpty);
      await container
          .read(notificationInboxProvider.notifier)
          .record(
            const AppNotification(id: 'event-a', title: 'Account A update'),
          );
      expect(
        container.read(notificationInboxProvider).requireValue.single.id,
        'event-a',
      );
      container.read(authSessionProvider.notifier).markLoggedOut();
      expect(await container.read(notificationInboxProvider.future), isEmpty);
      await prefs.setString(SharedPrefsKeys.userIdKey, 'employee-b');
      container.read(authSessionProvider.notifier).markLoggedIn();
      expect(await container.read(notificationInboxProvider.future), isEmpty);
      await container
          .read(notificationInboxProvider.notifier)
          .record(
            const AppNotification(id: 'event-b', title: 'Account B update'),
          );
      expect(
        container.read(notificationInboxProvider).requireValue.single.id,
        'event-b',
      );
    },
  );

  testWidgets(
    'screen starts empty and displays received content at large text scale',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.isUserLoggedIn: true,
        SharedPrefsKeys.userIdKey: 'employee-a',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authSessionProvider.notifier).markLoggedIn();
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
            home: const NotificationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No notifications yet'), findsOneWidget);
      await tester.runAsync(
        () => container
            .read(notificationInboxProvider.notifier)
            .record(
              AppNotification(
                id: 'real-event',
                title: 'Backend approval',
                body: 'The backend message is displayed unchanged.',
                type: 'leave_approved',
                sentAt: DateTime.now(),
              ),
            ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Backend approval'), findsOneWidget);
      expect(
        find.text('The backend message is displayed unchanged.'),
        findsOneWidget,
      );
      expect(find.text('No notifications yet'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
