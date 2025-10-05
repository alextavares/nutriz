import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_storage.dart';
import 'user_preferences.dart';
import 'streak_service.dart';
import 'achievement_service.dart';

/// Daily goals evaluators (e.g., protein target reached today)
class DailyGoalService {
  static const _kProteinMarkedKey = 'protein_ok_marked_day_v1'; // per-day marker to avoid repeat work
  static const _kCaloriesMarkedKey = 'cal_ok_marked_day_v1';

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// If today's total protein >= goal.proteins, mark streak 'protein' for today.
  /// When streak reaches 5, create an achievement.
  static Future<bool> evaluateProteinOkToday() async {
    final prefs = await SharedPreferences.getInstance();
    final markerKey = '$_kProteinMarkedKey-${_todayKey()}';
    if (prefs.getBool(markerKey) == true) {
      return false; // already processed today
    }

    // Sum protein grams from today's entries
    final today = DateTime.now();
    final entries = await NutritionStorage.getEntriesForDate(today);
    final totalProt = entries.fold<int>(0, (sum, e) => sum + ((e['proteins'] as num?)?.toInt() ?? 0));
    final goals = await UserPreferences.getGoals();
    final target = goals.proteins <= 0 ? 100 : goals.proteins; // fallback

    if (totalProt >= target) {
      await StreakService.markCompleted('protein', DateTime(today.year, today.month, today.day));
      final streak = await StreakService.currentStreak('protein');
      if (streak == 5 || streak == 7 || streak == 14 || streak == 30) {
        await AchievementService.add({
          'id': 'protein_${streak}_${DateTime.now().millisecondsSinceEpoch}',
          'type': 'success',
          'title': 'Proteína ${streak} dias!',
          'dateIso': DateTime.now().toIso8601String(),
          'metaKey': 'protein',
          'value': streak,
        });
      }
    }

    await prefs.setBool(markerKey, true);
    return true;
  }

  /// If today's total calories <= goal.totalCalories (and > 0), mark streak 'calories_ok_day'.
  /// When streak reaches 3 or 5, create an achievement.
  static Future<bool> evaluateCaloriesOkToday() async {
    final prefs = await SharedPreferences.getInstance();
    final markerKey = '$_kCaloriesMarkedKey-${_todayKey()}';
    if (prefs.getBool(markerKey) == true) return false;

    final today = DateTime.now();
    final entries = await NutritionStorage.getEntriesForDate(today);
    final kcal = entries.fold<int>(0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
    final goals = await UserPreferences.getGoals();
    final cap = goals.totalCalories <= 0 ? 2000 : goals.totalCalories;

    if (kcal > 0 && kcal <= cap) {
      await StreakService.markCompleted('calories_ok_day', DateTime(today.year, today.month, today.day));
      final streak = await StreakService.currentStreak('calories_ok_day');
      if (streak == 3 || streak == 5 || streak == 7 || streak == 14 || streak == 30) {
        await AchievementService.add({
          'id': 'cal_ok_${streak}_${DateTime.now().millisecondsSinceEpoch}',
          'type': 'success',
          'title': 'Calorias ${streak} dias!',
          'dateIso': DateTime.now().toIso8601String(),
          'metaKey': 'calories',
          'value': streak,
        });
      }
    }

    await prefs.setBool(markerKey, true);
    return true;
  }
}
