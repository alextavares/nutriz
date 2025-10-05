import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutritracker/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutritracker/presentation/recipe_browser/widgets/recipe_grid_widget.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Recipe Browser renders EN title and grid', (tester) async {
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

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.byType(RecipeGridWidget), findsOneWidget);
  });
}
