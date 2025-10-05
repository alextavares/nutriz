import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Generic streak storage: tracks completion per day for a given key
/// (e.g., "water", "calories_ok_day") and computes current streak.
class StreakService {
  static const _kStreakStore = 'streak_store_v1'; // JSON: key -> { yyyy-mm-dd: true }

  static String _dayKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Mark a specific day as completed for a given streak key
  static Future<void> markCompleted(String key, DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreakStore);
    final Map<String, dynamic> store = raw == null || raw.isEmpty
        ? {}
        : (jsonDecode(raw) as Map<String, dynamic>);
    final Map<String, dynamic> perKey =
        (store[key] as Map<String, dynamic>?) ?? <String, dynamic>{};
    perKey[_dayKey(day)] = true;
    store[key] = perKey;
    await prefs.setString(_kStreakStore, jsonEncode(store));
  }

  /// Return whether the day is marked as completed
  static Future<bool> isCompleted(String key, DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreakStore);
    if (raw == null || raw.isEmpty) return false;
    try {
      final store = jsonDecode(raw) as Map<String, dynamic>;
      final perKey = store[key] as Map<String, dynamic>?;
      if (perKey == null) return false;
      return (perKey[_dayKey(day)] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Compute current streak (consecutive completed days up to today)
  static Future<int> currentStreak(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreakStore);
    if (raw == null || raw.isEmpty) return 0;
    final Map<String, dynamic> store =
        jsonDecode(raw) as Map<String, dynamic>;
    final Map<String, dynamic> perKey =
        (store[key] as Map<String, dynamic>?) ?? <String, dynamic>{};
    int streak = 0;
    DateTime cursor = DateTime.now();
    while (true) {
      if ((perKey[_dayKey(cursor)] as bool?) == true) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStreakStore);
  }

  static Future<void> clearKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreakStore);
    if (raw == null || raw.isEmpty) return;
    try {
      final store = jsonDecode(raw) as Map<String, dynamic>;
      store.remove(key);
      await prefs.setString(_kStreakStore, jsonEncode(store));
    } catch (_) {}
  }

  /// Compute the longest streak within the last [days] days (default window 180).
  static Future<int> longestStreak(String key, {int days = 180}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStreakStore);
    if (raw == null || raw.isEmpty) return 0;
    final Map<String, dynamic> store =
        jsonDecode(raw) as Map<String, dynamic>;
    final Map<String, dynamic> perKey =
        (store[key] as Map<String, dynamic>?) ?? <String, dynamic>{};

    int best = 0;
    int cur = 0;
    DateTime cursor = DateTime.now();
    for (int i = 0; i < days; i++) {
      if ((perKey[_dayKey(cursor)] as bool?) == true) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 0;
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return best;
  }
}
