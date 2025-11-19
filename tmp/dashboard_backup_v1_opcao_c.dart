


import 'package:flutter/material.dart';


import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/achievement_service.dart';
import '../../services/daily_goal_service.dart';
import '../../services/fasting_storage.dart';
import '../../services/nutrition_storage.dart';
import '../../services/notifications_service.dart';
import '../../services/streak_service.dart';
import '../../services/user_preferences.dart' as prefs;
import '../../services/weekly_goal_service.dart';
import '../common/celebration_overlay.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/water_tracker_card_v2.dart';
import './widgets/body_metrics_card.dart';
import '../../widgets/notes_card.dart';
import '../../components/animated_card.dart';
import '../../components/calorie_ring.dart';
import '../../services/notes_storage.dart';
import '../../services/body_metrics_storage.dart';
import 'widgets/meal_plan_section_widget.dart';

class DailyTrackingDashboard extends StatefulWidget {
  const DailyTrackingDashboard({super.key});

  @override
  State<DailyTrackingDashboard> createState() => _DailyTrackingDashboardState();
}

class _DailyTrackingDashboardState extends State<DailyTrackingDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _initArgsHandled = false;
  // Estado principal
  // Removido: _expandedMealKeys (não usado após simplificação dos cards)
  List<Map<String, dynamic>> _todayEntries = [];
  List<int> _weeklyWater = List.filled(7, 0);

  // Meal goals (local DTO mirrored from prefs.MealGoals)
  Map<String, MealGoals> _mealGoals = const {
    'breakfast': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'lunch': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'dinner': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'snack': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
  };

  Map<String, Map<String, int>> _mealTotals = {
    'breakfast': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
    'lunch': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
    'dinner': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
    'snack': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
  };
  final Set<String> _exceededMeals = {};

  int _hydrationStreak = 0;
  int _fastingStreak = 0;
  int _caloriesStreak = 0;
  int _proteinStreak = 0;

  List<Map<String, dynamic>> _achievements = const [];

  bool _showNextMilestoneCaptions = true;

  // Fasting banner state
  bool _fastingActiveMuted = false;
  DateTime? _fastMuteUntil;
  DateTime? _fastEndAt;
  String _fastMethod = 'custom';
  String? _bannerDismissedOn;
  bool _bannerCollapsed = false;
  bool _bannerAlwaysCollapsed = false;

  // Eating window (for banner schedule labels)
  int? _eatStartH;
  int? _eatStartM;
  int? _eatStopH;
  int? _eatStopM;

  // Backing map for main ring + macros; mutated by loaders
  final Map<String, dynamic> _dailyData = {
    "consumedCalories": 0,
    "totalCalories": 2000,
    "spentCalories": 0,
    "waterMl": 0,
    "waterGoalMl": 2000,
    "macronutrients": {
      "carbohydrates": {"consumed": 0, "total": 0},
      "proteins": {"consumed": 0, "total": 0},
      "fats": {"consumed": 0, "total": 0},
    },
  };


  // --- Lifecycle -----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadUiPrefs();
    _ensureAuthenticated();
    _loadToday();
    _loadGoals();
    _loadExercise();
    _loadMealGoals();
    _updateHydrationAchievements();
    // Loop de lembrete de hidratação removido nesta build estável
    _refreshFastingBanner();
    _loadBannerPrefs();
    _loadEatingTimes();
    _refreshGamificationRow();

    WeeklyGoalService.evaluatePerfectCaloriesWeek().then((created) {
      if (created && mounted) _refreshGamificationRow();
    });
    DailyGoalService.evaluateProteinOkToday()
        .then((_) => _refreshGamificationRow());
    DailyGoalService.evaluateCaloriesOkToday()
        .then((_) => _refreshGamificationRow());

    NutritionStorage.changes.addListener(_onStorageChanged);
    prefs.UserPreferences.changes.addListener(_onUiPrefsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initArgsHandled) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final s = args['date']?.toString();
        if (s != null && s.isNotEmpty) {
          try {
            final d = DateTime.parse(s);
            _selectedDate = DateTime(d.year, d.month, d.day);
            _loadToday();
            _loadWeek();
          } catch (_) {}
        }
      }
      _initArgsHandled = true;
    }

    _refreshGamificationRow();
  }

  @override
  void dispose() {
    NutritionStorage.changes.removeListener(_onStorageChanged);
    prefs.UserPreferences.changes.removeListener(_onUiPrefsChanged);
    super.dispose();
  }

  // --- Listeners / prefs ---------------------------------------------------

  void _onStorageChanged() {
    if (!mounted) return;
    _loadToday();
    _loadWeek();
    _loadGoals();
    _loadMealGoals();
  }

  void _onUiPrefsChanged() {
    _loadUiPrefs();
  }

  Future<void> _loadUiPrefs() async {
    final show = await prefs.UserPreferences.getShowNextMilestoneCaptions();
    if (!mounted) return;
    setState(() {
      _showNextMilestoneCaptions = show;
    });
  }

  Future<void> _ensureAuthenticated() async {
    final sp = await SharedPreferences.getInstance();
    bool isAuthenticated = sp.getBool('is_authenticated') ?? false;

    // Dev auto-login in debug
    assert(() {
      isAuthenticated = true;
      sp.setBool('is_authenticated', true);
      sp.setString('user_email', 'dev@local');
      sp.setBool('premium_status', false);
      debugPrint("DEV: auto-login ativo");
      return true;
    }());

    if (!isAuthenticated && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // --- Gamificação / streaks ----------------------------------------------

  int? _nextMilestoneFor(int current, List<int> thresholds) {
    for (final t in thresholds) {
      if (current < t) return t;
    }
    return null;
  }

  Future<void> _refreshGamificationRow() async {
    final hydration = await StreakService.currentStreak('water');
    final fast = await StreakService.currentStreak('fasting');
    final cal = await StreakService.currentStreak('calories_ok_day');
    final prot = await StreakService.currentStreak('protein');
    final ach = await AchievementService.listAll();
    if (!mounted) return;
    ach.sort((a, b) =>
        (b['dateIso'] as String?)?.compareTo(a['dateIso'] as String? ?? '') ??
        0);
    setState(() {
      _hydrationStreak = hydration;
      _fastingStreak = fast;
      _caloriesStreak = cal;
      _proteinStreak = prot;
      _achievements = ach.take(6).toList();
    });

    // Overlay celebração
    final lastAdded = await AchievementService.getLastAddedTs();
    final lastSeen = await AchievementService.getLastSeenTs();
    if (lastAdded > 0 && lastAdded > lastSeen && mounted) {
      await CelebrationOverlay.maybeShow(
        context,
        variant: CelebrationVariant.achievement,
      );
      await AchievementService.setLastSeenTs(lastAdded);
    }
  }

  Future<void> _updateHydrationAchievements() async {
    // Nesta versão, não há API dedicada em AchievementService.
    // Mantemos apenas a atualização visual via _refreshGamificationRow.
    await _refreshGamificationRow();
  }

  Future<void> _updateExerciseStreak() async {
    await _refreshGamificationRow();
  }

  Widget _buildStreakChip({
    required IconData icon,
    required Color baseColor,
    required String label,
    required bool highlightStar,
    required int? next,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: baseColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (highlightStar) ...[
            const SizedBox(width: 6),
            Icon(Icons.star, color: baseColor, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            const SizedBox(width: 6),
            Text(
              '• próx: ${next}d',
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _waterStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.contains(_hydrationStreak);
    final next = _nextMilestoneFor(_hydrationStreak, milestones);
    final label =
        _hydrationStreak > 0 ? '${_hydrationStreak}d água' : 'Sem streak';
    return _buildStreakChip(
      icon: Icons.local_fire_department,
      baseColor: context.semanticColors.warning,
      label: label,
      highlightStar: isMilestone,
      next: next,
    );
  }

  Widget _fastingStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.contains(_fastingStreak);
    final next = _nextMilestoneFor(_fastingStreak, milestones);
    final label =
        _fastingStreak > 0 ? '${_fastingStreak}d jejum' : 'Sem streak jejum';
    return _buildStreakChip(
      icon: Icons.local_fire_department,
      baseColor: context.semanticColors.warning,
      label: label,
      highlightStar: isMilestone,
      next: next,
    );
  }

  Widget _caloriesStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.contains(_caloriesStreak);
    final next = _nextMilestoneFor(_caloriesStreak, milestones);
    final label = _caloriesStreak > 0
        ? '${_caloriesStreak}d calorias ok'
        : 'Sem streak calorias';
    return _buildStreakChip(
      icon: Icons.check_circle,
      baseColor: context.semanticColors.success,
      label: label,
      highlightStar: isMilestone,
      next: next,
    );
  }

  Widget _proteinStreakChip() {
    final milestones = const [5, 7, 14, 30];
    final isMilestone = milestones.contains(_proteinStreak);
    final next = _nextMilestoneFor(_proteinStreak, milestones);
    final label = _proteinStreak > 0
        ? '${_proteinStreak}d proteína ok'
        : 'Sem streak proteína';
    return _buildStreakChip(
      icon: Icons.set_meal,
      baseColor: context.colors.primary,
      label: label,
      highlightStar: isMilestone,
      next: next,
    );
  }

  // --- Fasting banner ------------------------------------------------------

  Future<void> _refreshFastingBanner() async {
    final active = await FastingStorage.getActive();
    final muteUntil = await NotificationsService.getFastingMuteUntil();
    final sp = await SharedPreferences.getInstance();
    final dismissed = sp.getString('fasting_banner_dismissed_on');
    if (!mounted) return;
    final now = DateTime.now();
    final muted = muteUntil != null && now.isBefore(muteUntil);
    setState(() {
      _fastingActiveMuted = active != null && muted;
      _fastMuteUntil = muteUntil;
      _fastEndAt = active != null ? active.start.add(active.target) : null;
      _fastMethod = active?.method ?? 'custom';
      _bannerDismissedOn = dismissed;
    });
  }

  Future<void> _loadBannerPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final always = sp.getBool('fasting_banner_always_collapsed') ?? false;
    if (!mounted) return;
    setState(() {
      _bannerAlwaysCollapsed = always;
      if (always) _bannerCollapsed = true;
    });
  }

  Future<void> _loadEatingTimes() async {
    final t = await prefs.UserPreferences.getEatingTimes();
    if (!mounted) return;
    setState(() {
      _eatStartH = t.startHour;
      _eatStartM = t.startMinute;
      _eatStopH = t.stopHour;
      _eatStopM = t.stopMinute;
    });
  }

  Widget _fastingMuteBanner(BuildContext context) {
    if (!_fastingActiveMuted) return const SizedBox.shrink();

    String two(int v) => v.toString().padLeft(2, '0');
    final todayKey =
        '${DateTime.now().year}-${two(DateTime.now().month)}-${two(DateTime.now().day)}';
    if (_bannerDismissedOn == todayKey) return const SizedBox.shrink();

    final until = _fastMuteUntil;
    final untilLabel = until != null
        ? '${two(until.day)}/${two(until.month)} ${two(until.hour)}:${two(until.minute)}'
        : '';

    final endAt = _fastEndAt;
    String endLabel = '';
    if (endAt != null) {
      final now = DateTime.now();
      final datePrefix =
          (endAt.day != now.day || endAt.month != now.month)
              ? '${two(endAt.day)}/${two(endAt.month)} '
              : '';
      endLabel =
          ' • Término: ${datePrefix}${two(endAt.hour)}:${two(endAt.minute)}';
    }

    String schLabel = '';
    if (_eatStartH != null &&
        _eatStartM != null &&
        _eatStopH != null &&
        _eatStopM != null) {
      schLabel =
          ' • Romper: ${two(_eatStartH!)}:${two(_eatStartM!)} • Iniciar: ${two(_eatStopH!)}:${two(_eatStopM!)}';
    }

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: _bannerCollapsed ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: AppTheme.warningAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.warningAmber.withValues(alpha: 0.4),
          ),
        ),
        constraints: BoxConstraints(
          minHeight: _bannerCollapsed ? 52 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 18,
                  color: (Color.lerp(
                          AppTheme.warningAmber, Colors.white, 0.2) ??
                      AppTheme.warningAmber),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final w = MediaQuery.of(context).size.width;
                      double? fs;
                      if (_bannerCollapsed) {
                        fs = w < 340
                            ? 9.sp
                            : (w < 380 ? 10.sp : 11.sp);
                      }
                      return Text(
                        until != null
                            ? 'Jejum em andamento — silenciado até $untilLabel — término sem notificação$endLabel$schLabel'
                            : 'Jejum em andamento — silenciado — término sem notificação$endLabel$schLabel',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: fs,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: _bannerCollapsed ? 'Expandir' : 'Recolher',
                  onPressed: () {
                    setState(() {
                      _bannerCollapsed = !_bannerCollapsed;
                    });
                  },
                  icon: Icon(
                    _bannerCollapsed
                        ? Icons.expand_more
                        : Icons.expand_less,
                    size: 20,
                    color: cs.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final sp = await SharedPreferences.getInstance();
                    await sp.setString(
                        'fasting_banner_dismissed_on', todayKey);
                    if (!mounted) return;
                    setState(() {
                      _bannerDismissedOn = todayKey;
                    });
                  },
                  child: const Text('Dispensar hoje'),
                ),
              ],
            ),
            if (!_bannerCollapsed) const SizedBox(height: 8),
            if (!_bannerCollapsed)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await NotificationsService.setFastingMuteUntil(null);
                      if (!mounted) return;
                      setState(() => _fastMuteUntil = null);

                      final t =
                          await prefs.UserPreferences.getEatingTimes();
                      if (t.startHour != null &&
                          t.startMinute != null &&
                          t.stopHour != null &&
                          t.stopMinute != null) {
                        await NotificationsService
                            .scheduleDailyFastingReminders(
                          startEatingHour: t.startHour!,
                          startEatingMinute: t.startMinute!,
                          stopEatingHour: t.stopHour!,
                          stopEatingMinute: t.stopMinute!,
                          openTitle: 'Jejum',
                          openBody: 'Lembrete de jejum',
                          startTitle: 'Início do jejum',
                          startBody: 'Seu jejum vai começar',
                        );
                      }

                      if (_fastEndAt != null) {
                        await NotificationsService.scheduleFastingEnd(
                          endAt: _fastEndAt!,
                          method: _fastMethod,
                          title: 'Fim do jejum',
                          body: 'Seu jejum termina agora',
                        );
                      }

                      _refreshFastingBanner();
                    },
                    icon: const Icon(Icons.notifications_active_outlined, size: 16),
                    label: const Text('Reativar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final until =
                          DateTime.now().add(const Duration(hours: 1));
                      await NotificationsService.setFastingMuteUntil(until);
                      await NotificationsService
                          .cancelDailyFastingReminders();
                      await NotificationsService.cancelFastingEnd();
                      _refreshFastingBanner();
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('1h'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final until =
                          DateTime.now().add(const Duration(hours: 4));
                      await NotificationsService.setFastingMuteUntil(until);
                      await NotificationsService
                          .cancelDailyFastingReminders();
                      await NotificationsService.cancelFastingEnd();
                      _refreshFastingBanner();
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('4h'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final until =
                          DateTime.now().add(const Duration(hours: 24));
                      await NotificationsService.setFastingMuteUntil(until);
                      await NotificationsService
                          .cancelDailyFastingReminders();
                      await NotificationsService.cancelFastingEnd();
                      _refreshFastingBanner();
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('24h'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                          context,
                          AppRoutes.intermittentFastingTracker);
                      if (!mounted) return;
                      _refreshFastingBanner();
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Gerenciar'),
                  ),
                ],
              ),
            if (!_bannerCollapsed) const SizedBox(height: 6),
            if (!_bannerCollapsed)
              Row(
                children: [
                  Switch(
                    value: _bannerAlwaysCollapsed,
                    onChanged: (v) async {
                      final sp = await SharedPreferences.getInstance();
                      await sp.setBool(
                          'fasting_banner_always_collapsed', v);
                      if (!mounted) return;
                      setState(() {
                        _bannerAlwaysCollapsed = v;
                        _bannerCollapsed = v ? true : _bannerCollapsed;
                      });
                    },
                    activeColor: AppTheme.activeBlue,
                  ),
                  Text(
                    'Sempre recolher',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- Macro helpers -------------------------------------------------------

  // Nota: helpers de macro estão mantidos por enquanto para possível reuso.
  // Se continuarem sem uso após polimento dos cards, podemos removê-los.

  Widget _calorieBudgetCard(
    BuildContext context, {
    required int goal,
    required int food,
    required int exercise,
    required int remaining,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool exceeded = remaining < 0;
    final int absRemaining = exceeded ? -remaining : remaining;

    final textSmall = theme.textTheme.bodySmall!;
    final textMedium = theme.textTheme.bodyMedium!;
    final textNumber = (theme.textTheme.headlineSmall ??
            theme.textTheme.titleLarge ??
            const TextStyle(fontSize: 24))
        .copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        // Gradient azul claríssimo estilo YAZIO
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withValues(alpha: 0.04),
            cs.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16), // Menor que antes (era 24)
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha superior: Eaten | anel Remaining | Burned
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Eaten
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eaten',
                    style: textSmall.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtInt(food)} kcal',
                    style: textMedium.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Remaining central com anel CalorieRing (estilo YAZIO)
              CalorieRing(
                goal: goal.toDouble(),
                eaten: food.toDouble(),
                burned: exercise.toDouble(),
                size: 140,
                thickness: 14,
                showTicks: false,
                gapDegrees: 40,
              ),

              // Burned
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Burned',
                    style: textSmall.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtInt(exercise)} kcal',
                    style: textMedium.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status "Now: Eating" (estilo YAZIO)
          _buildMealStatusRow(context),
        ],
      ),
    );
  }

  // Helper para mostrar status de refeição atual
  Widget _buildMealStatusRow(BuildContext context) {
    final hour = DateTime.now().hour;
    String status;
    IconData icon;

    if (hour >= 6 && hour < 10) {
      status = 'Breakfast time';
      icon = Icons.free_breakfast;
    } else if (hour >= 12 && hour < 14) {
      status = 'Lunch time';
      icon = Icons.lunch_dining;
    } else if (hour >= 19 && hour < 21) {
      status = 'Dinner time';
      icon = Icons.dinner_dining;
    } else {
      status = 'Eating';
      icon = Icons.restaurant;
    }

    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.warningAmber,
        ),
        const SizedBox(width: 6),
        Text(
          'Now: $status',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _fmtInt(int v) => v.toString();

  // Helper para calcular número da semana no ano (estilo YAZIO)
  int _getWeekNumber() {
    final date = _selectedDate;
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.weekday;
    final daysInFirstWeek = 8 - firstMonday;
    final diff = date.difference(startOfYear).inDays;

    if (diff < daysInFirstWeek) {
      return 1;
    }

    return ((diff - daysInFirstWeek) / 7).floor() + 2;
  }

  // Widget de ícone de status com contador (estilo YAZIO)
  Widget _buildStatusIcon(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // --- Top actions / date nav ---------------------------------------------

  String _localizedTodayLabel(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return lang == 'pt' ? 'Hoje' : 'Today';
  }

  Widget _topActionsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = cs.onSurfaceVariant;
    final w = MediaQuery.of(context).size.width;
    final bool compact = w < 380;
    final bool ultraCompact = w < 350;
    const double iconSize = 20;
    const BoxConstraints iconConstraints =
        BoxConstraints(minWidth: 36, minHeight: 36);

    Widget action(IconData icon, String tip, VoidCallback onTap) => IconButton(
          tooltip: tip,
          icon: Icon(icon, size: iconSize, color: iconColor),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: iconConstraints,
          onPressed: onTap,
        );

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 1),
        initialDate: _selectedDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme:
                  Theme.of(context).colorScheme.copyWith(
                        primary: AppTheme.activeBlue,
                      ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedDate =
              DateTime(picked.year, picked.month, picked.day);
        });
        await _loadToday();
        await _loadWeek();
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.chevron_left,
                size: iconSize, color: cs.onSurfaceVariant),
            onPressed: () async {
              setState(() {
                _selectedDate =
                    _selectedDate.subtract(const Duration(days: 1));
              });
              await _loadToday();
              await _loadWeek();
            },
          ),
          Flexible(
            child: GestureDetector(
              onTap: pickDate,
              child: Builder(
                builder: (context) {
                  final DateTime t = DateTime.now();
                  final today = DateTime(t.year, t.month, t.day);
                  final sel = DateTime(_selectedDate.year,
                      _selectedDate.month, _selectedDate.day);
                  final isToday = sel == today;

                  String label;
                  if (isToday) {
                    label = _localizedTodayLabel(context);
                  } else {
                    final lang = Localizations.localeOf(context)
                        .languageCode
                        .toLowerCase();
                    final wdPt = const [
                      'Seg',
                      'Ter',
                      'Qua',
                      'Qui',
                      'Sex',
                      'Sáb',
                      'Dom',
                    ];
                    final wdEn = const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];
                    final wd = (lang == 'pt' ? wdPt : wdEn)[sel.weekday - 1];
                    final dd = sel.day.toString().padLeft(2, '0');
                    final mm = sel.month.toString().padLeft(2, '0');
                    label = ultraCompact ? '$dd/$mm' : '$wd $dd/$mm';
                  }

                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.chevron_right,
                size: iconSize, color: cs.onSurfaceVariant),
            onPressed: () async {
              setState(() {
                _selectedDate =
                    _selectedDate.add(const Duration(days: 1));
              });
              await _loadToday();
              await _loadWeek();
            },
          ),
          const Spacer(),
          if (!ultraCompact)
            action(Icons.query_stats_outlined, 'Estatísticas', () {
              Navigator.pushNamed(context, AppRoutes.progressOverview);
            }),
          action(Icons.calendar_today_outlined, 'Calendário', pickDate),
          action(Icons.smart_toy_outlined, 'Coach de IA', () {
            Navigator.pushNamed(context, AppRoutes.aiCoachChat);
          }),
          action(Icons.local_fire_department, 'Ações do dia', _openDayActionsMenu),
          action(Icons.emoji_events_outlined, 'Conquistas', () {
            Navigator.pushNamed(context, AppRoutes.achievements);
          }),
          if (!compact) ...[
            action(Icons.accessibility_new_outlined, 'Valores corporais', () {
              Navigator.pushNamed(context, AppRoutes.bodyMetrics);
            }),
            action(Icons.sticky_note_2_outlined, 'Anotações', () {
              Navigator.pushNamed(context, AppRoutes.notes, arguments: {
                'date': _selectedDate.toIso8601String(),
              });
            }),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PopupMenuButton<String>(
                tooltip: 'Mais ações',
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'metrics',
                    child: Text('Valores corporais'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'notes',
                    child: Text('Anotações'),
                  ),
                  if (ultraCompact)
                    const PopupMenuItem<String>(
                      value: 'stats',
                      child: Text('Estatísticas'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'coach',
                    child: Text('Coach de IA'),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'metrics':
                      Navigator.pushNamed(
                          context, AppRoutes.bodyMetrics);
                      break;
                    case 'notes':
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notes,
                        arguments: {
                          'date': _selectedDate.toIso8601String(),
                        },
                      );
                      break;
                    case 'stats':
                      Navigator.pushNamed(
                          context, AppRoutes.progressOverview);
                      break;
                    case 'coach':
                      Navigator.pushNamed(
                          context, AppRoutes.aiCoachChat);
                      break;
                  }
                },
                icon: Icon(Icons.more_vert, size: iconSize, color: iconColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Week agenda ---------------------------------------------------------


  Widget _weekAgenda(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final DateTime selected = _selectedDate;
    final DateTime t = DateTime.now();
    final DateTime today = DateTime(t.year, t.month, t.day);
    final int weekday = selected.weekday;
    final DateTime monday =
        selected.subtract(Duration(days: (weekday - 1)));
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final labelsPt = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final labelsEn = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabels = lang == 'pt' ? labelsPt : labelsEn;

    final items = <Widget>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final bool isSelected = d.year == selected.year &&
          d.month == selected.month &&
          d.day == selected.day;
      final bool isToday =
          d.year == today.year && d.month == today.month && d.day == today.day;

      items.add(
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              setState(() {
                _selectedDate = DateTime(d.year, d.month, d.day);
              });
              await _loadToday();
              await _loadWeek();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : (isToday
                                ? cs.primary
                                : cs.outlineVariant.withValues(alpha: 0.6)),
                        width: isToday && !isSelected ? 1.5 : 1.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      d.day.toString(),
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color:
                                    isSelected ? cs.onPrimary : cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    dayLabels[i],
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(children: items),
    );
  }

  // --- Overall macros row --------------------------------------------------

  Widget _overallMacrosRow(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double fsLabel = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
    final double fsValue = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
    final double barH = w < 360 ? 3 : 4;
    final double vspace = w < 360 ? 4 : 6;

    Widget cell(String label, int consumed, int total, Color color) {
      final ratio = total <= 0 ? 0.0 : (consumed / total).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: fsLabel,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: vspace),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final dotSize = (barH + 3).clamp(4, 8).toDouble();
              final trackColor = Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.35);
              final progressW = (width * ratio).clamp(0.0, width);
              final dotX = (width * ratio).clamp(0.0, width - dotSize);

              return SizedBox(
                height: barH + 6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: 3,
                      bottom: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 3,
                      bottom: 3,
                      child: Container(
                        width: progressW,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned(
                      left: dotX,
                      top: (barH + 6 - dotSize) / 2,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: vspace),
          Text(
            '$consumed/$total g',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: fsValue,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final carbsC =
        (_dailyData["macronutrients"]["carbohydrates"]["consumed"] as int? ??
            0);
    final carbsT =
        (_dailyData["macronutrients"]["carbohydrates"]["total"] as int? ??
            0);
    final protC =
        (_dailyData["macronutrients"]["proteins"]["consumed"] as int? ?? 0);
    final protT =
        (_dailyData["macronutrients"]["proteins"]["total"] as int? ?? 0);
    final fatC =
        (_dailyData["macronutrients"]["fats"]["consumed"] as int? ?? 0);
    final fatT =
        (_dailyData["macronutrients"]["fats"]["total"] as int? ?? 0);

    final double hgap = w < 360 ? 8 : 12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: cell(
            'Carboidratos',
            carbsC,
            carbsT,
            AppTheme.warningAmber,
          ),
        ),
        SizedBox(width: hgap),
        Expanded(
          child: cell(
            'Proteína',
            protC,
            protT,
            AppTheme.successGreen,
          ),
        ),
        SizedBox(width: hgap),
        Expanded(
          child: cell(
            'Gordura',
            fatC,
            fatT,
            AppTheme.activeBlue,
          ),
        ),
      ],
    );
  }
 
  // --- Build: topo rico + cards principais ---------------------------------
 
  @override
  Widget build(BuildContext context) {
    // Mantém a lógica atual de dados, mas mostra um topo mais completo:
    // - Navegação de data (_topActionsRow + _weekAgenda)
    // - Banner de jejum
    // - Chips de streaks
    // - Badges de conquistas
    // - Card principal de calorias + macros
    // - Seções por refeição e água
    final cs = Theme.of(context).colorScheme;
 
    final total = _dailyData["totalCalories"] as int? ?? 0;
    final consumed = _dailyData["consumedCalories"] as int? ?? 0;
    final spent = _dailyData["spentCalories"] as int? ?? 0;
    final remaining = total - consumed + spent;
 
    // Linha compacta de streaks, estilo chip, somente se houver dados.
    Widget streaksRow() {
      if (_hydrationStreak == 0 &&
          _fastingStreak == 0 &&
          _caloriesStreak == 0 &&
          _proteinStreak == 0) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _waterStreakChip(),
              const SizedBox(width: 6),
              _fastingStreakChip(),
              const SizedBox(width: 6),
              _caloriesStreakChip(),
              const SizedBox(width: 6),
              _proteinStreakChip(),
            ],
          ),
        ),
      );
    }

    // Achievements em modo compacto, sem título grande, abaixo dos streaks.
    Widget badgesRow() {
      if (_achievements.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.4.h),
        child: AchievementBadgesWidget(
          achievements: _achievements,
          onBadgeTap: (a) {
            // Bottom sheet compacto, consistente com o estilo YAZIO-like.
            final when = (a['dateIso'] as String?) ?? '';
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.secondaryBackgroundDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.premiumGold,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Conquista',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a['title'] as String? ?? 'Conquista',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        when.isNotEmpty ? 'Obtida em: $when' : '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successGreen,
                            foregroundColor: AppTheme.textPrimary,
                          ),
                          child: const Text('Fechar'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
 
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: cs.primary,
          backgroundColor: cs.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOPO ESTILO YAZIO COMPLETO:
                // Linha 1: "Today" à esquerda + ícones de status à direita
                // Linha 2: "Week X" abaixo de Today
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna esquerda: Today + Week X
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Today" em fonte grande e bold (estilo YAZIO)
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22.sp, // +4sp maior que antes
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // "Week X" em fonte menor e cinza (estilo YAZIO)
                          Text(
                            'Week ${_getWeekNumber()}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Ícones de status (estilo YAZIO) - água, fogo, calendário
                      _buildStatusIcon(
                        Icons.water_drop,
                        _hydrationStreak,
                        cs.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusIcon(
                        Icons.local_fire_department,
                        _fastingStreak,
                        AppTheme.warningAmber,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 1),
                            initialDate: _selectedDate,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(primary: cs.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _selectedDate = DateTime(picked.year, picked.month, picked.day);
                            });
                            await _loadToday();
                            await _loadWeek();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Removemos qualquer indicador de semana/dias aqui.
                SizedBox(height: 0.4.h),
                // Banner de jejum (quando ativo) vem logo abaixo, sutil.
                _fastingMuteBanner(context),
                SizedBox(height: 0.4.h),
                // Entramos direto no card principal de calorias/macros (sem título "Summary" pesado).
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section header like YAZIO: Summary  |  Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: cs.onSurface,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.progressOverview);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Details',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _calorieBudgetCard(
                        context,
                        goal: total,
                        food: consumed,
                        exercise: spent,
                        remaining: remaining,
                      ),
                      SizedBox(height: 10),
                      _overallMacrosRow(context),
                    ],
                  ),
                ),
                SizedBox(height: 1.2.h),

                _buildPerMealProgressSection(),
                SizedBox(height: 1.0.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                SizedBox(height: 1.0.h),
                // Novo card de água premium (YAZIO-like) usando WaterTrackerCardV2.
                // Mantém a fonte de dados real (NutritionStorage) via callbacks.
                Padding(
                  padding: EdgeInsets.only(bottom: 2.0.h),
                  child: WaterTrackerCardV2(
                    currentMl: _dailyData["waterMl"] as int? ?? 0,
                    goalMl: _dailyData["waterGoalMl"] as int? ?? 2000,
                    foodWaterMl: 0,
                    onEditGoal: () async {
                      // Reaproveita fluxo existente de meta de água via UserPreferences.
                      final goals = await prefs.UserPreferences.getGoals();
                      final controller = TextEditingController(
                        text: goals.waterGoalMl.toString(),
                      );
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Meta de água (mL)'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final v = int.tryParse(
                                      controller.text.trim(),
                                    ) ??
                                    goals.waterGoalMl;
                                // Atualiza metas existentes (sem água) para manter compatibilidade
                                await prefs.UserPreferences.setGoals(
                                  totalCalories: goals.totalCalories,
                                  carbs: goals.carbs,
                                  proteins: goals.proteins,
                                  fats: goals.fats,
                                );
                                // Atualiza meta de água usando API correta
                                await prefs.UserPreferences.setWaterGoal(v);
                                if (mounted) {
                                  setState(() {
                                    _dailyData["waterGoalMl"] = v;
                                  });
                                }
                                // ignore: use_build_context_synchronously
                                Navigator.pop(ctx);
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      );
                    },
                    onChange: (delta) async {
                      // Aplica delta em relação ao storage real e retorna novo total.
                      final ml = await NutritionStorage.addWaterMl(
                        _selectedDate,
                        delta,
                      );
                      if (mounted) {
                        setState(() {
                          _dailyData["waterMl"] = ml;
                        });
                      }
                      // Mantém comportamento antigo de atualizações/acúmulos.
                      await _updateHydrationAchievements();
                      return ml;
                    },
                  ),
                ),

                // Body Metrics card (hybrid dark card with sparkline)
                SizedBox(height: 1.2.h),
                AnimatedCard(
                  delay: 220,
                  child: FutureBuilder<List<Object?>>(
                    future: Future.wait([
                      BodyMetricsStorage.getForDate(_selectedDate),
                      BodyMetricsStorage.getRecent(days: 7),
                      prefs.UserPreferences.getWeightGoalKg(),
                    ]),
                    builder: (context, snap) {
                      final data = snap.data;
                      final m = (data != null && data.isNotEmpty && data[0] is Map<String, dynamic>)
                          ? data[0] as Map<String, dynamic>
                          : <String, dynamic>{};
                      final recent = (data != null && data.length > 1 && data[1] is List)
                          ? (data[1] as List)
                              .cast<(DateTime, Map<String, dynamic>)>()
                          : const <(DateTime, Map<String, dynamic>)>[];
                      final goalW = (data != null && data.length > 2)
                          ? data[2] as double?
                          : null;

                      final weeklyWeights = <double>[];
                      for (final e in recent) {
                        final w = (e.$2['weightKg'] as num?)?.toDouble();
                        if (w != null) weeklyWeights.add(w);
                      }
                      double? weeklyChange;
                      if (weeklyWeights.length >= 2) {
                        weeklyChange = weeklyWeights.last - weeklyWeights.first;
                      }
                      final currW = (m['weightKg'] as num?)?.toDouble();

                      return BodyMetricsCard(
                        onAddMetrics: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.bodyMetrics,
                            arguments: {
                              'date': _selectedDate.toIso8601String(),
                              'openEditor': true,
                            },
                          );
                        },
                        currentWeight: currW,
                        goalWeight: goalW,
                        weeklyWeights: weeklyWeights.isEmpty ? null : weeklyWeights,
                        weeklyChange: weeklyChange,
                        hasEntry: m.isNotEmpty,
                        onAdjustWeight: (delta) {
                          () async {
                            final current = await BodyMetricsStorage.getForDate(_selectedDate);
                            final cw = (current['weightKg'] as num?)?.toDouble() ?? 0.0;
                            final next = double.parse((cw + delta).toStringAsFixed(1));
                            current['weightKg'] = next;
                            await BodyMetricsStorage.setForDate(_selectedDate, current);
                            if (!mounted) return;
                            setState(() {});
                          }();
                        },
                      );
                    },
                  ),
                ),

                // Notes card - ÚLTIMO CARD (estilo YAZIO)
                SizedBox(height: 1.2.h),
                AnimatedCard(
                  delay: 240,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: NotesStorage.getAll(),
                    builder: (context, snap) {
                      final list = snap.data ?? const [];
                      int countToday = 0;
                      final d = _selectedDate;
                      final today = DateTime(d.year, d.month, d.day);
                      for (final n in list) {
                        final u = DateTime.tryParse(
                              (n['updatedAt'] ?? n['createdAt']) as String? ?? '') ??
                          DateTime(1970);
                        final dd = DateTime(u.year, u.month, u.day);
                        if (dd == today) countToday++;
                      }
                      // last note preview (most recent by updatedAt/createdAt)
                      Map<String, dynamic>? last;
                      DateTime best = DateTime(1970);
                      for (final n in list) {
                        final u = DateTime.tryParse(
                              (n['updatedAt'] ?? n['createdAt']) as String? ?? '') ??
                            DateTime(1970);
                        if (u.isAfter(best)) {
                          best = u;
                          last = n;
                        }
                      }
                      final preview = (last != null)
                          ? NoteSummary(
                              id: (last!['id']?.toString() ?? ''),
                              text: (last!['text'] as String?) ??
                                  (last!['content'] as String?) ??
                                  '-',
                              createdAt: best,
                            )
                          : null;

                      return NotesCard(
                        lastNote: preview,
                        isLoading: snap.connectionState == ConnectionState.waiting,
                        noteCount: countToday,
                        onAddNote: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.notes,
                            arguments: {
                              'date': _selectedDate.toIso8601String(),
                              'openEditor': true,
                            },
                          );
                        },
                        onViewAll: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.notes,
                            arguments: {
                              'date': _selectedDate.toIso8601String(),
                            },
                          );
                        },
                        onImpression: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
 
  // --- Loaders: hoje / semana / metas / exercício -------------------------

  void _checkMealExceeds() {
    final labels = <String, String>{
      'breakfast': 'Café da manhã',
      'lunch': 'Almoço',
      'dinner': 'Jantar',
      'snack': 'Lanches',
    };

    for (final meal in _mealTotals.keys) {
      final kcal = _mealTotals[meal]!['kcal'] ?? 0;
      final goal = _mealGoals[meal]?.kcal ?? 0;
      final exceeded = goal > 0 && kcal > goal;

      if (exceeded && !_exceededMeals.contains(meal)) {
        _exceededMeals.add(meal);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Meta de ${labels[meal]} excedida: $kcal/$goal kcal'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } else if (!exceeded && _exceededMeals.contains(meal)) {
        _exceededMeals.remove(meal);
      }
    }
  }

  Future<void> _loadToday() async {
    List<Map<String, dynamic>> entries = [];
    try {
      entries = await NutritionStorage.getEntriesForDate(_selectedDate)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('Timeout ao carregar entradas do dia');
        return <Map<String, dynamic>>[];
      });
    } catch (e, st) {
      debugPrint('Erro ao carregar entradas do dia: $e');
      debugPrintStack(stackTrace: st);
      entries = [];
    }

    int consumed = 0;
    int carbs = 0;
    int protein = 0;
    int fat = 0;

    final Map<String, Map<String, int>> mealTotals = {
      'breakfast': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
      'lunch': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
      'dinner': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
      'snack': {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0},
    };

    for (final e in entries) {
      final kcal = (e['calories'] as num?)?.toInt() ?? 0;
      final c = (e['carbs'] as num?)?.toInt() ?? 0;
      final p = (e['protein'] as num?)?.toInt() ?? 0;
      final f = (e['fat'] as num?)?.toInt() ?? 0;
      consumed += kcal;
      carbs += c;
      protein += p;
      fat += f;
      final mt = (e['mealTime'] as String?) ?? 'snack';
      if (!mealTotals.containsKey(mt)) {
        mealTotals[mt] = {'kcal': 0, 'carbs': 0, 'proteins': 0, 'fats': 0};
      }
      mealTotals[mt]!['kcal'] = (mealTotals[mt]!['kcal'] ?? 0) + kcal;
      mealTotals[mt]!['carbs'] = (mealTotals[mt]!['carbs'] ?? 0) + c;
      mealTotals[mt]!['proteins'] =
          (mealTotals[mt]!['proteins'] ?? 0) + p;
      mealTotals[mt]!['fats'] = (mealTotals[mt]!['fats'] ?? 0) + f;
    }

    final water = await NutritionStorage.getWaterMl(_selectedDate);

    if (!mounted) return;
    setState(() {
      _todayEntries = entries;
      _dailyData["consumedCalories"] = consumed;
      _dailyData["macronutrients"]["carbohydrates"]["consumed"] = carbs;
      _dailyData["macronutrients"]["proteins"]["consumed"] = protein;
      _dailyData["macronutrients"]["fats"]["consumed"] = fat;
      _dailyData["waterMl"] = water;
      _mealTotals = mealTotals;
    });

    _checkMealExceeds();
  }

  Future<void> _loadWeek() async {
    final now = _selectedDate;
    final int weekday = now.weekday;
    final DateTime monday =
        now.subtract(Duration(days: (weekday - 1)));
    final List<int> week = [];

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final entries =
          await NutritionStorage.getEntriesForDate(day);
      final kcal = entries.fold<int>(
        0,
        (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0),
      );
      week.add(kcal);
      final water = await NutritionStorage.getWaterMl(day);
      _weeklyWater[i] = water;
    }

    if (!mounted) return;
    setState(() {
      // Mantém apenas água semanal para possíveis usos futuros
      _weeklyWater = List<int>.from(_weeklyWater);
    });
  }

  Future<void> _loadExercise() async {
    final kcal =
        await NutritionStorage.getExerciseCalories(_selectedDate);
    // Meta e logs completos não são usados no layout atual.
    if (!mounted) return;
    setState(() {
      _dailyData["spentCalories"] = kcal;
    });
    await _updateHydrationAchievements();
    await _updateExerciseStreak();
  }

  Future<void> _loadGoals() async {
    final goals = await prefs.UserPreferences.getGoals();
    if (!mounted) return;
    setState(() {
      _dailyData["totalCalories"] = goals.totalCalories;
      _dailyData["macronutrients"]["carbohydrates"]["total"] =
          goals.carbs;
      _dailyData["macronutrients"]["proteins"]["total"] =
          goals.proteins;
      _dailyData["macronutrients"]["fats"]["total"] = goals.fats;
      _dailyData["waterGoalMl"] = goals.waterGoalMl;
    });
  }

  Future<void> _loadMealGoals() async {
    final goals = await prefs.UserPreferences.getMealGoals();
    if (!mounted) return;
    setState(() {
      _mealGoals = goals.map(
        (k, v) => MapEntry(
          k,
          MealGoals(
            kcal: v.kcal,
            carbs: v.carbs,
            proteins: v.proteins,
            fats: v.fats,
          ),
        ),
      );
    });
  }

  // --- Water actions -------------------------------------------------------

  void _addWater() {
    NutritionStorage.addWaterMl(_selectedDate, 250).then((ml) {
      if (!mounted) return;
      setState(() {
        _dailyData["waterMl"] = ml;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Água registrada: +250ml (total ${ml}ml)'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _updateHydrationAchievements();
    });
  }

  void _removeWater() {
    NutritionStorage.addWaterMl(_selectedDate, -250).then((ml) {
      if (!mounted) return;
      setState(() {
        _dailyData["waterMl"] = ml;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Água ajustada: -250ml (total ${ml}ml)'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      _updateHydrationAchievements();
    });
  }

  Widget _waterCupsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const int cupSize = 250;
    final int goal = _dailyData["waterGoalMl"] as int? ?? 2000;
    final int current = _dailyData["waterMl"] as int? ?? 0;
    final int totalCups = (goal / cupSize).clamp(4, 20).round();
    final int filled = (current / cupSize).floor().clamp(0, totalCups);

    final cups = <Widget>[];
    for (int i = 0; i < totalCups; i++) {
      final bool isFilled = i < filled;
      cups.add(
        GestureDetector(
          onTap: () async {
            final targetMl = (i + 1) * cupSize;
            final delta = targetMl - current;
            if (delta <= 0) return;
            final next =
                await NutritionStorage.addWaterMl(_selectedDate, delta);
            if (!mounted) return;
            setState(() {
              _dailyData["waterMl"] = next;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 0.8.w,
              vertical: 0.4.h,
            ),
            child: Icon(
              isFilled
                  ? Icons.water_drop
                  : Icons.water_drop_outlined,
              size: 18,
              color: isFilled
                  ? cs.primary.withValues(alpha: 0.92)
                  : cs.onSurfaceVariant.withValues(alpha: 0.65),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        OutlinedButton(
          onPressed: _removeWater,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(6),
            side: BorderSide(
              color: cs.primary.withValues(alpha: 0.5),
            ),
            foregroundColor: cs.primary,
          ),
          child: const Icon(Icons.remove, size: 16),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: cups),
          ),
        ),
        OutlinedButton(
          onPressed: _addWater,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(6),
            side: BorderSide(
              color: cs.primary.withValues(alpha: 0.5),
            ),
            foregroundColor: cs.primary,
          ),
          child: const Icon(Icons.add, size: 16),
        ),
      ],
    );
  }

    // --- Meal rows -----------------------------------------------------------
  
    /// Constrói os itens dos cards de refeições usando os estados atuais.
    /// Mantém a mesma lógica de dados, apenas organiza a apresentação visual.
    List<MealPlanItem> _buildMealPlanItems(BuildContext context) {
      MealPlanItem buildItem({
        required String title,
        required String mealKey,
      }) {
        final totals = _mealTotals[mealKey] ?? const {
          'kcal': 0,
          'carbs': 0,
          'proteins': 0,
          'fats': 0,
        };
        final int kcal = totals['kcal'] ?? 0;
        final MealGoals? goals = _mealGoals[mealKey];
        final int goalKcal = goals?.kcal ?? 0;
  
        // Último item registrado na refeição (mais recente)
        String? subtitle;
        final entries = _todayEntries
            .where((e) => (e['mealTime'] as String?) == mealKey)
            .toList()
          ..sort((a, b) => ((b['createdAt'] as String?) ?? '')
              .compareTo((a['createdAt'] as String?) ?? ''));
        if (entries.isNotEmpty) {
          final e = entries.first;
          final name = (e['name'] as String?)?.trim() ?? '';
          final ekcal = (e['calories'] as num?)?.toInt() ?? 0;
          if (name.isNotEmpty && ekcal > 0) {
            subtitle = '$name • ${ekcal} kcal';
          } else if (name.isNotEmpty) {
            subtitle = name;
          }
        }
  
        return MealPlanItem(
          title: title,
          consumedKcal: kcal,
          goalKcal: goalKcal,
          subtitle: subtitle,
          enabled: true,
          onAdd: () {
            Navigator.pushNamed(
              context,
              AppRoutes.addFoodEntry,
              arguments: {
                'mealKey': mealKey,
                'targetDate': _selectedDate.toIso8601String(),
              },
            ).then((_) async {
              if (!mounted) return;
              await _loadToday();
              await _loadWeek();
            });
          },
        );
      }
  
      return [
        buildItem(title: 'Café da manhã', mealKey: 'breakfast'),
        buildItem(title: 'Almoço', mealKey: 'lunch'),
        buildItem(title: 'Jantar', mealKey: 'dinner'),
        buildItem(title: 'Lanches', mealKey: 'snack'),
      ];
    }
  
    /// Seção visual consolidada de cards de refeições.
    /// Substitui os blocos manuais por MealPlanSectionWidget padronizado.
    Widget _buildPerMealProgressSection() {
      final items = _buildMealPlanItems(context);
      final cs = Theme.of(context).colorScheme;
  
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(
          horizontal: 3.2.w,
          vertical: 2.4.w,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: MealPlanSectionWidget(items: items),
      );
    }

  // --- Dia: ações extras (export resumo) -----------------------------------

  void _openDayActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Exportar resumo do dia'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareDaySummary();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareDaySummary() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
          'Resumo do dia ${_selectedDate.toIso8601String()}');
      buffer.writeln(
          'Calorias: ${_dailyData["consumedCalories"]}/${_dailyData["totalCalories"]}');
      buffer.writeln('Água: ${_dailyData["waterMl"]} ml');
      await Share.share(
        buffer.toString(),
        subject: 'Resumo diário Nutritracker',
      );
    } catch (e) {
      debugPrint('Erro ao compartilhar resumo do dia: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao compartilhar resumo do dia'),
        ),
      );
    }
  }

  // --- Refresh + build -----------------------------------------------------

  Future<void> _refreshData() async {
    await _loadToday();
    await _loadExercise();
  }


  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final navBg =
        theme.bottomNavigationBarTheme.backgroundColor ?? cs.surface;
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(
                context,
                AppRoutes.intermittentFastingTracker,
              );
              break;
            case 2:
              Navigator.pushNamed(
                context,
                AppRoutes.recipeBrowser,
              );
              break;
            case 3:
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
              break;
            case 4:
              Navigator.pushNamed(
                context,
                AppRoutes.aiCoachChat,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: CustomIconWidget(iconName: 'today', size: 24),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(iconName: 'schedule', size: 24),
            label: 'Jejum',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'restaurant_menu',
              size: 24,
            ),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined, size: 24),
            label: 'Coach',
          ),
        ],
      ),
    );
  }
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


