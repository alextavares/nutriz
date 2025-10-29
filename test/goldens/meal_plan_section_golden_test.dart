import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutriz/presentation/daily_tracking_dashboard/widgets/meal_plan_section_widget.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });

  testGoldens('MealPlanSection - lunch/dinner/snacks', (tester) async {
    final items = [
      const MealPlanItem(
        title: 'Almoço',
        consumedKcal: 410,
        goalKcal: 934,
        subtitle: 'Assado de batata com ...',
        ai: true,
        enabled: true,
      ),
      const MealPlanItem(
        title: 'Jantar',
        consumedKcal: 0,
        goalKcal: 934,
        enabled: true,
      ),
      const MealPlanItem(
        title: 'Lanches',
        consumedKcal: 0,
        goalKcal: 0,
        enabled: false,
      ),
    ];

    await pumpGolden(
      tester,
      MealPlanSectionWidget(items: items),
    );
    await screenMatchesGolden(tester, 'meal_plan_section');
  });
}

