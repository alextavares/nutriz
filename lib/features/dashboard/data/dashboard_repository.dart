import '../../../services/nutrition_storage.dart';
import '../../../services/user_preferences.dart';
import '../../../services/daily_goal_service.dart';
import '../../../services/notes_storage.dart';
import '../../../services/body_metrics_storage.dart';

class DashboardRepository {
  // Singleton pattern for now to match existing service usage, 
  // but designed to be injectable later.
  static final DashboardRepository _instance = DashboardRepository._internal();
  factory DashboardRepository() => _instance;
  DashboardRepository._internal();

  /// Loads the daily summary (calories, macros, water) for a specific date.
  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final entries = await NutritionStorage.getEntriesForDate(date);
    final waterMl = await NutritionStorage.getWaterMl(date);
    final exerciseKcal = await NutritionStorage.getExerciseCalories(date);

    int calories = 0;
    int carbs = 0;
    int protein = 0;
    int fat = 0;

    for (var e in entries) {
      calories += (e['calories'] as num?)?.toInt() ?? 0;
      carbs += (e['carbs'] as num?)?.toInt() ?? 0;
      protein += (e['protein'] as num?)?.toInt() ?? 0;
      fat += (e['fat'] as num?)?.toInt() ?? 0;
    }

    return {
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'waterMl': waterMl,
      'exerciseKcal': exerciseKcal,
      'entries': entries,
    };
  }

  /// Loads user goals (calories, macros, water).
  Future<Map<String, int>> getUserGoals() async {
    final goals = await UserPreferences.getGoals();
    return {
      'calories': goals.totalCalories,
      'carbs': goals.carbs,
      'protein': goals.proteins,
      'fat': goals.fats,
      'waterMl': goals.waterGoalMl,
    };
  }

  /// Adds water intake.
  Future<void> addWater(DateTime date, int amountMl) async {
    await NutritionStorage.addWaterMl(date, amountMl);
  }

  /// Removes water intake (undo).
  Future<void> removeWater(DateTime date, int amountMl) async {
    await NutritionStorage.addWaterMl(date, -amountMl);
  }

  /// Deletes a food entry by ID.
  Future<void> deleteEntry(DateTime date, dynamic id) async {
    await NutritionStorage.removeEntryById(date, id);
  }

  // --- Weight & Notes ---

  Future<double?> getWeight(DateTime date) async {
    final metrics = await BodyMetricsStorage.getForDate(date);
    return (metrics['weightKg'] as num?)?.toDouble();
  }

  Future<void> setWeight(DateTime date, double weight) async {
    final metrics = await BodyMetricsStorage.getForDate(date);
    metrics['weightKg'] = weight;
    await BodyMetricsStorage.setForDate(date, metrics);
  }

  Future<Map<String, dynamic>?> getNote(DateTime date) async {
    final allNotes = await NotesStorage.getAll();
    final dateStr = _dateKey(date);
    // Filter notes for this date
    final notesForDate = allNotes.where((n) {
      // NotesStorage uses createdAt/updatedAt, not 'date'
      final rawDate = (n['createdAt'] ?? n['updatedAt']) as String?;
      if (rawDate == null) return false;
      // Check if the ISO string starts with the YYYY-MM-DD part
      return rawDate.startsWith(dateStr);
    }).toList();
    
    if (notesForDate.isEmpty) return null;
    // Return the last note (most recent)
    return notesForDate.last;
  }

  // Helper to match NutritionStorage date key format
  String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
