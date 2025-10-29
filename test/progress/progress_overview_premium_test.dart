import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:nutriz/presentation/progress_overview/progress_overview.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> _settle(WidgetTester tester) async {
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('Free user sees PRO upsell and gating in progress overview',
      (tester) async {
    SharedPreferences.setMockInitialValues({'premium_status': false});

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(home: ProgressOverviewScreen());
    }));
    await _settle(tester);

    expect(find.text('Relatórios PRO'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('Exportar relatórios avançados'), findsOneWidget);

    final monthChip = find.widgetWithText(ChoiceChip, 'Mês');
    await tester.tap(monthChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final chipWidget = tester.widget<ChoiceChip>(monthChip);
    expect(chipWidget.selected, isFalse);
  });

  testWidgets('Premium user consegue alternar para modo mensal', (tester) async {
    SharedPreferences.setMockInitialValues({'premium_status': true});

    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(home: ProgressOverviewScreen());
    }));
    await _settle(tester);

    final monthChip = find.widgetWithText(ChoiceChip, 'Mês');
    await tester.tap(monthChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final chipWidget = tester.widget<ChoiceChip>(monthChip);
    expect(chipWidget.selected, isTrue);
    expect(find.text('Relatórios PRO'), findsNothing);
  });
}
