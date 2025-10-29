import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutriz/services/nutrition_storage.dart';
import 'package:nutriz/services/streak_service.dart';
import 'package:nutriz/services/achievement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StreakService.clearAll();
  });

  test('addEntry marks food_log and increments currentStreak when consecutive to today', () async {
    final now = DateTime.now();
    DateTime day(int daysAgo) => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysAgo));

    // Logging only yesterday should not start a current streak up to today
    await NutritionStorage.addEntry(day(1), {
      'name': 'Yogurt',
      'calories': 80,
      'mealTime': 'breakfast',
    });
    expect(await StreakService.isCompleted('food_log', day(1)), isTrue);
    expect(await StreakService.currentStreak('food_log'), 0);

    // Logging today should make it 2-day current streak (yesterday + today)
    await NutritionStorage.addEntry(day(0), {
      'name': 'Banana',
      'calories': 90,
      'mealTime': 'snack',
    });
    expect(await StreakService.currentStreak('food_log'), 2);
  });

  test('awards achievement at 3-day milestone', () async {
    final now = DateTime.now();
    DateTime day(int daysAgo) => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysAgo));

    await AchievementService.clearAll();

    // Create a 3-day consecutive streak ending today
    await NutritionStorage.addEntry(day(2), {
      'name': 'Item A',
      'calories': 50,
      'mealTime': 'lunch',
    });
    await NutritionStorage.addEntry(day(1), {
      'name': 'Item B',
      'calories': 60,
      'mealTime': 'dinner',
    });
    await NutritionStorage.addEntry(day(0), {
      'name': 'Item C',
      'calories': 70,
      'mealTime': 'breakfast',
    });

    final streak = await StreakService.currentStreak('food_log');
    expect(streak, 3);

    final all = await AchievementService.listAll();
    final hasMilestone3 = all.any((a) =>
        (a['type'] == 'flame') && (a['metaKey'] == 'food_log') && (a['value'] == 3));
    expect(hasMilestone3, isTrue);
  });
}

