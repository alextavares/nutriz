// DashboardOverviewService
// Versão segura (stub) para futura consolidação do dashboard diário.
// IMPORTANTE: nesta fase NÃO é usada pela UI e NÃO chama métodos inexistentes.
// Serve apenas como contrato/documentação para a próxima etapa de refino.

import 'dart:async';

import '../services/nutrition_storage.dart';
import '../services/streak_service.dart';
import '../services/achievement_service.dart';

/// Serviço de agregação para o dashboard diário.
/// Atualmente implementa apenas partes baseadas em APIs existentes.
class DailyOverviewService {
  const DailyOverviewService();

  /// Carrega entradas de refeição do dia.
  /// Mantém 1:1 com NutritionStorage.getEntriesForDate.
  Future<DailyOverviewData> loadForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    final entries =
        await NutritionStorage.getEntriesForDate(normalized);

    return DailyOverviewData(
      date: normalized,
      entries: entries,
    );
  }

  /// Carrega streaks e conquistas recentes usando apenas serviços existentes.
  Future<GamificationSnapshot> loadGamificationSnapshot() async {
    final water = await StreakService.currentStreak('water');
    final fast = await StreakService.currentStreak('fasting');
    final caloriesOk = await StreakService.currentStreak('calories_ok_day');
    final protein = await StreakService.currentStreak('protein');
    final all = await AchievementService.listAll();

    all.sort((a, b) {
      final as = a['dateIso'] as String?;
      final bs = b['dateIso'] as String?;
      if (as == null && bs == null) return 0;
      if (as == null) return 1;
      if (bs == null) return -1;
      return bs.compareTo(as);
    });

    final latest = all.take(6).toList();

    return GamificationSnapshot(
      waterStreak: water,
      fastingStreak: fast,
      caloriesStreak: caloriesOk,
      proteinStreak: protein,
      latestAchievements: latest,
    );
  }

  /// Verifica se há conquistas novas para eventual celebração.
  /// NÃO dispara UI; apenas atualiza o marcador em AchievementService.
  Future<bool> markAndCheckNewAchievementsSeen() async {
    final lastAdded = await AchievementService.getLastAddedTs();
    final lastSeen = await AchievementService.getLastSeenTs();
    if (lastAdded > 0 && lastAdded > lastSeen) {
      await AchievementService.setLastSeenTs(lastAdded);
      return true;
    }
    return false;
  }
}

/// Snapshot mínimo dos dados diários suportados hoje.
class DailyOverviewData {
  final DateTime date;
  final List<Map<String, dynamic>> entries;

  const DailyOverviewData({
    required this.date,
    required this.entries,
  });
}

/// Snapshot dos dados de gamificação necessários para o header do dashboard.
class GamificationSnapshot {
  final int waterStreak;
  final int fastingStreak;
  final int caloriesStreak;
  final int proteinStreak;
  final List<Map<String, dynamic>> latestAchievements;

  const GamificationSnapshot({
    required this.waterStreak,
    required this.fastingStreak,
    required this.caloriesStreak,
    required this.proteinStreak,
    required this.latestAchievements,
  });
}