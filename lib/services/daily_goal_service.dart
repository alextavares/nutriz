import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_storage.dart';
import 'user_preferences.dart';
import 'streak_service.dart';
import 'achievement_service.dart';
import 'gamification_rules.dart';

/// Daily goals evaluators (e.g., protein target reached today)
///
/// Integra as regras puras de [GamificationRules] com:
/// - NutritionStorage (dados reais do dia)
/// - UserPreferences (metas configuradas)
/// - StreakService (persistência de streak)
/// - AchievementService (criação de conquistas)
class DailyGoalService {
  static const _kProteinMarkedKey =
      'protein_ok_marked_day_v1'; // per-day marker to avoid repeat work
  static const _kCaloriesMarkedKey = 'cal_ok_marked_day_v1';

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Helper para construir metas diárias a partir das preferências atuais.
  static DailyGoals _buildGoalsFromPrefs(goalsPrefs) {
    return DailyGoals(
      calorieGoal:
          goalsPrefs.totalCalories <= 0 ? 2000 : goalsPrefs.totalCalories,
      proteinGoal: goalsPrefs.proteins <= 0 ? 100 : goalsPrefs.proteins,
      carbsGoal: goalsPrefs.carbs,
      fatGoal: goalsPrefs.fats,
      waterGoalMl: goalsPrefs.waterGoalMl <= 0 ? 2000 : goalsPrefs.waterGoalMl,
    );
  }

  /// Helper para obter intake diário de forma consistente (pelo menos calorias/proteína/água).
  static Future<DailyIntake> _loadTodayIntake(DateTime today) async {
    final entries = await NutritionStorage.getEntriesForDate(today);
    final totalKcal = entries.fold<int>(
      0,
      (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0),
    );
    final totalProt = entries.fold<int>(
      0,
      (sum, e) => sum + ((e['proteins'] as num?)?.toInt() ?? 0),
    );

    // Placeholder para água: manter 0 até integrar corretamente com a fonte oficial
    // (ex.: armazenamento específico de água). Isso evita quebrar o build.
    const waterMl = 0;

    return DailyIntake(
      calories: totalKcal,
      protein: totalProt,
      carbs: 0,
      fat: 0,
      waterMl: waterMl,
    );
  }

  /// Avalia se hoje atingiu a meta de proteína usando [GamificationRules.isProteinOk].
  /// Mantém contrato antigo: marca streak 'protein' e cria achievements em marcos específicos.
  static Future<bool> evaluateProteinOkToday() async {
    final prefs = await SharedPreferences.getInstance();
    final markerKey = '$_kProteinMarkedKey-${_todayKey()}';
    if (prefs.getBool(markerKey) == true) {
      return false; // já processado hoje
    }

    final today = DateTime.now();
    final entries = await NutritionStorage.getEntriesForDate(today);
    final totalProt = entries.fold<int>(
      0,
      (sum, e) => sum + ((e['proteins'] as num?)?.toInt() ?? 0),
    );
    final goalsPrefs = await UserPreferences.getGoals();

    final goals = DailyGoals(
      calorieGoal:
          goalsPrefs.totalCalories <= 0 ? 2000 : goalsPrefs.totalCalories,
      proteinGoal: goalsPrefs.proteins <= 0 ? 100 : goalsPrefs.proteins,
      carbsGoal: goalsPrefs.carbs,
      fatGoal: goalsPrefs.fats,
      waterGoalMl: goalsPrefs.waterGoalMl,
    );

    final intake = DailyIntake(
      calories: 0,
      // não precisamos das outras métricas aqui
      protein: totalProt,
      carbs: 0,
      fat: 0,
      waterMl: 0,
    );

    final proteinOk = GamificationRules.isProteinOk(intake, goals);

    if (proteinOk) {
      final day = DateTime(today.year, today.month, today.day);
      await StreakService.markCompleted('protein', day);
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

  /// Avalia se hoje atingiu a meta de hidratação usando [GamificationRules.isHydrationOk].
  /// Quando ok, marca streak 'water'. Mantém comportamento isolado e opcional.
  static Future<bool> evaluateHydrationOkToday() async {
    final prefs = await SharedPreferences.getInstance();
    // Reutiliza chave estável semelhante às demais, sem quebrar histórico existente.
    const keyBase = 'water_ok_marked_day_v1';
    final markerKey = '$keyBase-${_todayKey()}';
    if (prefs.getBool(markerKey) == true) return false;

    final today = DateTime.now();
    final goalsPrefs = await UserPreferences.getGoals();
    final goals = _buildGoalsFromPrefs(goalsPrefs);
    final intake = await _loadTodayIntake(today);

    final hydrationOk = GamificationRules.isHydrationOk(intake, goals);
    if (hydrationOk) {
      final day = DateTime(today.year, today.month, today.day);
      await StreakService.markCompleted('water', day);
      // Sem achievements específicos aqui por enquanto para não introduzir
      // mudanças de produto inesperadas.
    }

    await prefs.setBool(markerKey, true);
    return true;
  }

  /// Avalia se hoje foi um dia "ok" em calorias usando [GamificationRules.isCaloriesDayOk].
  /// Mantém contrato antigo: marca 'calories_ok_day' e cria achievements nos mesmos marcos.
  static Future<bool> evaluateCaloriesOkToday() async {
    final prefs = await SharedPreferences.getInstance();
    final markerKey = '$_kCaloriesMarkedKey-${_todayKey()}';
    if (prefs.getBool(markerKey) == true) return false;

    final today = DateTime.now();
    final entries = await NutritionStorage.getEntriesForDate(today);
    final kcal = entries.fold<int>(
      0,
      (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0),
    );
    final goalsPrefs = await UserPreferences.getGoals();

    final goals = DailyGoals(
      calorieGoal:
          goalsPrefs.totalCalories <= 0 ? 2000 : goalsPrefs.totalCalories,
      proteinGoal: goalsPrefs.proteins,
      carbsGoal: goalsPrefs.carbs,
      fatGoal: goalsPrefs.fats,
      waterGoalMl: goalsPrefs.waterGoalMl,
    );

    final intake = DailyIntake(
      calories: kcal,
      protein: 0,
      carbs: 0,
      fat: 0,
      waterMl: 0,
    );

    final caloriesOk = GamificationRules.isCaloriesDayOk(intake, goals);

    if (caloriesOk) {
      final day = DateTime(today.year, today.month, today.day);
      await StreakService.markCompleted('calories_ok_day', day);
      final streak = await StreakService.currentStreak('calories_ok_day');
      if (streak == 3 ||
          streak == 5 ||
          streak == 7 ||
          streak == 14 ||
          streak == 30) {
        await AchievementService.add({
          'id':
              'cal_ok_${streak}_${DateTime.now().millisecondsSinceEpoch}',
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
