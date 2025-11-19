import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/onboarding/onboarding_flow.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('Onboarding shows EN copy and navigates steps', (tester) async {
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
      home: const OnboardingFlow(),
    );
    }));

    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Step 1 -> Step 2 (Commitment)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Day Streak'), findsOneWidget);

    // Step 2 -> Step 3 (Goals)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Set your goals'), findsOneWidget);

    // Step 3 -> Step 4 (Reminders)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Reminders & Notifications'), findsOneWidget);

    // Do not press Finish to avoid route navigation during test
  });
}
