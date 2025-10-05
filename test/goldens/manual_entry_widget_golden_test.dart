
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutritracker/presentation/food_logging_screen/widgets/manual_entry_widget.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });
  testGoldens('ManualEntryWidget - compact confirm', (tester) async {
    final food = {
      'name': 'Salada (total)',
      'brand': 'Caseiro',
      'calories': 320,
      'carbs': 28,
      'protein': 6,
      'fat': 18,
      'serving': '320 g',
    };

    await pumpGolden(
      tester,
      ManualEntryWidget(
        selectedFood: food,
        onQuantityChanged: (_) {},
        onServingSizeChanged: (_) {},
      ),
    );

    await screenMatchesGolden(tester, 'manual_entry_compact');
  });
}
