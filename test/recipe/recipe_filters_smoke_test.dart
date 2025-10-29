import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Filter bottom sheet shows localized title', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const RecipeBrowser(),
    ));

    await tester.pumpAndSettle();

    // Tap filter button (tune icon)
    final filterIcon = find.byIcon(Icons.tune);
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Meal Type'), findsOneWidget);
  });
}
