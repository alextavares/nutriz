import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutritracker/presentation/achievements/all_achievements_screen.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Achievements screen shows tabs and empty state (EN)', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const AllAchievementsScreen(),
    ));

    await tester.pumpAndSettle();

    // App bar title
    expect(find.text('Achievements'), findsOneWidget);

    // Tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Fasting'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Empty state by default
    expect(find.text('No achievements yet'), findsOneWidget);
  });
}
