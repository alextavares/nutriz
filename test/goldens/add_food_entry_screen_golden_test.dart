
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutriz/presentation/food_logging_screen/add_food_entry_screen.dart';
import 'helpers.dart';
import 'package:sizer/sizer.dart';

Future<void> _pumpAddFoodEntry(WidgetTester tester, Map<String, dynamic> args) async {
  await tester.pumpWidgetBuilder(
    Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/add') {
            return MaterialPageRoute(
              builder: (_) => const AddFoodEntryScreen(),
              settings: RouteSettings(arguments: args),
            );
          }
          return MaterialPageRoute(builder: (_) => const SizedBox());
        },
        initialRoute: '/add',
      );
    }),
    surfaceSize: const Size(390, 844),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });
  testGoldens('AddFoodEntryScreen - lunch reviewOnly start', (tester) async {
    await _pumpAddFoodEntry(tester, {
      'mealKey': 'lunch',
      'targetDate': DateTime.now().toIso8601String(),
    });
    await screenMatchesGolden(tester, 'add_food_entry_lunch');
  });
}
