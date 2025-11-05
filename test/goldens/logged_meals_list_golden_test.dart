@Skip('Golden tests disabled temporarily')

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutriz/presentation/daily_tracking_dashboard/widgets/logged_meals_list_widget.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });
  testGoldens('LoggedMealsListWidget - with breakfast and lunch', (tester) async {
    final entries = <Map<String, dynamic>>[
      {
        'name': 'Omelete',
        'calories': 220,
        'carbs': 2,
        'protein': 18,
        'fat': 14,
        'mealTime': 'breakfast',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Salada (total)',
        'calories': 320,
        'carbs': 28,
        'protein': 6,
        'fat': 18,
        'mealTime': 'lunch',
        'source': 'AI/quick',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    await pumpGolden(
      tester,
      LoggedMealsListWidget(
        entries: entries,
        onRemove: (_) {},
        onEdit: (_) {},
        mealKcalGoals: const {'breakfast': 400, 'lunch': 700},
        mealMacroGoalsByKey: const {
          'breakfast': {'carbs': 40, 'proteins': 25, 'fats': 15},
          'lunch': {'carbs': 80, 'proteins': 35, 'fats': 30},
        },
      ),
      size: const Size(520, 844),
    );

    await screenMatchesGolden(tester, 'logged_meals_two_sections');
  });
}
