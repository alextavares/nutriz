import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutriz/services/nutrition_storage.dart';
import 'package:nutriz/services/achievement_service.dart';
import 'package:nutriz/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AchievementService.clearAll();
    await StreakService.clearAll();
  });

  test('awards 3 and 5 cumulatively at 5-day streak', () async {
    final now = DateTime.now();
    DateTime day(int ago) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: ago));

    for (int i = 4; i >= 0; i--) {
      await NutritionStorage.addEntry(day(i), {
        'name': 'X$i',
        'calories': 10,
        'mealTime': 'breakfast',
      });
    }

    final all = await AchievementService.listAll();
    final has3 = all.any((a) =>
        a['type'] == 'flame' && a['metaKey'] == 'food_log' && a['value'] == 3);
    final has5 = all.any((a) =>
        a['type'] == 'flame' && a['metaKey'] == 'food_log' && a['value'] == 5);
    expect(has3, isTrue, reason: 'Should award 3-day milestone by 5-day streak');
    expect(has5, isTrue, reason: 'Should award 5-day milestone when reaching 5');
  });
}

