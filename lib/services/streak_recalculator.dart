
import 'nutrition_storage.dart';
import 'user_preferences.dart';
import 'fasting_storage.dart';
import 'streak_service.dart';
import 'achievement_service.dart';

/// Recalculate streaks from persisted data over recent days.
class StreakRecalculator {
  /// Recalculate water, fasting, calories_ok_day and protein streaks over the last [days] days (default 60).
  static Future<void> recalcAllOverDays({int days = 60}) async {
    await _clearKeys();
    final now = DateTime.now();
    final goals = await UserPreferences.getGoals();
    final waterGoal = goals.waterGoalMl <= 0 ? 2000 : goals.waterGoalMl;
    final kcalCap = goals.totalCalories <= 0 ? 2000 : goals.totalCalories;
    final protCap = goals.proteins <= 0 ? 100 : goals.proteins;

    // Prefetch fasting history once
    final fastingMap = await FastingStorage.getHistoryMap();
    bool fastingDayOK(DateTime d) {
      String two(int v) => v.toString().padLeft(2, '0');
      final key = '${d.year}-${two(d.month)}-${two(d.day)}';
      final m = fastingMap[key] as Map<String, dynamic>?;
      final secs = (m?['duration_secs'] as num?)?.toInt() ?? 0;
      return secs >= const Duration(hours: 12).inSeconds;
    }

    for (int i = 0; i < days; i++) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));

      // Water
      final water = await NutritionStorage.getWaterMl(d);
      if (water >= waterGoal && water > 0) {
        await StreakService.markCompleted('water', d);
      }

      // Fasting
      if (fastingDayOK(d)) {
        await StreakService.markCompleted('fasting', d);
      }

      // Calories OK + generic food log
      final entries = await NutritionStorage.getEntriesForDate(d);
      // Food log OK (any entry counts)
      if (entries.isNotEmpty) {
        await StreakService.markCompleted('food_log', d);
      }
      final kcal = entries.fold<int>(0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
      if (kcal > 0 && kcal <= kcalCap) {
        await StreakService.markCompleted('calories_ok_day', d);
      }

      // Protein OK
      final prot = entries.fold<int>(0, (sum, e) => sum + ((e['proteins'] as num?)?.toInt() ?? 0));
      if (prot >= protCap) {
        await StreakService.markCompleted('protein', d);
      }
    }

    // Award food_log milestones after rebuild (deduped)
    try {
      const thresholds = [3, 5, 7, 14, 30];
      final cur = await StreakService.currentStreak('food_log');
      if (cur > 0) {
        final existing = await AchievementService.listAll();
        final have = <int>{};
        for (final a in existing) {
          if ((a['type'] == 'flame') && (a['metaKey'] == 'food_log')) {
            final v = (a['value'] as num?)?.toInt();
            if (v != null) have.add(v);
          }
        }
        for (final t in thresholds) {
          if (cur >= t && !have.contains(t)) {
            await AchievementService.add({
              'id': 'food_log_${t}_${DateTime.now().millisecondsSinceEpoch}',
              'type': 'flame',
              'title': 'Sequência ${t} dias!',
              'dateIso': DateTime.now().toIso8601String(),
              'metaKey': 'food_log',
              'value': t,
            });
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> _clearKeys() async {
    await StreakService.clearKey('water');
    await StreakService.clearKey('fasting');
    await StreakService.clearKey('calories_ok_day');
    await StreakService.clearKey('protein');
    await StreakService.clearKey('food_log');
  }
}
