import 'package:shared_preferences/shared_preferences.dart';

import 'achievement_service.dart';
import 'streak_service.dart';

enum GamificationEventType {
  goalStarted,
  goalCompleted,
  streakIncremented,
  milestoneReached,
  badgeUnlocked,
}

class GamificationEvent {
  final GamificationEventType type;
  final String metaKey; // e.g., 'water', 'fasting'
  final num? value; // optional payload
  GamificationEvent({
    required this.type,
    required this.metaKey,
    this.value,
  });
}

typedef CelebrationCallback = void Function(GamificationEvent e);

class GamificationEngine {
  GamificationEngine._();
  static final GamificationEngine I = GamificationEngine._();

  CelebrationCallback? onCelebrate;

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Fire-and-forget handler; returns whether a celebration overlay is recommended
  Future<bool> fire(GamificationEvent e) async {
    switch (e.type) {
      case GamificationEventType.goalCompleted:
        return _handleGoalCompleted(e);
      case GamificationEventType.streakIncremented:
        return _handleStreakIncremented(e);
      case GamificationEventType.milestoneReached:
      case GamificationEventType.badgeUnlocked:
      case GamificationEventType.goalStarted:
        // For MVP just return false
        return false;
    }
  }

  Future<bool> _handleGoalCompleted(GamificationEvent e) async {
    // For MVP: special-case water and fasting
    if (e.metaKey == 'water') {
      final prefs = await SharedPreferences.getInstance();
      final key = 'water_celebrated_${_todayKey()}';
      if ((prefs.getBool(key) ?? false) == false) {
        await prefs.setBool(key, true);
        // Mark streak completed today
        await StreakService.markCompleted('water', DateTime.now());
        // Optional: add simple achievement after 7 days
        final streak = await StreakService.currentStreak('water');
        // Milestones for water
        const milestones = [3, 5, 7, 14, 30];
        if (milestones.contains(streak)) {
          await AchievementService.add({
            'id': 'water_${streak}_${DateTime.now().millisecondsSinceEpoch}',
            'type': 'success',
            'title': streak == 7 ? '7 dias de água!' : 'Água ${streak} dias!',
            'dateIso': DateTime.now().toIso8601String(),
            'metaKey': 'water',
            'value': streak,
          });
        }
        onCelebrate?.call(e);
        return true;
      }
    }
    if (e.metaKey == 'fasting') {
      final prefs = await SharedPreferences.getInstance();
      final key = 'fasting_celebrated_${_todayKey()}';
      if ((prefs.getBool(key) ?? false) == false) {
        await prefs.setBool(key, true);
        await StreakService.markCompleted('fasting', DateTime.now());
        final streak = await StreakService.currentStreak('fasting');
        const milestones = [3, 5, 7, 14, 30];
        if (milestones.contains(streak)) {
          await AchievementService.add({
            'id': 'fasting_${streak}_${DateTime.now().millisecondsSinceEpoch}',
            'type': 'flame',
            'title': 'Jejum ${streak} dias!',
            'dateIso': DateTime.now().toIso8601String(),
            'metaKey': 'fasting',
            'value': streak,
          });
        }
        onCelebrate?.call(e);
        return true;
      }
    }
    if (e.metaKey == 'commitment') {
      final prefs = await SharedPreferences.getInstance();
      final key = 'commitment_celebrated_${_todayKey()}';
      if ((prefs.getBool(key) ?? false) == false) {
        await prefs.setBool(key, true);
        await StreakService.markCompleted('commitment', DateTime.now());
        final streak = await StreakService.currentStreak('commitment');
        const milestones = [1, 3, 7];
        if (milestones.contains(streak)) {
          await AchievementService.add({
            'id': 'commitment_${streak}_${DateTime.now().millisecondsSinceEpoch}',
            'type': 'spark',
            'title': streak == 1 ? 'Compromisso iniciado' : 'Compromisso ${streak} dias!',
            'dateIso': DateTime.now().toIso8601String(),
            'metaKey': 'commitment',
            'value': streak,
          });
        }
        onCelebrate?.call(e);
        return true;
      }
    }
    return false;
  }

  Future<bool> _handleStreakIncremented(GamificationEvent e) async {
    // Show celebration only on meaningful streak milestones
    // Supported metas: water, fasting, calories_ok_day, protein
    final key = e.metaKey;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    final dedupKey = 'streak_celebrated_${key}_$todayKey';
    if ((prefs.getBool(dedupKey) ?? false) == true) return false;

    // Mark today as celebrated for this streak to avoid duplicate overlays
    await prefs.setBool(dedupKey, true);

    final streak = await StreakService.currentStreak(key);
    const milestones = [3, 5, 7, 14, 30];
    if (!milestones.contains(streak)) return false;

    await AchievementService.add({
      'id': 'streak_${key}_${streak}_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'flame',
      'title': '$streak dias de $key!',
      'dateIso': DateTime.now().toIso8601String(),
      'metaKey': key,
      'value': streak,
    });
    onCelebrate?.call(e);
    return true;
  }
}
