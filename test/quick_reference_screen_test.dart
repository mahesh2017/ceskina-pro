import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ceskina_pro/core/theme/app_theme.dart';
import 'package:ceskina_pro/presentation/screens/grammar/quick_reference_screen.dart';

/// Renders the reference screens against the real bundled assets so schema
/// drift between the JSON files and the renderer fails loudly (previously the
/// renderer expected a `rows` key that no asset had, producing headings with
/// empty bodies).
void main() {
  Future<void> pumpReference(WidgetTester tester, String type) async {
    await tester.pumpWidget(
      MaterialApp(theme: lightTheme(), home: QuickReferenceScreen(type: type)),
    );
    // Assets >50KB are utf8-decoded off the main isolate, which never
    // completes under fake async — give the load real wall-clock time.
    for (var i = 0;
        i < 20 && tester.any(find.byType(CircularProgressIndicator));
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
  }

  testWidgets('declension tables expand to real case forms', (tester) async {
    await pumpReference(tester, 'declension_tables');

    expect(find.text('Masculine Animate — Hard Stem'), findsOneWidget);

    await tester.tap(find.text('Masculine Animate — Hard Stem'));
    await tester.pumpAndSettle();

    // Case rows and declined forms from the asset (pattern word "pan").
    expect(find.text('Singular'), findsOneWidget);
    expect(find.text('Plural'), findsOneWidget);
    expect(find.text('pana (-a)'), findsWidgets);
  });

  testWidgets('conjugation tables expand to real verb forms', (tester) async {
    await pumpReference(tester, 'conjugation_tables');

    expect(find.text('být — present'), findsOneWidget);

    await tester.tap(find.text('být — present'));
    await tester.pumpAndSettle();

    expect(find.text('jsem'), findsOneWidget);
    expect(find.text('jsou'), findsOneWidget);
  });

  testWidgets('cheat sheets render unit entries', (tester) async {
    await pumpReference(tester, 'cheat_sheets');
    expect(find.textContaining('Unit 1'), findsWidgets);
  });
}
