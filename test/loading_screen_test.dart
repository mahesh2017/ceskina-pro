import 'package:ceskina_pro/presentation/screens/onboarding/loading_screen.dart';
import 'package:flutter/material.dart';
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
}
