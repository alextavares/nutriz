import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutritracker/services/nutrition_storage.dart';
import 'package:nutritracker/services/streak_recalculator.dart';
import 'package:nutritracker/services/achievement_service.dart';
import 'package:nutritracker/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AchievementService.clearAll();
    await StreakService.clearAll();
  });

  test('recalc awards 3-day milestone and dedupes on rerun', () async {
    final now = DateTime.now();
    DateTime day(int ago) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: ago));

    // Create 3 consecutive days ending today
    await NutritionStorage.addEntry(
        day(2), {'name': 'A', 'calories': 10, 'mealTime': 'breakfast'});
    await NutritionStorage.addEntry(
        day(1), {'name': 'B', 'calories': 10, 'mealTime': 'lunch'});
    await NutritionStorage.addEntry(
        day(0), {'name': 'C', 'calories': 10, 'mealTime': 'dinner'});

    await StreakRecalculator.recalcAllOverDays(days: 7);

    var all = await AchievementService.listAll();
    expect(
        all.any((a) =>
            a['type'] == 'flame' && a['metaKey'] == 'food_log' && a['value'] == 3),
        isTrue);

    // Re-run recalc; should not duplicate
    await StreakRecalculator.recalcAllOverDays(days: 7);
    all = await AchievementService.listAll();
    final count3 = all
        .where((a) =>
            a['type'] == 'flame' && a['metaKey'] == 'food_log' && a['value'] == 3)
        .length;
    expect(count3, 1);
  });
}

