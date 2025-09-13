import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  int _waterStreak = 0;
  int _fastingStreak = 0;
  int _caloriesStreak = 0;
  int _proteinStreak = 0;
  List<Map<String, dynamic>> _achievements = const [];
  bool _showNextMilestoneCaptions = true;

  // Mock data - similar to existing dashboard
  final Map<String, dynamic> _nutritionData = {
    "consumedCalories": 1450,
    "totalCalories": 2000,
    "carbs": {"consumed": 180, "total": 250},
    "proteins": {"consumed": 95, "total": 120},
    "fats": {"consumed": 65, "total": 80},
    "water": {"consumed": 1200, "total": 2000},
  };

  final List<Map<String, dynamic>> _todaysMeals = [
    {
      "id": 1,
      "type": "breakfast",
      "title": "Aveia com frutas",
      "calories": 320,
      "time": "07:30",
      "completed": true,
    },
    {
      "id": 2,
      "type": "lunch",
      "title": "Salada de frango",
      "calories": 450,
      "time": "12:15",
      "completed": true,
    },
    {
      "id": 3,
      "type": "snack",
      "title": "Iogurte grego",
      "calories": 180,
      "time": "15:00",
      "completed": false,
    },
    {
      "id": 4,
      "type": "dinner",
      "title": "Peixe grelhado",
      "calories": 500,
      "time": "19:30",
      "completed": false,
    },
  ];

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

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
  }

  void _navigateToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  // Refresh streak/achievements when returning to screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshGamification();
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
              primary: AppTheme.activeBlue,
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
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundDark,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.dashboardTitle ?? 'Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
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
              color: AppTheme.textSecondary,
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)?.achievementsTitle ?? 'Achievements',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.achievements),
            icon: Icon(
              Icons.emoji_events_outlined,
              color: AppTheme.textSecondary,
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
                  consumedCalories: _nutritionData["consumedCalories"],
                  totalCalories: _nutritionData["totalCalories"],
                  carbs: _nutritionData["carbs"],
                  proteins: _nutritionData["proteins"],
                  fats: _nutritionData["fats"],
                ),

                SizedBox(height: 3.h),

                // Water Intake Tracker
                WaterIntakeTracker(
                  consumed: _nutritionData["water"]["consumed"],
                  total: _nutritionData["water"]["total"],
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
                            backgroundColor: AppTheme.secondaryBackgroundDark,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  AppLocalizations.of(context)?.dashboardQuickActions ?? 'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
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
                      AppLocalizations.of(context)?.dashboardTodaysMeals ?? "Today's Meals",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.addFoodEntry);
                      },
                      child: Text(
                        AppLocalizations.of(context)?.dashboardViewAll ?? 'View All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.activeBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                TodaysMealsList(meals: _todaysMeals),

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
        backgroundColor: AppTheme.activeBlue,
        foregroundColor: AppTheme.textPrimary,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)?.dashboardAddMeal ?? 'Add Meal'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUiPrefs();
    _refreshGamification();
    // Evaluate weekly calories milestone lazily
    WeeklyGoalService.evaluatePerfectCaloriesWeek().then((created) {
      if (created && mounted) _refreshGamification();
    });
    // Evaluate protein goal day
    DailyGoalService.evaluateProteinOkToday().then((_) => _refreshGamification());
    // Evaluate calories-ok streak day
    DailyGoalService.evaluateCaloriesOkToday().then((_) => _refreshGamification());
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
      ach.sort((a, b) => (b['dateIso'] as String?)?.compareTo(a['dateIso'] as String? ?? '') ?? 0);
      _achievements = ach.take(6).toList();
    });

    // Celebrate newly added achievements (optional)
    final lastAdded = await AchievementService.getLastAddedTs();
    final lastSeen = await AchievementService.getLastSeenTs();
    if (lastAdded > 0 && lastAdded > lastSeen) {
      await CelebrationOverlay.maybeShow(context, variant: CelebrationVariant.achievement);
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: AppTheme.warningAmber, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _waterStreak > 0 ? '${_waterStreak}d water' : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.amber, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(AppLocalizations.of(context)?.streakNext(next ?? 0) ?? '• next: ${next}d',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildFastingStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_fastingStreak);
    final next = _nextMilestoneFor(_fastingStreak, milestones);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: AppTheme.warningAmber, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _fastingStreak > 0 ? '${_fastingStreak}d fasting' : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.amber, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(AppLocalizations.of(context)?.streakNext(next ?? 0) ?? '• next: ${next}d',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_caloriesStreak);
    final next = _nextMilestoneFor(_caloriesStreak, milestones);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _caloriesStreak > 0 ? '${_caloriesStreak}d calories ok' : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.lightGreen, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(AppLocalizations.of(context)?.streakNext(next ?? 0) ?? '• next: ${next}d',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildProteinStreakChip() {
    final milestones = const [5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_proteinStreak);
    final next = _nextMilestoneFor(_proteinStreak, milestones);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.activeBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.activeBlue.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.set_meal, color: AppTheme.activeBlue, size: 16),
          SizedBox(width: 1.2.w),
          Text(
            _proteinStreak > 0 ? '${_proteinStreak}d protein ok' : (AppLocalizations.of(context)?.streakNoStreak ?? 'No streak'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (isMilestone) ...[
            SizedBox(width: 1.w),
            const Icon(Icons.star, color: Colors.lightBlue, size: 14),
          ],
          if (_showNextMilestoneCaptions && next != null) ...[
            SizedBox(width: 1.w),
            Text(AppLocalizations.of(context)?.streakNext(next ?? 0) ?? '• next: ${next}d',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
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
            CustomIconWidget(iconName: 'emoji_events', color: AppTheme.premiumGold, size: 22),
            SizedBox(width: 2.w),
            Text(AppLocalizations.of(context)?.achievementsDefaultTitle ?? 'Achievement', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary)),
          ]),
          SizedBox(height: 1.h),
          Text(a['title'] as String? ?? (AppLocalizations.of(context)?.achievementsDefaultTitle ?? 'Achievement'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: 0.5.h),
          Text((AppLocalizations.of(context)?.badgeEarnedOn(when) ?? 'Earned on: $when'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          SizedBox(height: 2.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: AppTheme.textPrimary),
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
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _navigateToPreviousDay,
            icon: Icon(
              Icons.chevron_left,
              color: AppTheme.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Column(
              children: [
                Text(
                  _formattedDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getWeekdayName(_selectedDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _navigateToNextDay,
            icon: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
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
    super.dispose();
  }
}
