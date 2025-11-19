import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('Filter bottom sheet shows localized title', (tester) async {
    // Fixed surface size to stabilize layout.
    final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
    binding.window.physicalSizeTestValue = const Size(390, 844);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const RecipeBrowser(),
    );
    }));

    await tester.pump(const Duration(milliseconds: 150));

    // Tap filter button (tune icon)
    final filterIcon = find.byIcon(Icons.tune);
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Meal Type'), findsOneWidget);
  });
}
