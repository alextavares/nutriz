import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/achievements/all_achievements_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Achievements screen shows tabs and empty state (EN)', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const AllAchievementsScreen(),
    );
    }));

    await tester.pumpAndSettle();

    // App bar title
    expect(find.text('Achievements'), findsOneWidget);

    // Tabs (ensure Tab widgets have the expected labels)
    expect(find.widgetWithText(Tab, 'All'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Water'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Fasting'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Calories'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Protein'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Food'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Test'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Favorites'), findsOneWidget);

    // Empty state by default
    expect(find.text('No achievements yet'), findsOneWidget);
  });
}
