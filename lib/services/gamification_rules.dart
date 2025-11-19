// Regras puras de gamificação (streaks, conquistas, metas) centralizadas.
// Objetivo: tirar lógica sensível de dentro dos widgets e facilitar testes.

class DailyGoals {
  final int calorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final int waterGoalMl;

  const DailyGoals({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoalMl,
  });
}

class DailyIntake {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int waterMl;

  const DailyIntake({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.waterMl,
  });
}

class GamificationRules {
  const GamificationRules._();

  /// Determina se o dia é considerado "ok" em calorias.
  /// Política atual (ajustável):
  /// - Dentro de [0, goal] é aceito.
  static bool isCaloriesDayOk(DailyIntake intake, DailyGoals goals) {
    if (goals.calorieGoal <= 0) return false;
    return intake.calories <= goals.calorieGoal && intake.calories >= 0;
  }

  /// Proteína ok se chegar em pelo menos X% da meta (ex.: 90%).
  static bool isProteinOk(DailyIntake intake, DailyGoals goals,
      {double threshold = 0.9}) {
    if (goals.proteinGoal <= 0) return false;
    return intake.protein >= (goals.proteinGoal * threshold).round();
  }

  /// Hidratação ok se atingir pelo menos 100% da meta.
  static bool isHydrationOk(DailyIntake intake, DailyGoals goals) {
    if (goals.waterGoalMl <= 0) return false;
    return intake.waterMl >= goals.waterGoalMl;
  }

  /// Exemplo de regra de streak simples:
  /// - Se o dia atual cumprir a condição, incrementa.
  /// - Caso contrário, reseta para 0.
  static int nextStreak({
    required bool todayOk,
    required int previousStreak,
  }) {
    if (!todayOk) return 0;
    if (previousStreak < 0) return 1;
    return previousStreak + 1;
  }
}