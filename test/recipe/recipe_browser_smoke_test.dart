import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutriz/presentation/recipe_browser/widgets/recipe_grid_widget.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('Recipe Browser renders EN title and grid', (tester) async {
    // Use a fixed surface size to avoid layout overflows and skip network settling.
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

    // Pump a few frames instead of pumpAndSettle (network is blocked in tests).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Recipes'), findsOneWidget);
    // Grid may be loading if a network call is pending; tolerate either grid or progress.
    expect(find.byType(RecipeGridWidget).hitTestable(), findsOneWidget);
  });
}
