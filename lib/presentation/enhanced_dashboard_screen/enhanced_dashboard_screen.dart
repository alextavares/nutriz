import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'package:nutritracker/theme/design_tokens.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import './widgets/nutrition_summary_card.dart';
import './widgets/quick_actions_grid.dart';
import './widgets/todays_meals_list.dart';
import './widgets/water_intake_tracker.dart';
import '../daily_tracking_dashboard/widgets/achievement_badges_widget.dart';
import '../../services/achievement_service.dart';
import '../../services/streak_service.dart';
import '../../services/weekly_goal_service.dart';
import '../../services/daily_goal_service.dart';
import '../../services/user_preferences.dart';
import '../common/celebration_overlay.dart';
import '../../services/nutrition_storage.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  int _waterStreak = 0;
  int _fastingStreak = 0;
  int _caloriesStreak = 0;
  int _proteinStreak = 0;
  List<Map<String, dynamic>> _achievements = const [];
  bool _showNextMilestoneCaptions = true;

  // Live data computed from storage + goals
  int _consumedCalories = 0;
  int _totalCaloriesGoal = 2000;
  Map<String, int> _carbs = {"consumed": 0, "total": 250};
  Map<String, int> _proteins = {"consumed": 0, "total": 120};
  Map<String, int> _fats = {"consumed": 0, "total": 80};
  int _waterConsumed = 0;
  int _waterGoal = 2000;

  List<Map<String, dynamic>> _mealsForUi = const [];

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return AppLocalizations.of(context)?.appbarToday ?? 'Today';
    } else {
      return '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    }
  }

  void _navigateToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadDay();
  }

  void _navigateToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadDay();
  }

  // Refresh streak/achievements when returning to screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshGamification();
  }

  void _onStorageChanged() {
    _loadDay();
  }

  void _onPrefsChanged() {
    _loadGoalsAndDay();
  }

  Future<void> _loadGoalsAndDay() async {
    final goals = await UserPreferences.getGoals();
    if (!mounted) return;
    setState(() {
      _totalCaloriesGoal = goals.totalCalories;
      _carbs["total"] = goals.carbs;
      _proteins["total"] = goals.proteins;
      _fats["total"] = goals.fats;
      _waterGoal = goals.waterGoalMl;
    });
    await _loadDay();
  }

  Future<void> _loadDay() async {
    final d =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final entries = await NutritionStorage.getEntriesForDate(d);
    final water = await NutritionStorage.getWaterMl(d);
    int kcal = 0;
    int carbs = 0;
    int prot = 0;
    int fat = 0;
    for (final e in entries) {
      kcal += (e['calories'] as num?)?.toInt() ?? 0;
      carbs += (e['carbs'] as num?)?.toInt() ?? 0;
      prot += (e['protein'] as num?)?.toInt() ?? 0;
      fat += (e['fat'] as num?)?.toInt() ?? 0;
    }
    // Map entries to UI meals format expected by TodaysMealsList
    final mappedMeals = entries.map<Map<String, dynamic>>((e) {
      final name = (e['name'] ?? '').toString();
      final mt = (e['mealTime'] as String?) ?? 'snack';
      final timeIso = (e['createdAt'] as String?) ?? '';
      String hhmm = '';
      try {
        if (timeIso.isNotEmpty) {
          final dt = DateTime.tryParse(timeIso);
          if (dt != null) {
            hhmm =
                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          }
        }
      } catch (_) {}
      return {
        'id': e['id'],
        'type': mt,
        'title': name.isEmpty ? 'Refeição' : name,
        'calories': (e['calories'] as num?)?.toInt() ?? 0,
        'time': hhmm.isEmpty ? '-' : hhmm,
        'completed': true,
        'raw': e,
      };
    }).toList();
    if (!mounted) return;
    setState(() {
      _consumedCalories = kcal;
      _carbs["consumed"] = carbs;
      _proteins["consumed"] = prot;
      _fats["consumed"] = fat;
      _waterConsumed = water;
      _mealsForUi = mappedMeals;
    });
  }

  void _openMealDetail(Map<String, dynamic> meal) {
    final raw = (meal['raw'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final title = (raw['name'] ?? meal['title'] ?? 'Refeição').toString();
    final kcal =
        (raw['calories'] as num?)?.toInt() ?? (meal['calories'] as int? ?? 0);
    final carbs = (raw['carbs'] as num?)?.toInt() ?? 0;
    final protein = (raw['protein'] as num?)?.toInt() ?? 0;
    final fat = (raw['fat'] as num?)?.toInt() ?? 0;
    final serving = (raw['serving'] as String?) ?? '1 porção';
    final mealKey =
        (raw['mealTime'] as String?) ?? (meal['type'] as String?) ?? 'snack';
    final time = (meal['time'] as String?) ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      mealKey,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                    )
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: context.colors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text(time,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.colors.onSurfaceVariant)),
                    const Spacer(),
                    Text('$kcal kcal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.semanticColors.warning,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 1.2.h),
                Divider(color: context.colors.outline.withValues(alpha: 0.3)),
                SizedBox(height: 1.2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _macroPill(
                        'Carbo', '$carbs g', context.semanticColors.warning),
                    _macroPill(
                        'Prot', '$protein g', context.semanticColors.success),
                    _macroPill('Gord', '$fat g', context.colors.primary),
                  ],
                ),
                SizedBox(height: 1.2.h),
                Text('Porção: $serving',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.colors.onSurfaceVariant)),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final args = {
                            'prefillFood': {
                              'name': title,
                              'brand': raw['brand'] ?? 'Genérico',
                              'calories': kcal,
                              'carbs': carbs,
                              'protein': protein,
                              'fat': fat,
                              'serving': serving,
                              'imageUrl': raw['imageUrl'],
                              'createdAt': raw['createdAt'],
                            },
                            'reviewOnly': true,
                            'mealKey': mealKey,
                            'date': raw['createdAt'] ??
                                DateTime.now().toIso8601String(),
                            'editId': raw['id'],
                          };
                          // Edit existing entry
                          await Navigator.pushNamed(
                              context, AppRoutes.addFoodEntry,
                              arguments: args);
                          if (mounted) await _loadDay();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final id = raw['id'] ?? meal['id'];
                          if (id != null) {
                            await NutritionStorage.removeEntryById(
                              DateTime(_selectedDate.year, _selectedDate.month,
                                  _selectedDate.day),
                              id,
                            );
                            if (mounted) {
                              await _loadDay();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Refeição excluída')));
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.redAccent.withValues(alpha: 0.2),
                            foregroundColor: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.colors.onSurface)),
          SizedBox(width: 6),
          Text(value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: context.colors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getWeekdayName(DateTime date) {
    final t = AppLocalizations.of(context);
    switch (date.weekday) {
      case DateTime.monday:
        return t?.dowMon ?? 'Monday';
      case DateTime.tuesday:
        return t?.dowTue ?? 'Tuesday';
      case DateTime.wednesday:
        return t?.dowWed ?? 'Wednesday';
      case DateTime.thursday:
        return t?.dowThu ?? 'Thursday';
      case DateTime.friday:
        return t?.dowFri ?? 'Friday';
      case DateTime.saturday:
        return t?.dowSat ?? 'Saturday';
      default:
        return t?.dowSun ?? 'Sunday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.dashboardTitle ?? 'Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: Icon(
              Icons.person_outline,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)?.achievementsTitle ??
                'Achievements',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.achievements),
            icon: Icon(
              Icons.emoji_events_outlined,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Navigation Header
                _buildDateNavigation(),

                SizedBox(height: 3.h),

                // Nutrition Summary Card
                NutritionSummaryCard(
                  consumedCalories: _consumedCalories,
                  totalCalories: _totalCaloriesGoal,
                  carbs: _carbs,
                  proteins: _proteins,
                  fats: _fats,
                ),

                SizedBox(height: 3.h),

                // Water Intake Tracker
                WaterIntakeTracker(
                  consumed: _waterConsumed,
                  total: _waterGoal,
                ),

                SizedBox(height: 1.5.h),
                // Streak chip + recent achievements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStreakChip(),
                    SizedBox(width: 1.2.w),
                    _buildFastingStreakChip(),
                    SizedBox(width: 1.2.w),
                    _buildCaloriesStreakChip(),
                    SizedBox(width: 1.2.w),
                    _buildProteinStreakChip(),
                    SizedBox(width: 1.2.w),
                    Expanded(
                      child: AchievementBadgesWidget(
                        achievements: _achievements,
                        onBadgeTap: (a) {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor:
                                context.colors.surfaceContainerHigh,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (_) => _buildBadgeDetails(a),
                          );
                        },
                      ),
                    )
                  ],
                ),

                SizedBox(height: 3.h),

                // Quick Actions
                Text(
                  AppLocalizations.of(context)?.dashboardQuickActions ??
                      'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 2.h),

                QuickActionsGrid(),

                SizedBox(height: 3.h),

                // Today's Meals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.dashboardTodaysMeals ??
                          "Today's Meals",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.addFoodEntry);
                      },
                      child: Text(
                        AppLocalizations.of(context)?.dashboardViewAll ??
                            'View All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                TodaysMealsList(
                  meals: _mealsForUi,
                  onDelete: (meal) async {
                    final id = meal['id'];
                    if (id != null) {
                      await NutritionStorage.removeEntryById(
                        DateTime(_selectedDate.year, _selectedDate.month,
                            _selectedDate.day),
                        id,
                      );
                      await _loadDay();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refeição excluída')));
                      }
                    }
                  },
                  onTap: (meal) => _openMealDetail(meal),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addFoodEntry);
        },
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onSurface,
        icon: const Icon(Icons.add),
        label:
            Text(AppLocalizations.of(context)?.dashboardAddMeal ?? 'Add Meal'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUiPrefs();
    _refreshGamification();
    _loadGoalsAndDay();
    NutritionStorage.changes.addListener(_onStorageChanged);
    UserPreferences.changes.addListener(_onPrefsChanged);
    // Evaluate weekly calories milestone lazily
    WeeklyGoalService.evaluatePerfectCaloriesWeek().then((created) {
      if (created && mounted) _refreshGamification();
    });
    // Evaluate protein goal day
    DailyGoalService.evaluateProteinOkToday()
        .then((_) => _refreshGamification());
    // Evaluate calories-ok streak day
    DailyGoalService.evaluateCaloriesOkToday()
        .then((_) => _refreshGamification());
    // Listen to UI pref changes for live updates
    UserPreferences.changes.addListener(_onUiPrefsChanged);
  }

  Future<void> _loadUiPrefs() async {
    final show = await UserPreferences.getShowNextMilestoneCaptions();
    if (!mounted) return;
    setState(() => _showNextMilestoneCaptions = show);
  }

  void _onUiPrefsChanged() {
    _loadUiPrefs();
  }

  Future<void> _refreshGamification() async {
    final streak = await StreakService.currentStreak('water');
    final fastStreak = await StreakService.currentStreak('fasting');
    final calStreak = await StreakService.currentStreak('calories_ok_day');
    final protStreak = await StreakService.currentStreak('protein');
    final ach = await AchievementService.listAll();
    if (!mounted) return;
    setState(() {
      _waterStreak = streak;
      _fastingStreak = fastStreak;
      _caloriesStreak = calStreak;
      _proteinStreak = protStreak;
      // Keep the most recent 6 achievements only for horizontal list
      ach.sort((a, b) =>
          (b['dateIso'] as String?)?.compareTo(a['dateIso'] as String? ?? '') ??
          0);
      _achievements = ach.take(6).toList();
    });

    // Celebrate newly added achievements (optional)
    final lastAdded = await AchievementService.getLastAddedTs();
    final lastSeen = await AchievementService.getLastSeenTs();
    if (lastAdded > 0 && lastAdded > lastSeen) {
      await CelebrationOverlay.maybeShow(context,
          variant: CelebrationVariant.achievement);
      await AchievementService.setLastSeenTs(lastAdded);
    }
  }

  int? _nextMilestoneFor(int current, List<int> thresholds) {
    for (final t in thresholds) {
      if (current < t) return t;
    }
    return null;
  }

  Widget _buildStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_waterStreak);
    final next = _nextMilestoneFor(_waterStreak, milestones);
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: semantics.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantics.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: semantics.warning, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _waterStreak > 0
                ? '${_waterStreak}d water'
                : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: textStyles.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.amber, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(
              AppLocalizations.of(context)?.streakNext(next) ??
                  '• next: ${next}d',
              style: textStyles.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFastingStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_fastingStreak);
    final next = _nextMilestoneFor(_fastingStreak, milestones);
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: semantics.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantics.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: semantics.warning, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _fastingStreak > 0
                ? '${_fastingStreak}d fasting'
                : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: textStyles.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.amber, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(
              AppLocalizations.of(context)?.streakNext(next) ??
                  '• next: ${next}d',
              style: textStyles.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_caloriesStreak);
    final next = _nextMilestoneFor(_caloriesStreak, milestones);
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: semantics.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantics.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: semantics.success, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _caloriesStreak > 0
                ? '${_caloriesStreak}d calories ok'
                : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: textStyles.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.lightGreen, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(
              AppLocalizations.of(context)?.streakNext(next) ??
                  '• next: ${next}d',
              style: textStyles.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProteinStreakChip() {
    final milestones = const [5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_proteinStreak);
    final next = _nextMilestoneFor(_proteinStreak, milestones);
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.set_meal, color: colors.primary, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _proteinStreak > 0
                ? '${_proteinStreak}d protein ok'
                : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: textStyles.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.lightBlue, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(
              AppLocalizations.of(context)?.streakNext(next) ??
                  '• next: ${next}d',
              style: textStyles.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeDetails(Map<String, dynamic> a) {
    final when = (a['dateIso'] as String?) ?? '';
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CustomIconWidget(
                iconName: 'emoji_events',
                color: context.semanticColors.premium,
                size: 22),
            SizedBox(width: 2.w),
            Text(
                AppLocalizations.of(context)?.achievementsDefaultTitle ??
                    'Achievement',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: context.colors.onSurface)),
          ]),
          SizedBox(height: 1.h),
          Text(
              a['title'] as String? ??
                  (AppLocalizations.of(context)?.achievementsDefaultTitle ??
                      'Achievement'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 0.5.h),
          Text(
              (AppLocalizations.of(context)?.badgeEarnedOn(when) ??
                  'Earned on: $when'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant)),
          SizedBox(height: 2.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.semanticColors.success,
                  foregroundColor: context.colors.onSurface),
              child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _navigateToPreviousDay,
            icon: Icon(
              Icons.chevron_left,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Column(
              children: [
                Text(
                  _formattedDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getWeekdayName(_selectedDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _navigateToNextDay,
            icon: Icon(
              Icons.chevron_right,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      UserPreferences.changes.removeListener(_onUiPrefsChanged);
    } catch (_) {}
    try {
      UserPreferences.changes.removeListener(_onPrefsChanged);
    } catch (_) {}
    try {
      NutritionStorage.changes.removeListener(_onStorageChanged);
    } catch (_) {}
    super.dispose();
  }
}
