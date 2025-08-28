import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static const String _kTotalCalories = 'user_goal_total_calories';
  static const String _kCarbs = 'user_goal_carbs';
  static const String _kProteins = 'user_goal_proteins';
  static const String _kFats = 'user_goal_fats';
  static const String _kWaterMl = 'user_goal_water_ml';
  static const String _kExerciseKcal = 'user_goal_exercise_kcal';
  static const String _kHydrationEnabled = 'hydration_enabled';
  static const String _kHydrationIntervalMin = 'hydration_interval_min';
  // Per-meal goals (kcal/macros)
  static const String _kMealKcalBreakfast = 'meal_goal_kcal_breakfast';
  static const String _kMealKcalLunch = 'meal_goal_kcal_lunch';
  static const String _kMealKcalDinner = 'meal_goal_kcal_dinner';
  static const String _kMealKcalSnack = 'meal_goal_kcal_snack';
  static const String _kMealCarbBreakfast = 'meal_goal_carb_breakfast';
  static const String _kMealCarbLunch = 'meal_goal_carb_lunch';
  static const String _kMealCarbDinner = 'meal_goal_carb_dinner';
  static const String _kMealCarbSnack = 'meal_goal_carb_snack';
  static const String _kMealProtBreakfast = 'meal_goal_prot_breakfast';
  static const String _kMealProtLunch = 'meal_goal_prot_lunch';
  static const String _kMealProtDinner = 'meal_goal_prot_dinner';
  static const String _kMealProtSnack = 'meal_goal_prot_snack';
  static const String _kMealFatBreakfast = 'meal_goal_fat_breakfast';
  static const String _kMealFatLunch = 'meal_goal_fat_lunch';
  static const String _kMealFatDinner = 'meal_goal_fat_dinner';
  static const String _kMealFatSnack = 'meal_goal_fat_snack';
  static const String _kNewBadgeMinutes = 'ui_new_badge_minutes';
  static const String _kQuickPortionGrams = 'ui_quick_portion_grams_v1';
  static const String _kQuickPortionGramsBreakfast =
      'ui_quick_portion_grams_breakfast_v1';
  static const String _kQuickPortionGramsLunch =
      'ui_quick_portion_grams_lunch_v1';
  static const String _kQuickPortionGramsDinner =
      'ui_quick_portion_grams_dinner_v1';
  static const String _kQuickPortionGramsSnack =
      'ui_quick_portion_grams_snack_v1';
  // Fasting eating window times
  static const String _kStartEatHour = 'fast_start_eat_hour_v1';
  static const String _kStartEatMinute = 'fast_start_eat_min_v1';
  static const String _kStopEatHour = 'fast_stop_eat_hour_v1';
  static const String _kStopEatMinute = 'fast_stop_eat_min_v1';

  static Future<void> setGoals({
    required int totalCalories,
    required int carbs,
    required int proteins,
    required int fats,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalCalories, totalCalories);
    await prefs.setInt(_kCarbs, carbs);
    await prefs.setInt(_kProteins, proteins);
    await prefs.setInt(_kFats, fats);
  }

  static Future<UserGoals> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(_kTotalCalories) ?? 2000;
    final carbs = prefs.getInt(_kCarbs) ?? 250;
    final proteins = prefs.getInt(_kProteins) ?? 120;
    final fats = prefs.getInt(_kFats) ?? 80;
    final waterMl = prefs.getInt(_kWaterMl) ?? 2000;
    final exerciseKcal = prefs.getInt(_kExerciseKcal) ?? 300;
    return UserGoals(
      totalCalories: total,
      carbs: carbs,
      proteins: proteins,
      fats: fats,
      waterGoalMl: waterMl,
      exerciseGoalKcal: exerciseKcal,
    );
  }

  static Future<void> setWaterGoal(int waterMl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWaterMl, waterMl);
  }

  static Future<void> setExerciseGoal(int kcal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kExerciseKcal, kcal < 0 ? 0 : kcal);
  }

  static Future<int> getExerciseGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kExerciseKcal) ?? 300;
  }

  // Hydration reminders
  static Future<void> setHydrationReminder({
    required bool enabled,
    required int intervalMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHydrationEnabled, enabled);
    await prefs.setInt(_kHydrationIntervalMin, intervalMinutes);
  }

  static Future<HydrationReminderPrefs> getHydrationReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kHydrationEnabled) ?? false;
    final interval = prefs.getInt(_kHydrationIntervalMin) ?? 60;
    return HydrationReminderPrefs(enabled: enabled, intervalMinutes: interval);
  }

  // UI: highlight 'novo' badge duration (minutes)
  static Future<void> setNewBadgeMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kNewBadgeMinutes, minutes);
  }

  static Future<int> getNewBadgeMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kNewBadgeMinutes) ?? 5;
  }

  // Search filters
  static const String _kFiltKcalMin = 'ui_filter_kcal_min_v1';
  static const String _kFiltKcalMax = 'ui_filter_kcal_max_v1';
  static const String _kFiltProt = 'ui_filter_protein_v1';
  static const String _kFiltCarb = 'ui_filter_carb_v1';
  static const String _kFiltFat = 'ui_filter_fat_v1';
  static const String _kSortKey = 'ui_sort_key_v1';
  static const String _kSearchHistory = 'ui_search_history_v1';

  static Future<void> setSearchFilters({
    required double kcalMin,
    required double kcalMax,
    required bool prioritizeProtein,
    required bool prioritizeCarb,
    required bool prioritizeFat,
    required String sortKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFiltKcalMin, kcalMin);
    await prefs.setDouble(_kFiltKcalMax, kcalMax);
    await prefs.setBool(_kFiltProt, prioritizeProtein);
    await prefs.setBool(_kFiltCarb, prioritizeCarb);
    await prefs.setBool(_kFiltFat, prioritizeFat);
    await prefs.setString(_kSortKey, sortKey);
  }

  static Future<
      ({
        double kcalMin,
        double kcalMax,
        bool p,
        bool c,
        bool f,
        String sort
      })> getSearchFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final min = prefs.getDouble(_kFiltKcalMin) ?? 0;
    final max = prefs.getDouble(_kFiltKcalMax) ?? 1000;
    final p = prefs.getBool(_kFiltProt) ?? false;
    final c = prefs.getBool(_kFiltCarb) ?? false;
    final f = prefs.getBool(_kFiltFat) ?? false;
    final sort = prefs.getString(_kSortKey) ?? 'relevance';
    return (kcalMin: min, kcalMax: max, p: p, c: c, f: f, sort: sort);
  }

  // Search history (persist last N queries)
  static Future<List<String>> getSearchHistory({int maxItems = 8}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSearchHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        final list = decoded.map((e) => e.toString()).toList();
        return list.take(maxItems).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> addSearchHistory(String term, {int maxItems = 8}) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = await getSearchHistory(maxItems: maxItems);
    // put most recent first, unique
    final list = [
      t,
      ...current.where((e) => e.toLowerCase() != t.toLowerCase())
    ].take(maxItems).toList();
    await prefs.setString(_kSearchHistory, json.encode(list));
  }

  // UI: quick portion chips (grams)
  static Future<void> setQuickPortionGrams(List<double> grams) async {
    final prefs = await SharedPreferences.getInstance();
    // store as CSV to keep it simple
    final sanitized = grams
        .map((g) => g.clamp(1, 2000))
        .map((g) => (g is int) ? g.toString() : g.toString())
        .join(',');
    await prefs.setString(_kQuickPortionGrams, sanitized);
  }

  static Future<List<double>> getQuickPortionGrams() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kQuickPortionGrams);
    if (raw == null || raw.trim().isEmpty) {
      return [50, 100, 150, 200, 250];
    }
    final parts = raw.split(',');
    final out = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.trim());
      if (v != null && v > 0) out.add(v);
    }
    return out.isEmpty ? [50, 100, 150, 200, 250] : out;
  }

  // Persist eating window times (for fasting reminders)
  static Future<void> setEatingTimes({
    int? startHour,
    int? startMinute,
    int? stopHour,
    int? stopMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (startHour != null) await prefs.setInt(_kStartEatHour, startHour);
    if (startMinute != null) await prefs.setInt(_kStartEatMinute, startMinute);
    if (stopHour != null) await prefs.setInt(_kStopEatHour, stopHour);
    if (stopMinute != null) await prefs.setInt(_kStopEatMinute, stopMinute);
  }

  static Future<({int? startHour, int? startMinute, int? stopHour, int? stopMinute})>
      getEatingTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final sh = prefs.getInt(_kStartEatHour);
    final sm = prefs.getInt(_kStartEatMinute);
    final eh = prefs.getInt(_kStopEatHour);
    final em = prefs.getInt(_kStopEatMinute);
    return (startHour: sh, startMinute: sm, stopHour: eh, stopMinute: em);
  }

  // Per-meal quick portions (fallback to global if empty)
  static String _mealKeyToPref(String meal) {
    switch (meal) {
      case 'breakfast':
        return _kQuickPortionGramsBreakfast;
      case 'lunch':
        return _kQuickPortionGramsLunch;
      case 'dinner':
        return _kQuickPortionGramsDinner;
      case 'snack':
      default:
        return _kQuickPortionGramsSnack;
    }
  }

  static Future<void> setQuickPortionGramsForMeal(
      String meal, List<double> grams) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mealKeyToPref(meal);
    final sanitized = grams
        .map((g) => g.clamp(1, 2000))
        .map((g) => (g is int) ? g.toString() : g.toString())
        .join(',');
    await prefs.setString(key, sanitized);
  }

  static Future<List<double>> getQuickPortionGramsForMeal(String meal) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mealKeyToPref(meal);
    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) {
      return await getQuickPortionGrams();
    }
    final parts = raw.split(',');
    final out = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.trim());
      if (v != null && v > 0) out.add(v);
    }
    if (out.isEmpty) return await getQuickPortionGrams();
    return out;
  }

  // Per-meal goals
  static Future<void> setMealGoals(Map<String, MealGoals> byMeal) async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> save(String meal, MealGoals g) async {
      switch (meal) {
        case 'breakfast':
          await prefs.setInt(_kMealKcalBreakfast, g.kcal);
          await prefs.setInt(_kMealCarbBreakfast, g.carbs);
          await prefs.setInt(_kMealProtBreakfast, g.proteins);
          await prefs.setInt(_kMealFatBreakfast, g.fats);
          break;
        case 'lunch':
          await prefs.setInt(_kMealKcalLunch, g.kcal);
          await prefs.setInt(_kMealCarbLunch, g.carbs);
          await prefs.setInt(_kMealProtLunch, g.proteins);
          await prefs.setInt(_kMealFatLunch, g.fats);
          break;
        case 'dinner':
          await prefs.setInt(_kMealKcalDinner, g.kcal);
          await prefs.setInt(_kMealCarbDinner, g.carbs);
          await prefs.setInt(_kMealProtDinner, g.proteins);
          await prefs.setInt(_kMealFatDinner, g.fats);
          break;
        case 'snack':
        default:
          await prefs.setInt(_kMealKcalSnack, g.kcal);
          await prefs.setInt(_kMealCarbSnack, g.carbs);
          await prefs.setInt(_kMealProtSnack, g.proteins);
          await prefs.setInt(_kMealFatSnack, g.fats);
          break;
      }
    }

    for (final entry in byMeal.entries) {
      await save(entry.key, entry.value);
    }
  }

  static Future<Map<String, MealGoals>> getMealGoals() async {
    final prefs = await SharedPreferences.getInstance();
    MealGoals read(String meal) {
      switch (meal) {
        case 'breakfast':
          return MealGoals(
            kcal: prefs.getInt(_kMealKcalBreakfast) ?? 0,
            carbs: prefs.getInt(_kMealCarbBreakfast) ?? 0,
            proteins: prefs.getInt(_kMealProtBreakfast) ?? 0,
            fats: prefs.getInt(_kMealFatBreakfast) ?? 0,
          );
        case 'lunch':
          return MealGoals(
            kcal: prefs.getInt(_kMealKcalLunch) ?? 0,
            carbs: prefs.getInt(_kMealCarbLunch) ?? 0,
            proteins: prefs.getInt(_kMealProtLunch) ?? 0,
            fats: prefs.getInt(_kMealFatLunch) ?? 0,
          );
        case 'dinner':
          return MealGoals(
            kcal: prefs.getInt(_kMealKcalDinner) ?? 0,
            carbs: prefs.getInt(_kMealCarbDinner) ?? 0,
            proteins: prefs.getInt(_kMealProtDinner) ?? 0,
            fats: prefs.getInt(_kMealFatDinner) ?? 0,
          );
        case 'snack':
        default:
          return MealGoals(
            kcal: prefs.getInt(_kMealKcalSnack) ?? 0,
            carbs: prefs.getInt(_kMealCarbSnack) ?? 0,
            proteins: prefs.getInt(_kMealProtSnack) ?? 0,
            fats: prefs.getInt(_kMealFatSnack) ?? 0,
          );
      }
    }

    return {
      'breakfast': read('breakfast'),
      'lunch': read('lunch'),
      'dinner': read('dinner'),
      'snack': read('snack'),
    };
  }
}

class UserGoals {
  final int totalCalories;
  final int carbs;
  final int proteins;
  final int fats;
  final int waterGoalMl;
  final int exerciseGoalKcal;

  const UserGoals({
    required this.totalCalories,
    required this.carbs,
    required this.proteins,
    required this.fats,
    this.waterGoalMl = 2000,
    this.exerciseGoalKcal = 300,
  });
}

class HydrationReminderPrefs {
  final bool enabled;
  final int intervalMinutes;

  const HydrationReminderPrefs({
    required this.enabled,
    required this.intervalMinutes,
  });
}

class MealGoals {
  final int kcal;
  final int carbs;
  final int proteins;
  final int fats;

  const MealGoals({
    required this.kcal,
    required this.carbs,
    required this.proteins,
    required this.fats,
  });
}
