import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_storage.dart';
import 'user_preferences.dart';
import 'streak_service.dart';
import 'achievement_service.dart';

/// Utilities for weekly goals like "perfect calorie week".
class WeeklyGoalService {
  static const _kLastPerfectWeek = 'weekly_perfect_calories_last_week_v1'; // ISO week id

  static String _isoWeekId(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstThursdayAdj = firstThursday.add(Duration(days: -((firstThursday.weekday + 6) % 7)));
    final week = 1 + ((thursday.difference(firstThursdayAdj).inDays) / 7).floor();
    return '${thursday.year.toString().padLeft(4, '0')}-W${week.toString().padLeft(2, '0')}';
  }

  /// Check last 7 days (including today) and, if all days <= daily calorie goal, award an achievement.
  /// Returns true if milestone/achievement was created.
  static Future<bool> evaluatePerfectCaloriesWeek() async {
    final now = DateTime.now();
    final goals = await UserPreferences.getGoals();
    final cap = goals.totalCalories <= 0 ? 2000 : goals.totalCalories;

    // Sum calories from diary entries
    int okDays = 0;
    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(day);
      final kcal = entries.fold<int>(0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
      if (kcal <= cap && kcal > 0) {
        okDays++;
      } else {
        okDays = 0; // require consecutiveness; break if desired
        break;
      }
    }

    if (okDays >= 7) {
      // Prevent duplicate for same ISO week
      final prefs = await SharedPreferences.getInstance();
      final id = _isoWeekId(now);
      final last = prefs.getString(_kLastPerfectWeek);
      if (last == id) return false;
      await prefs.setString(_kLastPerfectWeek, id);

      // Mark streak type calories_ok_day as completed for today
      await StreakService.markCompleted('calories_ok_day', DateTime.now());
      await AchievementService.add({
        'id': 'cal_week_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'success',
        'title': 'Semana perfeita de calorias!',
        'dateIso': DateTime.now().toIso8601String(),
        'metaKey': 'calories',
        'value': okDays,
      });
      return true;
    }
    return false;
  }

  static Future<void> clearLastPerfectWeek() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastPerfectWeek);
  }
}
