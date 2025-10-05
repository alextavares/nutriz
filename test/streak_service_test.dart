import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutritracker/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StreakService.clearAll();
  });

  test('longestStreak computes best run over window', () async {
    final now = DateTime.now();
    DateTime at(int daysAgo) => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysAgo));

    // Mark a 3-day streak ending 2 days ago: D-4, D-3, D-2
    await StreakService.markCompleted('food_log', at(4));
    await StreakService.markCompleted('food_log', at(3));
    await StreakService.markCompleted('food_log', at(2));

    // Gap on D-1

    // Another 3-day streak further back: D-8..D-6
    await StreakService.markCompleted('food_log', at(8));
    await StreakService.markCompleted('food_log', at(7));
    await StreakService.markCompleted('food_log', at(6));

    final best = await StreakService.longestStreak('food_log', days: 10);
    expect(best, 3);
  });
}

