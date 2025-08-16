import 'package:flutter/foundation.dart';

import 'nutrition_storage.dart';
import 'user_preferences.dart';

@immutable
class MealSummary {
  final int goalKcal;
  final int goalCarb;
  final int goalProt;
  final int goalFat;
  final int usedKcal;
  final int usedCarb;
  final int usedProt;
  final int usedFat;

  const MealSummary({
    required this.goalKcal,
    required this.goalCarb,
    required this.goalProt,
    required this.goalFat,
    required this.usedKcal,
    required this.usedCarb,
    required this.usedProt,
    required this.usedFat,
  });

  int get remainingKcal => (goalKcal - usedKcal).clamp(0, goalKcal);
  int get remainingCarb => (goalCarb - usedCarb).clamp(0, goalCarb);
  int get remainingProt => (goalProt - usedProt).clamp(0, goalProt);
  int get remainingFat => (goalFat - usedFat).clamp(0, goalFat);
}

class MealSummaryService {
  static Future<MealSummary> compute({
    required DateTime date,
    required String mealKey, // breakfast | lunch | dinner | snack
  }) async {
    final goalsMap = await UserPreferences.getMealGoals();
    final g = goalsMap[mealKey];
    final entries = await NutritionStorage.getEntriesForDate(date);
    int usedK = 0, usedC = 0, usedP = 0, usedF = 0;
    for (final e in entries) {
      if ((e['mealTime'] as String?) == mealKey) {
        usedK += (e['calories'] as num?)?.toInt() ?? 0;
        usedC += (e['carbs'] as num?)?.toInt() ?? 0;
        usedP += (e['protein'] as num?)?.toInt() ?? 0;
        usedF += (e['fat'] as num?)?.toInt() ?? 0;
      }
    }
    return MealSummary(
      goalKcal: g?.kcal ?? 0,
      goalCarb: g?.carbs ?? 0,
      goalProt: g?.proteins ?? 0,
      goalFat: g?.fats ?? 0,
      usedKcal: usedK,
      usedCarb: usedC,
      usedProt: usedP,
      usedFat: usedF,
    );
  }
}


