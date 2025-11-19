import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:nutriz/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> _settle(WidgetTester tester) async {
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Free users see PRO overlays on premium recipes',
      (tester) async {
    SharedPreferences.setMockInitialValues({'premium_status': false});

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: RecipeBrowser(),
      );
    }));
    await _settle(tester);

    expect(find.text('Somente PRO'), findsWidgets);
    expect(find.text('Receita PRO'), findsWidgets);
  });

  testWidgets('Premium users não veem bloqueios nas receitas', (tester) async {
    SharedPreferences.setMockInitialValues({'premium_status': true});

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: RecipeBrowser(),
      );
    }));
    await _settle(tester);

    expect(find.text('Somente PRO'), findsNothing);
    expect(find.text('Receita PRO'), findsNothing);
  });
}
