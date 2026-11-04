import 'package:attendance_flutter/features/splash/presentation/view/splash_view.dart';
import 'package:attendance_flutter/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup completes once and remains complete', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(splashViewModelProvider), isFalse);
    await tester.pump(const Duration(milliseconds: 2399));
    expect(container.read(splashViewModelProvider), isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    expect(container.read(splashViewModelProvider), isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(container.read(splashViewModelProvider), isTrue);
  });

  testWidgets('disposing startup cancels its pending timer', (tester) async {
    final container = ProviderContainer();
    container.read(splashViewModelProvider);
    container.dispose();
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash fits small screens and enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 480),
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: SplashView(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
