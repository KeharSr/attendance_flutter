import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view_model/widgets/attendance_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 4, 18);
  Widget clock({
    bool working = false,
    bool completed = false,
    bool loading = false,
    bool reducedMotion = false,
    Duration elapsed = Duration.zero,
    VoidCallback? onToggle,
  }) => MaterialApp(
    theme: buildAppTheme(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(
        body: SingleChildScrollView(
          child: AttendanceClock(
            now: now,
            working: working,
            completed: completed,
            loading: loading,
            elapsed: elapsed,
            checkIn: working || completed ? now.subtract(elapsed) : null,
            onToggle: onToggle ?? () {},
          ),
        ),
      ),
    ),
  );

  AttendanceDialPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint &&
                      widget.painter is AttendanceDialPainter,
                ),
              )
              .painter!
          as AttendanceDialPainter;

  testWidgets(
    'ring fills with time worked rather than immediately on clock-in',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(clock(onToggle: () => taps++));
      expect(painter(tester).fill, 0);
      await tester.tap(find.text('Clock in'));
      expect(taps, 1);
      expect(painter(tester).fill, 0);
      await tester.pumpWidget(clock(working: true));
      await tester.pumpAndSettle();
      expect(painter(tester).fill, 0);
      expect(find.text('Clock out'), findsOneWidget);

      await tester.pumpWidget(
        clock(working: true, elapsed: const Duration(hours: 2)),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(painter(tester).fill, greaterThan(0));
      expect(painter(tester).fill, lessThan(.25));
      await tester.pumpAndSettle();
      expect(painter(tester).fill, .25);

      await tester.pumpWidget(
        clock(working: true, elapsed: const Duration(hours: 4)),
      );
      await tester.pumpAndSettle();
      expect(painter(tester).fill, .5);
      expect(find.text('04:00:00'), findsOneWidget);
    },
  );

  testWidgets(
    'clock-out retains partial fill and mounting does not replay the session',
    (tester) async {
      await tester.pumpWidget(
        clock(working: true, elapsed: const Duration(hours: 3)),
      );
      expect(painter(tester).fill, .375);
      await tester.pumpWidget(
        clock(completed: true, elapsed: const Duration(hours: 3)),
      );
      await tester.pump(const Duration(hours: 1));
      expect(painter(tester).fill, .375);
      expect(find.text('03:00:00'), findsOneWidget);
      expect(find.text('Session complete'), findsOneWidget);
      expect(find.text('Completed for today'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Completed for today'),
            )
            .onPressed,
        isNull,
      );
      expect(find.widgetWithText(OutlinedButton, 'Clock in'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'eight hours fills the ring and overtime keeps the duration counting',
    (tester) async {
      await tester.pumpWidget(
        clock(
          working: true,
          reducedMotion: true,
          elapsed: const Duration(hours: 8),
        ),
      );
      expect(painter(tester).fill, 1);
      await tester.pumpWidget(
        clock(
          working: true,
          reducedMotion: true,
          elapsed: const Duration(hours: 9, minutes: 15, seconds: 9),
        ),
      );
      await tester.pump();
      expect(painter(tester).fill, 1);
      expect(find.text('09:15:09'), findsOneWidget);
      await tester.pumpWidget(
        clock(
          working: true,
          reducedMotion: true,
          elapsed: const Duration(hours: 4),
        ),
      );
      await tester.pump();
      expect(painter(tester).fill, .5);
      expect(tester.takeException(), isNull);
    },
  );
}
