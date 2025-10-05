import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievement_service.dart';
import 'streak_service.dart';

class NutritionStorage {
  // Change notifier so UI can refresh when storage mutates
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static void _bump() {
    changes.value = changes.value + 1;
  }
  static const String _keyPrefix = 'logged_meals_';
  static const String _exercisePrefix = 'exercise_kcal_';
  static const String _waterPrefix = 'water_ml_';
  static const String _exerciseMetaPrefix = 'exercise_meta_';
  static const String _templatesKey = 'meal_templates_v1';
  static const String _dayTemplatesKey = 'day_templates_v1';
  static const String _weekTemplatesKey = 'week_templates_v1';

  static String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<List<Map<String, dynamic>>> getEntriesForDate(
      DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_dateKey(date)}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addEntry(
      DateTime date, Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_dateKey(date)}';
    final current = await getEntriesForDate(date);
    final withId = Map<String, dynamic>.from(entry);
    withId['id'] = withId['id'] ?? DateTime.now().millisecondsSinceEpoch;
    current.add(withId);
    await prefs.setString(key, jsonEncode(current));
    _bump();

    // Mark generic food logging streak and award simple milestones
    try {
      final day = DateTime(date.year, date.month, date.day);
      await StreakService.markCompleted('food_log', day);
      final streak = await StreakService.currentStreak('food_log');

      // Award all missing milestones up to current streak (deduped)
      const thresholds = [3, 5, 7, 14, 30];
      try {
        final existing = await AchievementService.listAll();
        final have = <int>{};
        for (final a in existing) {
          if ((a['type'] == 'flame') && (a['metaKey'] == 'food_log')) {
            final v = (a['value'] as num?)?.toInt();
            if (v != null) have.add(v);
          }
        }
        for (final t in thresholds) {
          if (streak >= t && !have.contains(t)) {
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
      } catch (_) {}
      
    } catch (_) {}
  }

  static Future<void> updateEntryById(
      DateTime date, dynamic id, Map<String, dynamic> newEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_dateKey(date)}';
    final current = await getEntriesForDate(date);
    final index = current.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(newEntry);
      updated['id'] = id;
      current[index] = updated;
      await prefs.setString(key, jsonEncode(current));
      _bump();
    }
  }

  static Future<void> removeEntryById(DateTime date, dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_dateKey(date)}';
    final current = await getEntriesForDate(date);
    current.removeWhere((e) => e['id'] == id);
    await prefs.setString(key, jsonEncode(current));
    _bump();
  }

  static Future<void> clearDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_dateKey(date)}';
    await prefs.remove(key);
    _bump();
  }

  // Exercise kcal per day
  static Future<int> getExerciseCalories(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exercisePrefix${_dateKey(date)}';
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> setExerciseCalories(DateTime date, int kcal) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exercisePrefix${_dateKey(date)}';
    await prefs.setInt(key, kcal < 0 ? 0 : kcal);
    _bump();
  }

  static Future<int> addExerciseCalories(DateTime date, int delta) async {
    final current = await getExerciseCalories(date);
    final next = (current + delta);
    await setExerciseCalories(date, next < 0 ? 0 : next);
    return await getExerciseCalories(date);
  }

  // Water ml per day
  static Future<int> getWaterMl(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_waterPrefix${_dateKey(date)}';
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> setWaterMl(DateTime date, int ml) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_waterPrefix${_dateKey(date)}';
    await prefs.setInt(key, ml < 0 ? 0 : ml);
    _bump();
  }

  static Future<int> addWaterMl(DateTime date, int delta) async {
    final current = await getWaterMl(date);
    final next = current + delta;
    await setWaterMl(date, next < 0 ? 0 : next);
    return await getWaterMl(date);
  }

  // Exercise meta per day (e.g., last activity details)
  static Future<void> setExerciseMeta(DateTime date, Map<String, dynamic> meta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exerciseMetaPrefix${_dateKey(date)}';
    await prefs.setString(key, jsonEncode(meta));
    _bump();
  }

  static Future<Map<String, dynamic>> getExerciseMeta(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exerciseMetaPrefix${_dateKey(date)}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final obj = jsonDecode(raw);
      if (obj is Map<String, dynamic>) return obj;
    } catch (_) {}
    return {};
  }

  // Exercise logs (list of meta items) per day
  static const String _exerciseLogPrefix = 'exercise_log_v1_';

  static Future<List<Map<String, dynamic>>> getExerciseLogs(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exerciseLogPrefix${_dateKey(date)}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addExerciseLog(DateTime date, Map<String, dynamic> meta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_exerciseLogPrefix${_dateKey(date)}';
    final current = await getExerciseLogs(date);
    final item = Map<String, dynamic>.from(meta);
    item['savedAt'] = item['savedAt'] ?? DateTime.now().toIso8601String();
    current.add(item);
    await prefs.setString(key, jsonEncode(current));
    _bump();
  }

  // Export / Import diary
  static Future<Map<String, dynamic>> exportDiary() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> meals = {};
    final Map<String, int> exercise = {};
    for (final k in keys) {
      if (k.startsWith(_keyPrefix)) {
        final dateKey = k.substring(_keyPrefix.length);
        final raw = prefs.getString(k);
        if (raw != null) {
          try {
            final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
            meals[dateKey] = list;
          } catch (_) {}
        }
      } else if (k.startsWith(_exercisePrefix)) {
        final dateKey = k.substring(_exercisePrefix.length);
        final val = prefs.getInt(k) ?? 0;
        exercise[dateKey] = val;
      } else if (k.startsWith(_waterPrefix)) {
        // include water into export root as water map
      }
    }
    // collect water map
    final Map<String, int> water = {};
    for (final k in keys) {
      if (k.startsWith(_waterPrefix)) {
        final dateKey = k.substring(_waterPrefix.length);
        water[dateKey] = prefs.getInt(k) ?? 0;
      }
    }
    return {
      'meals': meals,
      'exercise': exercise,
      'water': water,
      'version': 1,
    };
  }

  static Future<void> importDiary(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final meals = data['meals'] as Map<String, dynamic>?;
    final exercise = data['exercise'] as Map<String, dynamic>?;
    final water = data['water'] as Map<String, dynamic>?;
    if (meals != null) {
      for (final entry in meals.entries) {
        final key = '$_keyPrefix${entry.key}';
        await prefs.setString(key, jsonEncode(entry.value));
      }
    }
    if (exercise != null) {
      for (final entry in exercise.entries) {
        final key = '$_exercisePrefix${entry.key}';
        final val = (entry.value as num?)?.toInt() ?? 0;
        await prefs.setInt(key, val);
      }
    }
    if (water != null) {
      for (final entry in water.entries) {
        final key = '$_waterPrefix${entry.key}';
        final val = (entry.value as num?)?.toInt() ?? 0;
        await prefs.setInt(key, val);
      }
    }
  }

  // Meal templates (save groups of entries to reuse)
  static Future<List<Map<String, dynamic>>> getMealTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_templatesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMealTemplate(
      {required String label,
      required List<Map<String, dynamic>> items}) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getMealTemplates();
    final tpl = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch,
      'label': label,
      'items': items,
      'createdAt': DateTime.now().toIso8601String(),
    };
    templates.add(tpl);
    await prefs.setString(_templatesKey, jsonEncode(templates));
  }

  static Future<void> removeMealTemplate(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getMealTemplates();
    templates.removeWhere((e) => e['id'] == id);
    await prefs.setString(_templatesKey, jsonEncode(templates));
  }

  static Future<void> insertTemplateOnDate(DateTime date,
      Map<String, dynamic> template, String targetMealKey) async {
    final List<Map<String, dynamic>> items =
        (template['items'] as List).cast<Map<String, dynamic>>();
    for (final it in items) {
      final entry = Map<String, dynamic>.from(it);
      entry['id'] = null; // force new id
      entry['mealTime'] = targetMealKey;
      entry['createdAt'] = DateTime.now().toIso8601String();
      await addEntry(date, entry);
    }
  }

  // ---------------------- Day Templates ----------------------
  static Future<List<Map<String, dynamic>>> getDayTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dayTemplatesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveDayTemplate({
    required String label,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getDayTemplates();
    final items = await getEntriesForDate(date);
    final water = await getWaterMl(date);
    final exercise = await getExerciseCalories(date);
    final tpl = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch,
      'label': label,
      'createdAt': DateTime.now().toIso8601String(),
      'items': items,
      'waterMl': water,
      'exerciseKcal': exercise,
    };
    templates.add(tpl);
    await prefs.setString(_dayTemplatesKey, jsonEncode(templates));
  }

  static Future<void> removeDayTemplate(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getDayTemplates();
    templates.removeWhere((e) => e['id'] == id);
    await prefs.setString(_dayTemplatesKey, jsonEncode(templates));
  }

  static Future<void> applyDayTemplateOnDate({
    required Map<String, dynamic> template,
    required DateTime date,
    bool includeWaterAndExercise = true,
  }) async {
    final List<Map<String, dynamic>> items =
        (template['items'] as List).cast<Map<String, dynamic>>();
    for (final it in items) {
      final entry = Map<String, dynamic>.from(it);
      entry['id'] = null;
      entry['createdAt'] = DateTime.now().toIso8601String();
      await addEntry(date, entry);
    }
    if (includeWaterAndExercise) {
      final water = (template['waterMl'] as num?)?.toInt();
      final ex = (template['exerciseKcal'] as num?)?.toInt();
      if (water != null) {
        await setWaterMl(date, water);
      }
      if (ex != null) {
        await setExerciseCalories(date, ex);
      }
    }
  }

  // ---------------------- Week Templates ----------------------
  static Future<List<Map<String, dynamic>>> getWeekTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weekTemplatesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWeekTemplate({
    required String label,
    required DateTime monday,
  }) async {
    // normalize to Monday
    final m = monday.subtract(Duration(days: (monday.weekday - 1)));
    final days = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      final d = m.add(Duration(days: i));
      final items = await getEntriesForDate(d);
      final water = await getWaterMl(d);
      final exercise = await getExerciseCalories(d);
      days.add({
        'offset': i,
        'items': items,
        'waterMl': water,
        'exerciseKcal': exercise,
      });
    }
    final prefs = await SharedPreferences.getInstance();
    final templates = await getWeekTemplates();
    final tpl = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch,
      'label': label,
      'createdAt': DateTime.now().toIso8601String(),
      'anchorMonday': m.toIso8601String(),
      'days': days,
    };
    templates.add(tpl);
    await prefs.setString(_weekTemplatesKey, jsonEncode(templates));
  }

  static Future<void> removeWeekTemplate(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getWeekTemplates();
    templates.removeWhere((e) => e['id'] == id);
    await prefs.setString(_weekTemplatesKey, jsonEncode(templates));
  }

  static Future<void> applyWeekTemplateOnMonday({
    required Map<String, dynamic> template,
    required DateTime monday,
    bool includeWaterAndExercise = true,
  }) async {
    final m = monday.subtract(Duration(days: (monday.weekday - 1)));
    final List<Map<String, dynamic>> days =
        (template['days'] as List).cast<Map<String, dynamic>>();
    for (final day in days) {
      final offset = (day['offset'] as num?)?.toInt() ?? 0;
      final date = m.add(Duration(days: offset));
      final List<Map<String, dynamic>> items =
          (day['items'] as List).cast<Map<String, dynamic>>();
      for (final it in items) {
        final entry = Map<String, dynamic>.from(it);
        entry['id'] = null;
        entry['createdAt'] = DateTime.now().toIso8601String();
        await addEntry(date, entry);
      }
      if (includeWaterAndExercise) {
        final water = (day['waterMl'] as num?)?.toInt();
        final ex = (day['exerciseKcal'] as num?)?.toInt();
        if (water != null) await setWaterMl(date, water);
        if (ex != null) await setExerciseCalories(date, ex);
      }
    }
  }

  // Duplicate data
  static Future<void> duplicateDay(DateTime from, DateTime to) async {
    final entries = await getEntriesForDate(from);
    for (final e in entries) {
      await addEntry(to, e);
    }
    final water = await getWaterMl(from);
    await setWaterMl(to, water);
    final ex = await getExerciseCalories(from);
    await setExerciseCalories(to, ex);
  }

  static Future<void> duplicateWeek(
      DateTime mondayFrom, DateTime mondayTo) async {
    for (int i = 0; i < 7; i++) {
      await duplicateDay(
          mondayFrom.add(Duration(days: i)), mondayTo.add(Duration(days: i)));
    }
  }

  // ---------------------- Clear helpers ----------------------
  static Future<void> clearDayFully(DateTime date) async {
    await clearDate(date);
    await setWaterMl(date, 0);
    await setExerciseCalories(date, 0);
  }

  static Future<void> clearWeekFully(DateTime monday) async {
    final m = monday.subtract(Duration(days: (monday.weekday - 1)));
    for (int i = 0; i < 7; i++) {
      await clearDayFully(m.add(Duration(days: i)));
    }
  }
}

