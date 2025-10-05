
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutritracker/presentation/ai_food_detection_screen/widgets/food_analysis_results_widget.dart';
import 'package:nutritracker/services/gemini_client.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });
  testGoldens('FoodAnalysisResultsWidget - aggregate first', (tester) async {
    final results = FoodNutritionData(foods: [
      DetectedFood(
        name: 'Salada (total)',
        calories: 320,
        carbs: 28,
        protein: 6,
        fat: 18,
        fiber: 6,
        sugar: 7,
        portionSize: '320 g',
        confidence: 0.88,
      ),
      DetectedFood(
        name: 'Tomate',
        calories: 20,
        carbs: 4,
        protein: 1,
        fat: 0.1,
        fiber: 1,
        sugar: 2,
        portionSize: '80 g',
        confidence: 0.75,
      ),
    ]);

    await pumpGolden(
      tester,
      FoodAnalysisResultsWidget(
        results: results,
        onAddFood: (_) {},
      ),
    );

    await screenMatchesGolden(tester, 'ai_results_aggregate_first');
  });
}
