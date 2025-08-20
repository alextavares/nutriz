import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../core/app_export.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/action_button_widget.dart';
import './widgets/circular_progress_chart_widget.dart';
import './widgets/macronutrient_progress_widget.dart';
import './widgets/weekly_progress_widget.dart';
import '../../services/nutrition_storage.dart';
import './widgets/logged_meals_list_widget.dart';
import '../../services/user_preferences.dart';
import '../../services/notifications_service.dart';
import 'package:nutritracker/util/download_stub.dart'
    if (dart.library.html) 'package:nutritracker/util/download_web.dart';
import 'package:nutritracker/util/upload_stub.dart'
    if (dart.library.html) 'package:nutritracker/util/upload_web.dart';
import 'package:share_plus/share_plus.dart';

class DailyTrackingDashboard extends StatefulWidget {
  const DailyTrackingDashboard({super.key});

  @override
  State<DailyTrackingDashboard> createState() => _DailyTrackingDashboardState();
}

class _DailyTrackingDashboardState extends State<DailyTrackingDashboard> {
  DateTime _selectedDate = DateTime.now();
  int _currentWeek = 32;
  bool _isDayView = true; // Hoje vs Semana toggle (UI)
  List<Map<String, dynamic>> _todayEntries = [];
  List<int> _weeklyCalories = List.filled(7, 0);
  List<int> _weeklyWater = List.filled(7, 0);
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
  // removed unused: _exceededMacroKeys

  // Mock data for daily tracking
  final Map<String, dynamic> _dailyData = {
    "consumedCalories": 1450,
    "totalCalories": 2000,
    "spentCalories": 0,
    "waterMl": 0,
    "waterGoalMl": 2000,
    "macronutrients": {
      "carbohydrates": {"consumed": 180, "total": 250},
      "proteins": {"consumed": 95, "total": 120},
      "fats": {"consumed": 65, "total": 80},
    },
  };

  List<Map<String, dynamic>> _achievements = [
    {
      "id": 1,
      "type": "flame",
      "title": "Sequência de 7 dias",
      "description": "Você manteve sua meta por 7 dias consecutivos!",
      "earnedDate": "2025-08-10",
    },
    {
      "id": 2,
      "type": "diamond",
      "title": "Meta Proteína",
      "description": "Atingiu sua meta de proteína por 5 dias seguidos.",
      "earnedDate": "2025-08-09",
    },
    {
      "id": 3,
      "type": "success",
      "title": "Hidratação",
      "description": "Bebeu 2L de água por 3 dias consecutivos.",
      "earnedDate": "2025-08-08",
    },
  ];

  Widget _calorieBudgetCard({
    required int goal,
    required int food,
    required int exercise,
    required int remaining,
  }) {
    final TextStyle label = AppTheme.darkTheme.textTheme.bodySmall!
        .copyWith(color: AppTheme.textSecondary);
    final TextStyle numStyle =
        AppTheme.darkTheme.textTheme.titleLarge!.copyWith(
      color: AppTheme.activeBlue,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final base = AppTheme.darkTheme.textTheme.bodyMedium!;
    final double eqSize = base.fontSize ?? 14;
    final TextStyle eqStyle = base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final TextStyle opStyle = eqStyle.copyWith(
      fontSize: eqSize - 2,
      color: AppTheme.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Remaining big
          Text('$remaining kcal', style: numStyle),
          const SizedBox(height: 4),
          Text('Restante', style: label),
          const SizedBox(height: 8),
          // Equation row
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: eqStyle.copyWith(color: AppTheme.textSecondary),
              children: [
                const TextSpan(text: 'Objetivo '),
                TextSpan(
                    text: '$goal',
                    style: eqStyle.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                TextSpan(text: ' − ', style: opStyle),
                const TextSpan(text: 'Alimentação '),
                TextSpan(
                    text: '$food',
                    style: eqStyle.copyWith(
                        color: AppTheme.warningAmber,
                        fontWeight: FontWeight.w700)),
                TextSpan(text: ' + ', style: opStyle),
                const TextSpan(text: 'Exercício '),
                TextSpan(
                    text: '$exercise',
                    style: eqStyle.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickMealActionsRow() {
    ButtonStyle style(Color color) => OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          foregroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );

    void goToLogging(String meal) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicionar em: $meal')),
      );
      Navigator.pushNamed(context, AppRoutes.foodLogging);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => goToLogging('Café da manhã'),
          style: style(AppTheme.warningAmber),
          child: const Text('+ Café'),
        ),
        OutlinedButton(
          onPressed: () => goToLogging('Almoço'),
          style: style(AppTheme.successGreen),
          child: const Text('+ Almoço'),
        ),
        OutlinedButton(
          onPressed: () => goToLogging('Jantar'),
          style: style(AppTheme.activeBlue),
          child: const Text('+ Jantar'),
        ),
        OutlinedButton(
          onPressed: () {
            final current = (_dailyData['waterMl'] as int?) ?? 0;
            setState(() => _dailyData['waterMl'] = current + 250);
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('+250 ml de água')),
            );
          },
          style: style(AppTheme.activeBlue),
          child: const Text('+ Água'),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
    _loadToday();
    _loadGoals();
    _loadExercise();
    _loadMealGoals();
    _updateHydrationAchievements();
    _startHydrationReminderLoop();
  }

  Future<void> _clearNewHighlightsForSelectedDay() async {
    // Regrava createdAt das entradas de hoje para um timestamp antigo, removendo destaque "novo"
    final entries = await NutritionStorage.getEntriesForDate(_selectedDate);
    if (entries.isEmpty) return;
    final ancient =
        DateTime.now().subtract(const Duration(days: 365)).toIso8601String();
    for (final e in entries) {
      final updated = Map<String, dynamic>.from(e);
      updated['createdAt'] = ancient;
      await NutritionStorage.updateEntryById(_selectedDate, e['id'], updated);
    }
    if (!mounted) return;
    await _loadToday();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Destaques limpos para o dia selecionado'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  IconData _macroIconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('carb') || l.contains('carbo')) return Icons.bakery_dining;
    if (l.contains('prot')) return Icons.set_meal;
    if (l.contains('gord') || l.contains('fat')) return Icons.local_pizza;
    return Icons.circle;
  }

  Color _macroColorFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('carb') || l.contains('carbo')) return AppTheme.warningAmber;
    if (l.contains('prot')) return AppTheme.successGreen;
    if (l.contains('gord') || l.contains('fat')) return AppTheme.activeBlue;
    return AppTheme.textSecondary;
  }

  Widget _macroSummary(String label, int consumed, int goal) {
    final color = _macroColorFor(label);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_macroIconFor(label), color: color, size: 16),
            SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.3.h),
        Text(
          "$consumed / $goal g",
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPerMealProgressSection() {
    Color barColorFor(String meal) {
      switch (meal) {
        case 'breakfast':
          return AppTheme.warningAmber;
        case 'lunch':
          return AppTheme.successGreen;
        case 'dinner':
          return AppTheme.activeBlue;
        default:
          return AppTheme.premiumGold;
      }
    }

    Widget row(String title, String mealKey) {
      final totals = _mealTotals[mealKey]!;
      final goal = _mealGoals[mealKey]?.kcal ?? 0;
      // Top bar similar ao app de referência

      final value = totals['kcal'] ?? 0;
      final ratio = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
      final color = barColorFor(mealKey);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                goal > 0 ? '$value/$goal kcal' : '$value kcal',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppTheme.dividerGray,
              color: color,
            ),
          ),
          SizedBox(height: 0.6.h),
          // Macros bars per meal
          _macroRow('Carb', totals['carbs'] ?? 0,
              _mealGoals[mealKey]?.carbs ?? 0, AppTheme.warningAmber),
          SizedBox(height: 0.4.h),
          _macroRow('Prot', totals['proteins'] ?? 0,
              _mealGoals[mealKey]?.proteins ?? 0, AppTheme.successGreen),
          SizedBox(height: 0.4.h),
          _macroRow('Gord', totals['fats'] ?? 0, _mealGoals[mealKey]?.fats ?? 0,
              AppTheme.activeBlue),
          SizedBox(height: 0.8.h),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu,
                  color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Metas por refeição',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _openEditMealGoalsDialog,
              child: const Text('Editar metas'),
            ),
          ),
          SizedBox(height: 1.h),
          row('Café da manhã', 'breakfast'),
          row('Almoço', 'lunch'),
          row('Jantar', 'dinner'),
          row('Lanches', 'snack'),
        ],
      ),
    );
  }

  Widget _macroRow(String label, int value, int goal, Color baseColor) {
    final ratio = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    final bool over = goal > 0 && value > goal;
    final Color color = over ? AppTheme.errorRed : baseColor;
    return Row(
      children: [
        SizedBox(
          width: 16.w,
          child: Text(
            goal > 0 ? '$label $value/$goal g' : '$label $value g',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppTheme.dividerGray.withValues(alpha: 0.6),
              color: color,
            ),
          ),
        ),
        if (over) ...[
          SizedBox(width: 2.w),
          Chip(
            label: const Text('Excedeu'),
            visualDensity: VisualDensity.compact,
            backgroundColor: AppTheme.secondaryBackgroundDark,
            shape: StadiumBorder(
              side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.6)),
            ),
            labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.errorRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]
      ],
    );
  }

  // _editEntry: ver implementação abaixo (com duplicar e seleção de período)

  // Hydration reminder loop (in-app SnackBar)
  Future<void> _startHydrationReminderLoop() async {
    final hyd = await UserPreferences.getHydrationReminder();
    if (!hyd.enabled) return;
    if (!mounted) return;
    await NotificationsService.initialize();
    await NotificationsService.requestPermissionsIfNeeded();
    Future.doWhile(() async {
      if (!mounted) return false;
      final prefs = await UserPreferences.getHydrationReminder();
      if (!prefs.enabled) return false;
      await Future.delayed(Duration(minutes: prefs.intervalMinutes));
      if (!mounted) return false;
      // Notificação local
      await NotificationsService.showHydrationReminder(
        body: 'Registre +250 ml ou um copo de água agora',
      );
      return true;
    });
  }

  Future<void> _ensureAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    // Atalho para desenvolvimento: autenticar automaticamente quando rodando localmente
    assert(() {
      isAuthenticated = true;
      prefs.setBool('is_authenticated', true);
      prefs.setString('user_email', 'dev@local');
      prefs.setBool('premium_status', false);
      debugPrint("Modo desenvolvedor: login automático ativado");
      return true;
    }());

    if (!isAuthenticated && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = (_dailyData["totalCalories"] as int? ?? 0) -
        (_dailyData["consumedCalories"] as int? ?? 0);

    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.activeBlue,
          backgroundColor: AppTheme.secondaryBackgroundDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top dashboard header estilo imagem de referência
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowDark,
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Toggle chips Hoje/Semana
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Hoje'),
                            selected: _isDayView,
                            onSelected: (v) =>
                                setState(() => _isDayView = true),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _isDayView
                                  ? AppTheme.activeBlue
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            backgroundColor: AppTheme.secondaryBackgroundDark,
                            selectedColor:
                                AppTheme.activeBlue.withValues(alpha: 0.12),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: (_isDayView
                                        ? AppTheme.activeBlue
                                        : AppTheme.dividerGray)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('Semana'),
                            selected: !_isDayView,
                            onSelected: (v) =>
                                setState(() => _isDayView = false),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: !_isDayView
                                  ? AppTheme.activeBlue
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            backgroundColor: AppTheme.secondaryBackgroundDark,
                            selectedColor:
                                AppTheme.activeBlue.withValues(alpha: 0.12),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: (!_isDayView
                                        ? AppTheme.activeBlue
                                        : AppTheme.dividerGray)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.0.h),
                      CircularProgressChartWidget(
                        consumedCalories: _dailyData["consumedCalories"],
                        remainingCalories: remainingCalories,
                        spentCalories: _dailyData["spentCalories"],
                        totalCalories: _dailyData["totalCalories"],
                        onTap: _showCalorieBreakdown,
                        waterMl: _dailyData["waterMl"] as int,
                      ),
                      SizedBox(height: 0.8.h),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Builder(builder: (context) {
                            final exceeded = remainingCalories <= 0;
                            final color = exceeded
                                ? AppTheme.errorRed
                                : AppTheme.activeBlue;
                            final text = exceeded
                                ? '${remainingCalories.abs()} kcal excedeu'
                                : '${remainingCalories} kcal restantes';
                            return Chip(
                              label: Text(text),
                              backgroundColor: AppTheme.secondaryBackgroundDark,
                              shape: StadiumBorder(
                                side: BorderSide(
                                    color: color.withValues(alpha: 0.6)),
                              ),
                              labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }),
                          Chip(
                            label: Text(
                                'Água: ${(_dailyData['waterMl'] as int?) ?? 0} ml'),
                            backgroundColor: AppTheme.secondaryBackgroundDark,
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.dividerGray
                                      .withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _macroSummary(
                              "Carb",
                              (_dailyData["macronutrients"]["carbohydrates"]
                                      ["consumed"] as int? ??
                                  0),
                              (_dailyData["macronutrients"]["carbohydrates"]
                                      ["total"] as int? ??
                                  0)),
                          _macroSummary(
                              "Prot",
                              (_dailyData["macronutrients"]["proteins"]
                                      ["consumed"] as int? ??
                                  0),
                              (_dailyData["macronutrients"]["proteins"]["total"]
                                      as int? ??
                                  0)),
                          _macroSummary(
                              "Gord",
                              (_dailyData["macronutrients"]["fats"]["consumed"]
                                      as int? ??
                                  0),
                              (_dailyData["macronutrients"]["fats"]["total"]
                                      as int? ??
                                  0)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openDayActionsMenu,
                      child: const Text('Ações do dia'),
                    ),
                  ),
                ),

                // Calorie budget card (Objetivo − Alimentação + Exercício = Restante)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _calorieBudgetCard(
                    goal: _dailyData["totalCalories"] as int? ?? 0,
                    food: _dailyData["consumedCalories"] as int? ?? 0,
                    exercise: _dailyData["spentCalories"] as int? ?? 0,
                    remaining: remainingCalories +
                        (_dailyData["spentCalories"] as int? ?? 0),
                  ),
                ),

                // Quick actions per meal
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: _quickMealActionsRow(),
                ),

                // Circular chart moved to header
                const SizedBox.shrink(),

                // Per-meal progress (kcal and macros) — aligns with YAZIO cards
                SizedBox(height: 1.6.h),
                _buildPerMealProgressSection(),

                SizedBox(height: 3.h),

                // Water progress
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowDark,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop_outlined,
                                  color: AppTheme.activeBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Água',
                                style: AppTheme.darkTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${_dailyData["waterMl"]}/${_dailyData["waterGoalMl"]} ml',
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.activeBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              TextButton(
                                onPressed: _openEditWaterGoalDialog,
                                child: const Text('Meta'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (() {
                            final int current = (_dailyData["waterMl"] as int);
                            final int goal = (_dailyData["waterGoalMl"] as int);
                            if (goal <= 0) return 0.0;
                            final v = current / goal;
                            return v.clamp(0.0, 1.0);
                          }()),
                          minHeight: 8,
                          backgroundColor: AppTheme.dividerGray,
                          color: AppTheme.activeBlue,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _removeWater,
                            child: const Text('-250 ml'),
                          ),
                          SizedBox(width: 2.w),
                          ElevatedButton(
                            onPressed: _addWater,
                            child: const Text('+250 ml'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Macronutrient progress bars
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macronutrientes',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openEditMacroGoalsDialog,
                          child: const Text('Meta Macros'),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      MacronutrientProgressWidget(
                        name: 'Carboidratos',
                        consumed: (_dailyData["macronutrients"]["carbohydrates"]
                            ["consumed"] as int),
                        total: (_dailyData["macronutrients"]["carbohydrates"]
                            ["total"] as int),
                        color: AppTheme.warningAmber,
                        onLongPress: () =>
                            _showMacronutrientDetails('carbohydrates'),
                      ),
                      MacronutrientProgressWidget(
                        name: 'Proteínas',
                        consumed: (_dailyData["macronutrients"]["proteins"]
                            ["consumed"] as int),
                        total: (_dailyData["macronutrients"]["proteins"]
                            ["total"] as int),
                        color: AppTheme.successGreen,
                        onLongPress: () =>
                            _showMacronutrientDetails('proteins'),
                      ),
                      MacronutrientProgressWidget(
                        name: 'Gorduras',
                        consumed: (_dailyData["macronutrients"]["fats"]
                            ["consumed"] as int),
                        total: (_dailyData["macronutrients"]["fats"]["total"]
                            as int),
                        color: AppTheme.activeBlue,
                        onLongPress: () => _showMacronutrientDetails('fats'),
                      ),
                    ],
                  ),
                ),

                // Weekly progress mini bars (calorias e água)
                WeeklyProgressWidget(
                  currentWeek: _currentWeek,
                  onWeekChanged: (w) => setState(() => _currentWeek = w),
                  weeklyCalories: _weeklyCalories,
                  dailyGoal: _dailyData["totalCalories"] as int? ?? 2000,
                  weeklyWater: _weeklyWater,
                  waterGoalMl: _dailyData["waterGoalMl"] as int? ?? 2000,
                  onDayTap: (i) {},
                ),

                SizedBox(height: 2.h),

                // Action button and quick actions
                ActionButtonWidget(
                  onPressed: _openFoodLogging,
                  onWater: _addWater,
                  onExercise: _addExercise,
                  onAi: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.aiFoodDetection,
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      // Pré-preencher a tela de comida com resultado da IA
                      Navigator.pushNamed(
                        context,
                        AppRoutes.foodLogging,
                        arguments: {
                          'prefillFood': result,
                          'mealKey': 'snack',
                          'date': _selectedDate.toIso8601String(),
                        },
                      ).then((value) {
                        if (value == true) {
                          _loadToday();
                        }
                      });
                    }
                  },
                ),

                // Weekly progress section
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.weeklyProgress,
                            arguments: {
                              'date': _selectedDate.toIso8601String(),
                            },
                          );
                        },
                        child: const Text('Ver semana'),
                      ),
                    ),
                    WeeklyProgressWidget(
                      currentWeek: _currentWeek,
                      onWeekChanged: _onWeekChanged,
                      weeklyCalories: _weeklyCalories,
                      dailyGoal: _dailyData["totalCalories"] as int,
                      onDayTap: _onWeekDayTap,
                      weeklyWater: _weeklyWater,
                      waterGoalMl: (_dailyData["waterGoalMl"] as int? ?? 2000),
                    ),
                  ],
                ),

                // Achievement badges
                AchievementBadgesWidget(
                  achievements: _achievements,
                  onBadgeTap: _showAchievementDetails,
                ),

                // Logged meals list
                _buildPerMealProgressSection(),
                SizedBox(height: 1.h),
                FutureBuilder<int>(
                  future: UserPreferences.getNewBadgeMinutes(),
                  builder: (context, snap) {
                    final mins = snap.data ?? 5;
                    final hl = Duration(minutes: mins);
                    bool showOnlyNew = false;
                    return StatefulBuilder(
                      builder: (context, setStateFilter) {
                        List<Map<String, dynamic>> filtered = _todayEntries;
                        if (showOnlyNew) {
                          filtered = _todayEntries.where((e) {
                            try {
                              final s = e['createdAt'] as String?;
                              if (s == null) return false;
                              final d = DateTime.parse(s);
                              return DateTime.now().difference(d) <= hl;
                            } catch (_) {
                              return false;
                            }
                          }).toList();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await _clearNewHighlightsForSelectedDay();
                                    setStateFilter(() {});
                                  },
                                  child: const Text('Limpar destaques'),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Somente novos',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.textSecondary),
                                    ),
                                    SizedBox(width: 2.w),
                                    Switch(
                                      value: showOnlyNew,
                                      onChanged: (v) {
                                        showOnlyNew = v;
                                        setStateFilter(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            LoggedMealsListWidget(
                              entries: filtered,
                              onRemove: (entry) async {
                                await NutritionStorage.removeEntryById(
                                    _selectedDate, entry['id']);
                                _loadToday();
                              },
                              onEdit: (entry) => _editEntry(entry),
                              highlightDuration: hl,
                              mealTotalsByKey: _mealTotals,
                              mealKcalGoals: {
                                'breakfast': _mealGoals['breakfast']?.kcal ?? 0,
                                'lunch': _mealGoals['lunch']?.kcal ?? 0,
                                'dinner': _mealGoals['dinner']?.kcal ?? 0,
                                'snack': _mealGoals['snack']?.kcal ?? 0,
                              },
                              mealMacroGoalsByKey: {
                                'breakfast': {
                                  'carbs': _mealGoals['breakfast']?.carbs ?? 0,
                                  'proteins':
                                      _mealGoals['breakfast']?.proteins ?? 0,
                                  'fats': _mealGoals['breakfast']?.fats ?? 0,
                                },
                                'lunch': {
                                  'carbs': _mealGoals['lunch']?.carbs ?? 0,
                                  'proteins':
                                      _mealGoals['lunch']?.proteins ?? 0,
                                  'fats': _mealGoals['lunch']?.fats ?? 0,
                                },
                                'dinner': {
                                  'carbs': _mealGoals['dinner']?.carbs ?? 0,
                                  'proteins':
                                      _mealGoals['dinner']?.proteins ?? 0,
                                  'fats': _mealGoals['dinner']?.fats ?? 0,
                                },
                                'snack': {
                                  'carbs': _mealGoals['snack']?.carbs ?? 0,
                                  'proteins':
                                      _mealGoals['snack']?.proteins ?? 0,
                                  'fats': _mealGoals['snack']?.fats ?? 0,
                                },
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppTheme.activeBlue,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.textPrimary,
          size: 28,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.secondaryBackgroundDark,
        selectedItemColor: AppTheme.activeBlue,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
              break; // Diário
            case 1:
              Navigator.pushNamed(context, AppRoutes.foodLogging);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.progressOverview);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'today',
              color: AppTheme.activeBlue,
              size: 24,
            ),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'flag',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'insights',
              color: AppTheme.textSecondary,
              size: 24,
            ),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _onWeekChanged(int newWeek) {
    setState(() {
      _currentWeek = newWeek;
    });
    _loadWeek();
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    await _loadToday();
    await _loadExercise();
  }

  void _showCalorieBreakdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Detalhamento de Calorias',
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              _buildCalorieDetailRow(
                'Consumidas',
                _dailyData["consumedCalories"],
                AppTheme.activeBlue,
              ),
              _buildCalorieDetailRow(
                'Restantes',
                _dailyData["totalCalories"] - _dailyData["consumedCalories"],
                AppTheme.successGreen,
              ),
              _buildCalorieDetailRow(
                'Gastas (Exercício)',
                _dailyData["spentCalories"],
                AppTheme.warningAmber,
              ),
              _buildCalorieDetailRow(
                'Meta Total',
                _dailyData["totalCalories"],
                AppTheme.textSecondary,
              ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalorieDetailRow(String label, int value, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '$value kcal',
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMacronutrientDetails(String macroType) {
    final macro =
        _dailyData["macronutrients"][macroType] as Map<String, dynamic>;
    final macroNames = {
      'carbohydrates': 'Carboidratos',
      'proteins': 'Proteínas',
      'fats': 'Gorduras',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Detalhes - ${macroNames[macroType]}',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consumido: ${macro["consumed"]}g',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Meta: ${macro["total"]}g',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Restante: ${macro["total"] - macro["consumed"]}g',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.activeBlue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: TextStyle(color: AppTheme.activeBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAchievementDetails(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Row(
            children: [
              CustomIconWidget(
                iconName: achievement['type'] == 'diamond'
                    ? 'diamond'
                    : achievement['type'] == 'flame'
                        ? 'local_fire_department'
                        : 'check_circle',
                color: achievement['type'] == 'diamond'
                    ? AppTheme.premiumGold
                    : achievement['type'] == 'flame'
                        ? AppTheme.warningAmber
                        : AppTheme.successGreen,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  achievement['title'] as String,
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            achievement['description'] as String,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: TextStyle(color: AppTheme.activeBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openFoodLogging() {
    Navigator.pushNamed(context, '/food-logging-screen').then((value) {
      if (value == true) {
        _loadToday();
      }
    });
  }

  void _duplicateLastMeal() async {
    final DateTime date = _selectedDate;
    try {
      final entries = await NutritionStorage.getEntriesForDate(date);
      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Sem refeições para duplicar hoje'),
              backgroundColor: AppTheme.warningAmber),
        );
        return;
      }
      entries.sort((a, b) => ((b['createdAt'] as String?) ?? '')
          .compareTo((a['createdAt'] as String?) ?? ''));
      final lastMealTime = (entries.first['mealTime'] as String?) ?? 'snack';
      final sameMeal = entries
          .where((e) => (e['mealTime'] as String?) == lastMealTime)
          .toList();
      for (final e in sameMeal) {
        final dup = Map<String, dynamic>.from(e);
        dup['id'] = null;
        dup['createdAt'] = DateTime.now().toIso8601String();
        await NutritionStorage.addEntry(date, dup);
      }
      if (!mounted) return;
      await _loadToday();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Refeição duplicada (${lastMealTime})'),
            backgroundColor: AppTheme.successGreen),
      );
    } catch (_) {}
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search, color: AppTheme.textPrimary),
                title: const Text('Buscar alimento'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openFoodLogging();
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: AppTheme.textPrimary),
                title: const Text('Favoritos'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/food-logging-screen',
                      arguments: {'activeTab': 'favorites'});
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.restaurant, color: AppTheme.textPrimary),
                title: const Text('Meus Alimentos'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/food-logging-screen',
                      arguments: {'activeTab': 'mine'});
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.playlist_add, color: AppTheme.textPrimary),
                title: const Text('Duplicar última refeição'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _duplicateLastMeal();
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadToday() async {
    List<Map<String, dynamic>> entries = [];
    try {
      entries = await NutritionStorage.getEntriesForDate(_selectedDate)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint("Aviso: Timeout ao carregar entradas de hoje");
        return [];
      });
    } catch (e, st) {
      debugPrint("Erro ao carregar entradas: $e");
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
      mealTotals[mt]!['kcal'] = mealTotals[mt]!['kcal']! + kcal;
      mealTotals[mt]!['carbs'] = mealTotals[mt]!['carbs']! + c;
      mealTotals[mt]!['proteins'] = mealTotals[mt]!['proteins']! + p;
      mealTotals[mt]!['fats'] = mealTotals[mt]!['fats']! + f;
    }
    if (mounted) {
      setState(() {
        _todayEntries = entries;
        _dailyData["consumedCalories"] = consumed;
        _dailyData["macronutrients"]["carbohydrates"]["consumed"] = carbs;
        _dailyData["macronutrients"]["proteins"]["consumed"] = protein;
        _dailyData["macronutrients"]["fats"]["consumed"] = fat;
        _mealTotals = mealTotals;
      });
    }
    _checkMealExceeds();
  }

  void _checkMealExceeds() {
    final Map<String, String> labels = {
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

  Future<void> _loadWeek() async {
    final now = _selectedDate;
    // Consider domingo como último (índice 6)
    final int weekday = now.weekday; // 1=Mon ... 7=Sun
    final DateTime monday = now.subtract(Duration(days: (weekday - 1)));
    final List<int> week = [];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(day);
      final kcal = entries.fold<int>(
          0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
      week.add(kcal);
      final water = await NutritionStorage.getWaterMl(day);
      _weeklyWater[i] = water;
    }
    if (mounted) {
      setState(() {
        _weeklyCalories = week;
        _weeklyWater = List<int>.from(_weeklyWater);
      });
    }
  }

  Future<void> _loadExercise() async {
    final kcal = await NutritionStorage.getExerciseCalories(_selectedDate);
    if (!mounted) return;
    setState(() {
      _dailyData["spentCalories"] = kcal;
    });
    _updateHydrationAchievements();
  }

  void _addWater() {
    NutritionStorage.addWaterMl(_selectedDate, 250).then((ml) {
      if (!mounted) return;
      setState(() {
        _dailyData["waterMl"] = ml;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Água registrada: +250ml (total ${ml}ml)'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _updateHydrationAchievements();
    });
  }

  void _openEditWaterGoalDialog() {
    final controller = TextEditingController(
        text: (_dailyData["waterGoalMl"] as int).toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text('Ajustar meta de água',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'ml por dia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(controller.text.trim()) ?? 2000;
              await UserPreferences.setWaterGoal(val);
              if (!mounted) return;
              setState(() {
                _dailyData["waterGoalMl"] = val;
              });
              _loadGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Meta de água atualizada'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _openEditMacroGoalsDialog() async {
    final goals = await UserPreferences.getGoals();
    if (!mounted) return;
    final carbCtrl = TextEditingController(text: goals.carbs.toString());
    final protCtrl = TextEditingController(text: goals.proteins.toString());
    final fatCtrl = TextEditingController(text: goals.fats.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text('Ajustar metas de macros',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: carbCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Carboidratos (g)'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: protCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Proteínas (g)'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: fatCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Gorduras (g)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final carbs = int.tryParse(carbCtrl.text.trim()) ?? goals.carbs;
              final prots =
                  int.tryParse(protCtrl.text.trim()) ?? goals.proteins;
              final fats = int.tryParse(fatCtrl.text.trim()) ?? goals.fats;
              await UserPreferences.setGoals(
                totalCalories: goals.totalCalories,
                carbs: carbs,
                proteins: prots,
                fats: fats,
              );
              if (!mounted) return;
              setState(() {
                _dailyData["macronutrients"]["carbohydrates"]["total"] = carbs;
                _dailyData["macronutrients"]["proteins"]["total"] = prots;
                _dailyData["macronutrients"]["fats"]["total"] = fats;
              });
              _loadGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Metas de macros atualizadas'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _openEditMealGoalsDialog() async {
    final current = await UserPreferences.getMealGoals();
    if (!mounted) return;
    final bkcal = TextEditingController(
        text: (current['breakfast']?.kcal ?? 0).toString());
    final bcarb = TextEditingController(
        text: (current['breakfast']?.carbs ?? 0).toString());
    final bprot = TextEditingController(
        text: (current['breakfast']?.proteins ?? 0).toString());
    final bfat = TextEditingController(
        text: (current['breakfast']?.fats ?? 0).toString());

    final lkcal =
        TextEditingController(text: (current['lunch']?.kcal ?? 0).toString());
    final lcarb =
        TextEditingController(text: (current['lunch']?.carbs ?? 0).toString());
    final lprot = TextEditingController(
        text: (current['lunch']?.proteins ?? 0).toString());
    final lfat =
        TextEditingController(text: (current['lunch']?.fats ?? 0).toString());

    final dkcal =
        TextEditingController(text: (current['dinner']?.kcal ?? 0).toString());
    final dcarb =
        TextEditingController(text: (current['dinner']?.carbs ?? 0).toString());
    final dprot = TextEditingController(
        text: (current['dinner']?.proteins ?? 0).toString());
    final dfat =
        TextEditingController(text: (current['dinner']?.fats ?? 0).toString());

    final skcal =
        TextEditingController(text: (current['snack']?.kcal ?? 0).toString());
    final scarb =
        TextEditingController(text: (current['snack']?.carbs ?? 0).toString());
    final sprot = TextEditingController(
        text: (current['snack']?.proteins ?? 0).toString());
    final sfat =
        TextEditingController(text: (current['snack']?.fats ?? 0).toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text('Metas por refeição',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Café da manhã',
                  style: AppTheme.darkTheme.textTheme.titleSmall
                      ?.copyWith(color: AppTheme.textPrimary)),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: bkcal,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kcal'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: bcarb,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carb (g)'))),
              ]),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: bprot,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prot (g)'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: bfat,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Gord (g)'))),
              ]),
              SizedBox(height: 12),
              Text('Almoço',
                  style: AppTheme.darkTheme.textTheme.titleSmall
                      ?.copyWith(color: AppTheme.textPrimary)),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: lkcal,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kcal'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: lcarb,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carb (g)'))),
              ]),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: lprot,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prot (g)'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: lfat,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Gord (g)'))),
              ]),
              SizedBox(height: 12),
              Text('Jantar',
                  style: AppTheme.darkTheme.textTheme.titleSmall
                      ?.copyWith(color: AppTheme.textPrimary)),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: dkcal,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kcal'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: dcarb,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carb (g)'))),
              ]),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: dprot,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prot (g)'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: dfat,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Gord (g)'))),
              ]),
              SizedBox(height: 12),
              Text('Lanches',
                  style: AppTheme.darkTheme.textTheme.titleSmall
                      ?.copyWith(color: AppTheme.textPrimary)),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: skcal,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kcal'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: scarb,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carb (g)'))),
              ]),
              SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: sprot,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prot (g)'))),
                SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: sfat,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Gord (g)'))),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final byMeal = <String, MealGoals>{
                'breakfast': MealGoals(
                  kcal: int.tryParse(bkcal.text.trim()) ??
                      (current['breakfast']?.kcal ?? 0),
                  carbs: int.tryParse(bcarb.text.trim()) ??
                      (current['breakfast']?.carbs ?? 0),
                  proteins: int.tryParse(bprot.text.trim()) ??
                      (current['breakfast']?.proteins ?? 0),
                  fats: int.tryParse(bfat.text.trim()) ??
                      (current['breakfast']?.fats ?? 0),
                ),
                'lunch': MealGoals(
                  kcal: int.tryParse(lkcal.text.trim()) ??
                      (current['lunch']?.kcal ?? 0),
                  carbs: int.tryParse(lcarb.text.trim()) ??
                      (current['lunch']?.carbs ?? 0),
                  proteins: int.tryParse(lprot.text.trim()) ??
                      (current['lunch']?.proteins ?? 0),
                  fats: int.tryParse(lfat.text.trim()) ??
                      (current['lunch']?.fats ?? 0),
                ),
                'dinner': MealGoals(
                  kcal: int.tryParse(dkcal.text.trim()) ??
                      (current['dinner']?.kcal ?? 0),
                  carbs: int.tryParse(dcarb.text.trim()) ??
                      (current['dinner']?.carbs ?? 0),
                  proteins: int.tryParse(dprot.text.trim()) ??
                      (current['dinner']?.proteins ?? 0),
                  fats: int.tryParse(dfat.text.trim()) ??
                      (current['dinner']?.fats ?? 0),
                ),
                'snack': MealGoals(
                  kcal: int.tryParse(skcal.text.trim()) ??
                      (current['snack']?.kcal ?? 0),
                  carbs: int.tryParse(scarb.text.trim()) ??
                      (current['snack']?.carbs ?? 0),
                  proteins: int.tryParse(sprot.text.trim()) ??
                      (current['snack']?.proteins ?? 0),
                  fats: int.tryParse(sfat.text.trim()) ??
                      (current['snack']?.fats ?? 0),
                ),
              };
              await UserPreferences.setMealGoals(byMeal);
              if (!mounted) return;
              await _loadMealGoals();
              _checkMealExceeds();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Metas por refeição atualizadas'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removeWater() {
    NutritionStorage.addWaterMl(_selectedDate, -250).then((ml) {
      if (!mounted) return;
      setState(() {
        _dailyData["waterMl"] = ml;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Água ajustada: -250ml (total ${ml}ml)'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      _updateHydrationAchievements();
    });
  }

  bool _hasAchievementById(String id) {
    return _achievements.any((a) => (a['id']?.toString() ?? '') == id);
  }

  Future<void> _updateHydrationAchievements() async {
    final goals = await UserPreferences.getGoals();
    final int waterGoal = goals.waterGoalMl;
    if (waterGoal <= 0) return;

    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ).subtract(Duration(days: i));
      final ml = await NutritionStorage.getWaterMl(day);
      if (ml >= waterGoal) {
        streak += 1;
      } else {
        break;
      }
    }

    final List<int> thresholds = [3, 5, 7];
    bool added = false;
    for (final t in thresholds) {
      final String badgeId = 'hydration_streak_$t';
      if (streak >= t && !_hasAchievementById(badgeId)) {
        _achievements.insert(0, {
          "id": badgeId,
          "type": "success",
          "title": "Hidratação",
          "description": "Meta de água atingida por $t dias consecutivos.",
          "earnedDate": DateTime.now().toIso8601String(),
        });
        added = true;
      }
    }
    if (added && mounted) {
      setState(() {});
    }
  }

  void _addExercise() async {
    final next = await NutritionStorage.addExerciseCalories(_selectedDate, 100);
    if (!mounted) return;
    setState(() {
      _dailyData["spentCalories"] = next;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exercício registrado: +100 kcal'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _onWeekDayTap(int index) async {
    final now = _selectedDate;
    final int weekday = now.weekday; // 1..7
    final DateTime monday = now.subtract(Duration(days: (weekday - 1)));
    final DateTime tappedDay = monday.add(Duration(days: index));
    final entries = await NutritionStorage.getEntriesForDate(tappedDay);
    final int waterMlDay = await NutritionStorage.getWaterMl(tappedDay);
    final int exerciseKcalDay =
        await NutritionStorage.getExerciseCalories(tappedDay);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final int totalKcal = entries.fold<int>(
            0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Registros de ${tappedDay.day}/${tappedDay.month}',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Total: $totalKcal kcal',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.activeBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Água: ${waterMlDay} ml',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Exercício: ${exerciseKcalDay} kcal',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              ...entries.map((e) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e['name'] as String? ?? '-',
                            style: AppTheme.darkTheme.textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          '${e['calories']} kcal',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.activeBlue,
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            tappedDay.year, tappedDay.month, tappedDay.day);
                      });
                      _loadToday();
                      _loadWeek();
                      Navigator.pop(context);
                    },
                    child: Text('Ver dia',
                        style: TextStyle(color: AppTheme.activeBlue)),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _addMealButton('Café', 'breakfast', tappedDay),
                      _addMealButton('Almoço', 'lunch', tappedDay),
                      _addMealButton('Jantar', 'dinner', tappedDay),
                      _addMealButton('Lanche', 'snack', tappedDay),
                      OutlinedButton(
                        onPressed: () async {
                          final ml = await NutritionStorage.addWaterMl(
                              tappedDay, -250);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Água ajustada: -250ml (total ${ml}ml)'),
                              backgroundColor: AppTheme.warningAmber,
                            ),
                          );
                          if (tappedDay.year == _selectedDate.year &&
                              tappedDay.month == _selectedDate.month &&
                              tappedDay.day == _selectedDate.day) {
                            setState(() {
                              _dailyData["waterMl"] = ml;
                            });
                            _updateHydrationAchievements();
                          }
                          _loadWeek();
                        },
                        child: const Text('-250 ml'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final ml =
                              await NutritionStorage.addWaterMl(tappedDay, 250);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Água registrada: +250ml (total ${ml}ml)'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                          if (tappedDay.year == _selectedDate.year &&
                              tappedDay.month == _selectedDate.month &&
                              tappedDay.day == _selectedDate.day) {
                            setState(() {
                              _dailyData["waterMl"] = ml;
                            });
                            _updateHydrationAchievements();
                          }
                          _loadWeek();
                        },
                        child: const Text('+250 ml'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final kcal =
                              await NutritionStorage.addExerciseCalories(
                                  tappedDay, 100);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Exercício registrado: +100 kcal'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                          if (tappedDay.year == _selectedDate.year &&
                              tappedDay.month == _selectedDate.month &&
                              tappedDay.day == _selectedDate.day) {
                            setState(() {
                              _dailyData["spentCalories"] = kcal;
                            });
                          }
                          _loadWeek();
                        },
                        child: const Text('+100 kcal'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final controller = TextEditingController(
                              text: (_dailyData["waterGoalMl"] as int)
                                  .toString());
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppTheme.secondaryBackgroundDark,
                              title: Text('Ajustar meta de água',
                                  style: AppTheme.darkTheme.textTheme.titleLarge
                                      ?.copyWith(color: AppTheme.textPrimary)),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'ml por dia'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancelar',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final val =
                                        int.tryParse(controller.text.trim()) ??
                                            2000;
                                    await UserPreferences.setWaterGoal(val);
                                    if (!mounted) return;
                                    setState(() {
                                      _dailyData["waterGoalMl"] = val;
                                    });
                                    _loadGoals();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Meta de água atualizada'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  },
                                  child: const Text('Salvar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Meta Água'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final goals = await UserPreferences.getGoals();
                          final controller = TextEditingController(
                              text: goals.totalCalories.toString());
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppTheme.secondaryBackgroundDark,
                              title: Text('Ajustar meta de calorias',
                                  style: AppTheme.darkTheme.textTheme.titleLarge
                                      ?.copyWith(color: AppTheme.textPrimary)),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'kcal por dia'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancelar',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final val =
                                        int.tryParse(controller.text.trim()) ??
                                            goals.totalCalories;
                                    await UserPreferences.setGoals(
                                      totalCalories: val,
                                      carbs: goals.carbs,
                                      proteins: goals.proteins,
                                      fats: goals.fats,
                                    );
                                    if (!mounted) return;
                                    setState(() {
                                      _dailyData["totalCalories"] = val;
                                    });
                                    _loadGoals();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Meta de calorias atualizada'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  },
                                  child: const Text('Salvar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Meta Calorias'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
          ),
        );
      },
    );
  }

  void _editEntry(Map<String, dynamic> entry) {
    final qtyController =
        TextEditingController(text: (entry['quantity']?.toString() ?? '1'));
    final servingController =
        TextEditingController(text: (entry['serving'] as String?) ?? 'porção');
    final mealOptions = const [
      {'key': 'breakfast', 'label': 'Café da manhã'},
      {'key': 'lunch', 'label': 'Almoço'},
      {'key': 'dinner', 'label': 'Jantar'},
      {'key': 'snack', 'label': 'Lanches'},
    ];
    String selectedMeal = (entry['mealTime'] as String?) ?? 'snack';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppTheme.secondaryBackgroundDark,
              title: Text(
                'Editar item',
                style: AppTheme.darkTheme.textTheme.titleLarge
                    ?.copyWith(color: AppTheme.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: servingController,
                    decoration: const InputDecoration(labelText: 'Porção'),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMeal,
                    decoration: const InputDecoration(labelText: 'Período'),
                    items: mealOptions
                        .map((m) => DropdownMenuItem<String>(
                              value: m['key'] as String,
                              child: Text(m['label'] as String),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedMeal = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    // Duplicar
                    final q = double.tryParse(qtyController.text.trim()) ?? 1.0;
                    final oldQ = (entry['quantity'] as num?)?.toDouble() ?? 1.0;
                    final baseFactor = oldQ == 0 ? 1.0 : (q / oldQ);

                    final duplicate = Map<String, dynamic>.from(entry);
                    duplicate['quantity'] = q;
                    duplicate['serving'] = servingController.text.trim();
                    duplicate['mealTime'] = selectedMeal;
                    duplicate['createdAt'] = DateTime.now().toIso8601String();
                    duplicate['calories'] =
                        ((entry['calories'] as num?)?.toDouble() ??
                                0 * baseFactor)
                            .round();
                    duplicate['carbs'] =
                        ((entry['carbs'] as num?)?.toDouble() ?? 0 * baseFactor)
                            .round();
                    duplicate['protein'] =
                        ((entry['protein'] as num?)?.toDouble() ??
                                0 * baseFactor)
                            .round();
                    duplicate['fat'] =
                        ((entry['fat'] as num?)?.toDouble() ?? 0 * baseFactor)
                            .round();

                    await NutritionStorage.addEntry(_selectedDate, duplicate);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadToday();
                  },
                  child: const Text('Duplicar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final q = double.tryParse(qtyController.text.trim()) ?? 1.0;
                    final updated = Map<String, dynamic>.from(entry);
                    final oldQ = (entry['quantity'] as num?)?.toDouble() ?? 1.0;
                    updated['quantity'] = q;
                    updated['serving'] = servingController.text.trim();
                    updated['mealTime'] = selectedMeal;

                    final baseFactor = oldQ == 0 ? 1.0 : (q / oldQ);
                    updated['calories'] =
                        ((entry['calories'] as num?)?.toDouble() ??
                                0 * baseFactor)
                            .round();
                    updated['carbs'] =
                        ((entry['carbs'] as num?)?.toDouble() ?? 0 * baseFactor)
                            .round();
                    updated['protein'] =
                        ((entry['protein'] as num?)?.toDouble() ??
                                0 * baseFactor)
                            .round();
                    updated['fat'] =
                        ((entry['fat'] as num?)?.toDouble() ?? 0 * baseFactor)
                            .round();

                    await NutritionStorage.updateEntryById(
                        _selectedDate, entry['id'], updated);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadToday();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadGoals() async {
    final goals = await UserPreferences.getGoals();
    if (!mounted) return;
    setState(() {
      _dailyData["totalCalories"] = goals.totalCalories;
      _dailyData["macronutrients"]["carbohydrates"]["total"] = goals.carbs;
      _dailyData["macronutrients"]["proteins"]["total"] = goals.proteins;
      _dailyData["macronutrients"]["fats"]["total"] = goals.fats;
      _dailyData["waterGoalMl"] = goals.waterGoalMl;
    });
  }

  Future<void> _loadMealGoals() async {
    final goals = await UserPreferences.getMealGoals();
    if (!mounted) return;
    setState(() {
      _mealGoals = goals;
    });
  }

  void _openDayActionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 12.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text('Ações do dia',
                    style: AppTheme.darkTheme.textTheme.titleLarge
                        ?.copyWith(color: AppTheme.textPrimary)),
                SizedBox(height: 1.5.h),
                ListTile(
                  leading:
                      Icon(Icons.bookmark_border, color: AppTheme.textPrimary),
                  title: Text('Salvar dia como template',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final ok = await _promptSaveDayTemplate(_selectedDate);
                    if (ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Template de dia salvo'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmarks, color: AppTheme.textPrimary),
                  title: Text('Aplicar template de dia',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _promptApplyDayTemplate(_selectedDate);
                    if (!mounted) return;
                    await _loadToday();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Template aplicado ao dia'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy_all, color: AppTheme.textPrimary),
                  title: Text('Duplicar dia → amanhã',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final to = _selectedDate.add(const Duration(days: 1));
                    await NutritionStorage.duplicateDay(_selectedDate, to);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Dia duplicado para ${to.day}/${to.month}'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event, color: AppTheme.textPrimary),
                  title: Text('Duplicar dia → escolher data',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked =
                        await _pickTargetDate(initial: _selectedDate);
                    if (picked == null) return;
                    await NutritionStorage.duplicateDay(_selectedDate, picked);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Dia duplicado para ${picked.day}/${picked.month}'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bolt, color: AppTheme.textPrimary),
                  title: Text('Duplicar "novos" → escolher data',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final int minutes =
                        await UserPreferences.getNewBadgeMinutes();
                    final Duration hl = Duration(minutes: minutes);
                    final all =
                        await NutritionStorage.getEntriesForDate(_selectedDate);
                    final newEntries = all.where((e) {
                      try {
                        final s = e['createdAt'] as String?;
                        if (s == null) return false;
                        final d = DateTime.parse(s);
                        return DateTime.now().difference(d) <= hl;
                      } catch (_) {
                        return false;
                      }
                    }).toList();
                    if (newEntries.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Nenhum item "novo" para duplicar'),
                          backgroundColor: AppTheme.warningAmber,
                        ),
                      );
                      return;
                    }
                    // Confirma seleção
                    final selected = List<bool>.filled(newEntries.length, true);
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.secondaryBackgroundDark,
                        title: Text('Selecionar itens para duplicar',
                            style: AppTheme.darkTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                            )),
                        content: SizedBox(
                          width: 600,
                          child: StatefulBuilder(
                            builder: (context, setStateSel) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < newEntries.length; i++)
                                    CheckboxListTile(
                                      value: selected[i],
                                      onChanged: (v) => setStateSel(
                                          () => selected[i] = v ?? true),
                                      title: Text(
                                        (newEntries[i]['name'] as String?) ??
                                            '-',
                                        style: AppTheme
                                            .darkTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${newEntries[i]['calories']} kcal',
                                        style: AppTheme
                                            .darkTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Continuar'),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) return;
                    // permitir edição de gramas
                    final gramCtrls = List.generate(newEntries.length, (i) {
                      final s = newEntries[i]['serving'] as String?;
                      final match = s != null
                          ? RegExp(r"(\\d+)\\s*g").firstMatch(s)
                          : null;
                      final g = match != null ? match.group(1) : null;
                      return TextEditingController(text: g ?? '100');
                    });
                    final picked =
                        await _pickTargetDate(initial: _selectedDate);
                    if (picked == null) return;
                    int dup = 0;
                    for (int i = 0; i < newEntries.length; i++) {
                      if (!selected[i]) continue;
                      final e = Map<String, dynamic>.from(newEntries[i]);
                      int newG = int.tryParse(gramCtrls[i].text.trim()) ?? 100;
                      final s = (newEntries[i]['serving'] as String?);
                      final match = s != null
                          ? RegExp(r"(\\d+)\\s*g").firstMatch(s)
                          : null;
                      if (match != null) {
                        final origG = int.tryParse(match.group(1)!) ?? 0;
                        if (origG > 0) {
                          final factor = newG / origG;
                          e['calories'] =
                              (((e['calories'] as num?)?.toDouble() ?? 0) *
                                      factor)
                                  .round();
                          e['carbs'] =
                              ((e['carbs'] as num?)?.toDouble() ?? 0) * factor;
                          e['protein'] =
                              ((e['protein'] as num?)?.toDouble() ?? 0) *
                                  factor;
                          e['fat'] =
                              ((e['fat'] as num?)?.toDouble() ?? 0) * factor;
                        }
                      }
                      e['serving'] = '${newG} g';
                      e['id'] = DateTime.now().microsecondsSinceEpoch + dup;
                      e['createdAt'] = DateTime.now().toIso8601String();
                      await NutritionStorage.addEntry(picked, e);
                      dup += 1;
                    }
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Duplicados ${dup} item(ns) para ${picked.day}/${picked.month}'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.upload_file, color: AppTheme.textPrimary),
                  title: Text('Exportar dia (CSV)',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final csv = _buildDayCsv(_selectedDate);
                    final def = _defaultDayCsvFilename(_selectedDate);
                    final controller = TextEditingController(text: def);
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.secondaryBackgroundDark,
                        title: Text('Nome do arquivo',
                            style: AppTheme.darkTheme.textTheme.titleLarge
                                ?.copyWith(color: AppTheme.textPrimary)),
                        content: TextField(
                          controller: controller,
                          decoration:
                              const InputDecoration(hintText: 'arquivo.csv'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              var name = controller.text.trim();
                              if (name.isEmpty) name = def;
                              if (!name.toLowerCase().endsWith('.csv')) {
                                name = '$name.csv';
                              }
                              if (kIsWeb) {
                                await downloadCsvFile(name, csv);
                              } else {
                                await Clipboard.setData(
                                    ClipboardData(text: csv));
                                await Share.share(csv,
                                    subject: name,
                                    sharePositionOrigin: Rect.zero);
                              }
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(kIsWeb
                                      ? 'CSV do dia baixado'
                                      : 'CSV do dia copiado/compartilhado'),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            },
                            child: Text(kIsWeb ? 'Baixar' : 'Copiar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_upload, color: AppTheme.textPrimary),
                  title: Text('Importar dia (CSV)',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () async {
                    Navigator.pop(context);
                    final controller = TextEditingController();
                    bool clearBefore = false;
                    await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.secondaryBackgroundDark,
                        title: Text('Importar CSV do dia',
                            style: AppTheme.darkTheme.textTheme.titleLarge
                                ?.copyWith(color: AppTheme.textPrimary)),
                        content: SizedBox(
                          width: 700,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatefulBuilder(builder: (context, setState) {
                                return CheckboxListTile(
                                  value: clearBefore,
                                  onChanged: (v) =>
                                      setState(() => clearBefore = v ?? false),
                                  title: Text('Limpar dia antes de importar',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppTheme.textPrimary)),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              }),
                              TextField(
                                controller: controller,
                                maxLines: 12,
                                decoration: const InputDecoration(
                                  hintText:
                                      'name,meal,kcal,carbs,proteins,fats,quantity,serving\nBanana,breakfast,89,23,1,0,1.0,unid',
                                ),
                              ),
                              if (kIsWeb) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final text = await pickCsvText();
                                      if (text != null && text.isNotEmpty) {
                                        controller.text = text;
                                      }
                                    },
                                    icon: const Icon(Icons.attach_file),
                                    label:
                                        const Text('Escolher arquivo (.csv)'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final csv = controller.text.trim();
                              final n = await _importDayCsv(_selectedDate, csv,
                                  clearBefore: clearBefore);
                              if (!mounted) return;
                              Navigator.pop(context, true);
                              await _loadToday();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Importado ${n} item(ns) para o dia'),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            },
                            child: const Text('Importar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _promptSaveDayTemplate(DateTime day) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text('Salvar dia como template',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome do template'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final label = controller.text.trim();
              if (label.isNotEmpty) {
                await NutritionStorage.saveDayTemplate(label: label, date: day);
                if (!mounted) return;
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _promptApplyDayTemplate(DateTime day) async {
    final templates = await NutritionStorage.getDayTemplates();
    if (templates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nenhum template de dia salvo'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }
    bool clearBefore = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text('Aplicar template de dia',
            style: AppTheme.darkTheme.textTheme.titleLarge
                ?.copyWith(color: AppTheme.textPrimary)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(builder: (context, setState) {
                return CheckboxListTile(
                  value: clearBefore,
                  onChanged: (v) => setState(() => clearBefore = v ?? false),
                  title: Text('Limpar dia antes de aplicar',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              for (final t in templates)
                ListTile(
                  title: Text(
                    (t['label'] as String?) ?? 'sem nome',
                    style: AppTheme.darkTheme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    (t['createdAt'] as String?) ?? '',
                    style: AppTheme.darkTheme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                  onTap: () async {
                    if (clearBefore) {
                      await NutritionStorage.clearDayFully(day);
                    }
                    await NutritionStorage.applyDayTemplateOnDate(
                      template: t,
                      date: day,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppTheme.errorRed,
                    onPressed: () async {
                      await NutritionStorage.removeDayTemplate(t['id']);
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _promptApplyDayTemplate(day);
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Fechar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickTargetDate({required DateTime initial}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.activeBlue,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return DateTime(picked.year, picked.month, picked.day);
  }

  String _defaultDayCsvFilename(DateTime day) {
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${day.year}-${two(day.month)}-${two(day.day)}';
    return 'nutritracker_day_$date.csv';
  }

  String _buildDayCsv(DateTime day) {
    final buffer = StringBuffer();
    buffer.writeln('name,meal,kcal,carbs,proteins,fats,quantity,serving');
    for (final e in _todayEntries) {
      final name = (e['name'] ?? '').toString().replaceAll(',', ' ');
      final meal = (e['mealTime'] ?? '').toString();
      final kcal = (e['calories'] as num?)?.toInt() ?? 0;
      final carbs = (e['carbs'] as num?)?.toInt() ?? 0;
      final prot = (e['protein'] as num?)?.toInt() ?? 0;
      final fat = (e['fat'] as num?)?.toInt() ?? 0;
      final qty = (e['quantity'] as num?)?.toDouble() ?? 1.0;
      final serving = (e['serving'] ?? '').toString().replaceAll(',', ' ');
      buffer.writeln('$name,$meal,$kcal,$carbs,$prot,$fat,$qty,$serving');
    }
    return buffer.toString();
  }

  Future<int> _importDayCsv(DateTime day, String csv,
      {bool clearBefore = false}) async {
    if (csv.isEmpty) return 0;
    if (clearBefore) {
      await NutritionStorage.clearDayFully(day);
    }
    final lines =
        csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return 0;
    int startIdx = 0;
    final header = lines.first.toLowerCase();
    if (header.contains('name') && header.contains('meal')) {
      startIdx = 1;
    }
    int imported = 0;
    for (int i = startIdx; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 8) continue;
      try {
        final name = parts[0].trim();
        final meal = parts[1].trim();
        final kcal = int.tryParse(parts[2].trim()) ?? 0;
        final carbs = int.tryParse(parts[3].trim()) ?? 0;
        final prot = int.tryParse(parts[4].trim()) ?? 0;
        final fat = int.tryParse(parts[5].trim()) ?? 0;
        final qty = double.tryParse(parts[6].trim()) ?? 1.0;
        final serving = parts.sublist(7).join(',').trim();
        final entry = <String, dynamic>{
          'id': DateTime.now().microsecondsSinceEpoch + i,
          'name': name,
          'mealTime': meal.isNotEmpty ? meal : 'snack',
          'calories': kcal,
          'carbs': carbs,
          'protein': prot,
          'fat': fat,
          'quantity': qty,
          'serving': serving,
          'createdAt': DateTime.now().toIso8601String(),
          'source': 'csv_import',
        };
        await NutritionStorage.addEntry(day, entry);
        imported += 1;
      } catch (_) {
        // skip
      }
    }
    return imported;
  }

  Widget _addMealButton(String label, String mealKey, DateTime day) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/food-logging-screen',
          arguments: {
            'mealKey': mealKey,
            'date': day.toIso8601String(),
          },
        ).then((value) {
          if (value == true) {
            _loadToday();
            _loadWeek();
          }
        });
      },
      child: Text(label),
    );
  }
}
