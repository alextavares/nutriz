import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutriz/services/nutrition_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addEntry and getEntriesForDate store and retrieve item', () async {
    final date = DateTime(2025, 1, 2);
    final entry = {
      'name': 'Apple',
      'calories': 95,
      'carbs': 25.0,
      'protein': 0.5,
      'fat': 0.3,
      'mealTime': 'breakfast',
    };
    await NutritionStorage.addEntry(date, entry);
    final items = await NutritionStorage.getEntriesForDate(date);
    expect(items.length, 1);
    expect(items.first['name'], 'Apple');
    expect(items.first['mealTime'], 'breakfast');
  });

  test('addWaterMl increments water for the day', () async {
    final date = DateTime(2025, 1, 3);
    final w0 = await NutritionStorage.getWaterMl(date);
    expect(w0, 0);
    final w1 = await NutritionStorage.addWaterMl(date, 300);
    expect(w1, 300);
    final w2 = await NutritionStorage.addWaterMl(date, 200);
    expect(w2, 500);
  });

  test('exportDiary contains expected keys and values', () async {
    final d = DateTime(2025, 1, 4);
    await NutritionStorage.addEntry(d, {
      'name': 'Rice',
      'calories': 200,
      'mealTime': 'lunch',
    });
    await NutritionStorage.setExerciseCalories(d, 100);
    await NutritionStorage.setWaterMl(d, 500);

    final exported = await NutritionStorage.exportDiary();
    expect(exported['version'], 1);
    expect(exported['meals'], isA<Map<String, dynamic>>());
    expect(exported['exercise'], isA<Map<String, dynamic>>());
    expect(exported['water'], isA<Map<String, dynamic>>());

    const dateKey = '2025-01-04';
    final meals = exported['meals'] as Map<String, dynamic>;
    final exercise = exported['exercise'] as Map<String, dynamic>;
    final water = exported['water'] as Map<String, dynamic>;
    expect(meals[dateKey], isNotNull);
    expect(exercise[dateKey], 100);
    expect(water[dateKey], 500);
  });
}

