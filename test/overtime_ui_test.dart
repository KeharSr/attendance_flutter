import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/overtime/domain/entity/overtime_entity.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view/overtime_history_view.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/view_model/overtime_view_model.dart';
import 'package:attendance_flutter/features/overtime/presentation/view_model/state/overtime_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOvertime extends OvertimeViewModel {
  int fetches = 0;
  @override
  OvertimeState build() => OvertimeState.initial();
  @override
  Future<void> getAllOvertimeRequest() async {
    fetches++;
  }
}

void main() {
  testWidgets('swiping to history fetches requests once', (tester) async {
    final fake = FakeOvertime();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [overtimeViewModelProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: OvertimeView())),
      ),
    );
    await tester.dragFrom(
      tester.getTopLeft(find.byType(TabBarView)) + const Offset(600, 20),
      const Offset(-550, 0),
    );
    await tester.pumpAndSettle();
    expect(fake.fetches, 1);
    expect(find.text('No overtime requests yet'), findsOneWidget);
  });

  testWidgets('request validates invalid duration inline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [overtimeViewModelProvider.overrideWith(FakeOvertime.new)],
        child: const MaterialApp(home: Scaffold(body: OvertimeView())),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'NaN');
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
    expect(find.text('Enter a duration greater than zero.'), findsOneWidget);
    expect(find.text('Select a work date.'), findsOneWidget);
  });

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
                  id: 1,
                  userId: 1,
                  workDate: '2026-11-01',
                  overtimeHours: 2.5,
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
