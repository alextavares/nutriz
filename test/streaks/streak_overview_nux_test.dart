import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/streaks/streak_overview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('Streak Overview NUX shows once and persists', (tester) async {
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
      home: const StreakOverviewScreen(),
    );
    }));
    // Allow async + post-frame callbacks
    await tester.pumpAndSettle();

    // Expect the NUX dialog to be visible
    expect(find.text('Got it'), findsOneWidget);

    // Dismiss NUX
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    // NUX should be gone
    expect(find.text('Got it'), findsNothing);

    // Rebuild screen; NUX should not show again
    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const StreakOverviewScreen(),
    );
    }));
    await tester.pumpAndSettle();

    expect(find.text('Got it'), findsNothing);
  });
}
