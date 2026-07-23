import 'package:ceskina_pro/presentation/screens/onboarding/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup error explains the problem and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      LoadingScreen(
        error: 'Check your internet connection and try again.',
        onRetry: () => retries++,
      ),
    );

    expect(find.text('Course couldn’t load'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  for (final size in const [Size(320, 568), Size(375, 667), Size(768, 1024)]) {
    for (final brightness in Brightness.values) {
      testWidgets('startup recovery fits ${size.width.toInt()}px at 2x text in '
          '${brightness.name} mode', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(
          LoadingScreen(
            error:
                'The verified course could not be prepared. '
                'Try again without losing your progress.',
            onRetry: () {},
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Try again'), findsOneWidget);
        expect(
          tester
              .getSemantics(find.widgetWithText(FilledButton, 'Try again'))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
      });
    }
  }

  testWidgets('startup retry is keyboard operable', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      LoadingScreen(error: 'Temporary failure.', onRetry: () => retries++),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(retries, 1);
  });
}
