// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as services;
import 'package:nutritracker/util/download_stub.dart'
    if (dart.library.html) 'package:nutritracker/util/download_web.dart';
import 'package:nutritracker/util/upload_stub.dart'
    if (dart.library.html) 'package:nutritracker/util/upload_web.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../core/app_export.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import '../../services/nutrition_storage.dart';
import '../../services/user_preferences.dart';
import '../../routes/app_routes.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  DateTime _anchorDate = DateTime.now();
  List<int> _weeklyCalories = List.filled(7, 0);
  List<int> _weeklyWater = List.filled(7, 0);
  List<int> _weeklyExercise = List.filled(7, 0);
  List<int> _weeklyCarbs = List.filled(7, 0);
  List<int> _weeklyProteins = List.filled(7, 0);
  List<int> _weeklyFats = List.filled(7, 0);
  List<bool> _weeklyHasNew = List.filled(7, false);
  int _dailyCalorieGoal = 2000;
  int _waterGoalMl = 2000;
  Map<String, MealGoals> _mealGoals = const {
    'breakfast': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'lunch': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'dinner': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
    'snack': MealGoals(kcal: 0, carbs: 0, proteins: 0, fats: 0),
  };
  Map<String, int> _mealAvgKcal = {
    'breakfast': 0,
    'lunch': 0,
    'dinner': 0,
    'snack': 0,
  };

  // Animation constants (aligned with dashboard)
  static const Duration _kAnimDuration = Duration(milliseconds: 900);
  static const Curve _kAnimCurve = Curves.easeOut;
  // Per-bar stagger fraction (e.g., 0.04 => ~36ms on 900ms anim)
  static const double _kBarStaggerFrac = 0.03;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final dateArg = args['date'];
        if (dateArg is String) {
          try {
            final d = DateTime.parse(dateArg);
            _anchorDate = DateTime(d.year, d.month, d.day);
          } catch (_) {}
        } else if (dateArg is DateTime) {
          _anchorDate = DateTime(dateArg.year, dateArg.month, dateArg.day);
        }
      }
      _loadGoalsAndWeek();
    });
  }

  Widget _entryRowWithHighlight(
      BuildContext context, Map<String, dynamic> e, Duration highlight) {
    DateTime? createdAt;
    final createdStr = e['createdAt'] as String?;
    if (createdStr != null) {
      try {
        createdAt = DateTime.parse(createdStr);
      } catch (_) {}
    }
    final bool isNew =
        createdAt != null && DateTime.now().difference(createdAt) <= highlight;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isNew
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNew
                ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.6)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                e['name'] as String? ?? '-',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (isNew)
              Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.achievementsNewBadge ?? 'New',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            Text(
              '${e['calories']} kcal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEntryNew(Map<String, dynamic> e, Duration highlight) {
    try {
      final s = e['createdAt'] as String?;
      if (s == null) return false;
      final d = DateTime.parse(s);
      return DateTime.now().difference(d) <= highlight;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadGoalsAndWeek() async {
    final goals = await UserPreferences.getGoals();
    final mealGoals = await UserPreferences.getMealGoals();
    if (!mounted) return;
    setState(() {
      _dailyCalorieGoal = goals.totalCalories;
      _waterGoalMl = goals.waterGoalMl;
      _mealGoals = mealGoals;
    });
    await _loadWeek();
  }

  Future<void> _loadWeek() async {
    final int weekday = _anchorDate.weekday; // 1=Mon..7=Sun
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final List<int> cal = [];
    final List<int> water = [];
    final List<int> exercise = [];
    final List<int> carbs = [];
    final List<int> proteins = [];
    final List<int> fats = [];
    final int minutes = await UserPreferences.getNewBadgeMinutes();
    final Duration highlight = Duration(minutes: minutes);
    final List<bool> hasNew = List.filled(7, false);
    int sumBreakfast = 0, sumLunch = 0, sumDinner = 0, sumSnack = 0;
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(day);
      final kc = entries.fold<int>(
          0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
      // detect new entries within highlight window
      for (final e in entries) {
        final s = e['createdAt'] as String?;
        if (s == null) continue;
        try {
          final d = DateTime.parse(s);
          if (DateTime.now().difference(d) <= highlight) {
            hasNew[i] = true;
            break;
          }
        } catch (_) {}
      }
      for (final e in entries) {
        final kcal = (e['calories'] as num?)?.toInt() ?? 0;
        final mt = (e['mealTime'] as String?) ?? 'snack';
        if (mt == 'breakfast')
          sumBreakfast += kcal;
        else if (mt == 'lunch')
          sumLunch += kcal;
        else if (mt == 'dinner')
          sumDinner += kcal;
        else
          sumSnack += kcal;
      }
      final c = entries.fold<int>(
          0, (sum, e) => sum + ((e['carbs'] as num?)?.toInt() ?? 0));
      final p = entries.fold<int>(
          0, (sum, e) => sum + ((e['protein'] as num?)?.toInt() ?? 0));
      final f = entries.fold<int>(
          0, (sum, e) => sum + ((e['fat'] as num?)?.toInt() ?? 0));
      cal.add(kc);
      water.add(await NutritionStorage.getWaterMl(day));
      exercise.add(await NutritionStorage.getExerciseCalories(day));
      carbs.add(c);
      proteins.add(p);
      fats.add(f);
    }
    if (!mounted) return;
    setState(() {
      _weeklyCalories = cal;
      _weeklyWater = water;
      _weeklyExercise = exercise;
      _weeklyCarbs = carbs;
      _weeklyProteins = proteins;
      _weeklyFats = fats;
      _weeklyHasNew = hasNew;
      _mealAvgKcal = {
        'breakfast': (sumBreakfast / 7).round(),
        'lunch': (sumLunch / 7).round(),
        'dinner': (sumDinner / 7).round(),
        'snack': (sumSnack / 7).round(),
      };
    });
  }

  void _changeWeek(int deltaWeeks) {
    setState(() {
      _anchorDate = _anchorDate.add(Duration(days: 7 * deltaWeeks));
    });
    _loadWeek();
  }

  String _weekRangeLabel() {
    final int weekday = _anchorDate.weekday;
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final DateTime sunday = monday.add(const Duration(days: 6));
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(monday.day)}/${two(monday.month)} - ${two(sunday.day)}/${two(sunday.month)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalCalWeek = _weeklyCalories.fold<int>(0, (a, b) => a + b);
    final avgCal = (totalCalWeek / 7).round();
    final totalWaterWeek = _weeklyWater.fold<int>(0, (a, b) => a + b);
    final totalExerciseWeek = _weeklyExercise.fold<int>(0, (a, b) => a + b);
    final avgCarbs = (_weeklyCarbs.fold<int>(0, (a, b) => a + b) / 7).round();
    final avgProteins =
        (_weeklyProteins.fold<int>(0, (a, b) => a + b) / 7).round();
    final avgFats = (_weeklyFats.fold<int>(0, (a, b) => a + b) / 7).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.weeklyProgressTitle ?? 'Weekly Progress'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: _openWeekActionsMenu,
            tooltip: AppLocalizations.of(context)?.menu ?? 'Menu',
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'export_csv') {
                await _exportWeekCsv();
              } else if (v == 'download_csv') {
                if (kIsWeb) _downloadWeekCsv();
              } else if (v == 'import_csv') {
                await _importWeekCsv();
              } else if (v == 'save_week_tpl') {
                _promptSaveWeekTemplate();
              } else if (v == 'apply_week_tpl') {
                _promptApplyWeekTemplate();
              } else if (v == 'duplicate_week') {
                await _promptDuplicateWeek();
              } else if (v == 'duplicate_week_to') {
                await _promptDuplicateWeekToDate();
              } else if (v == 'install_pwa') {
                await _promptInstallPwa();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'export_csv', child: Text(AppLocalizations.of(context)?.exportCsv ?? 'Export CSV')),
              if (kIsWeb)
                PopupMenuItem(
                    value: 'download_csv', child: Text(AppLocalizations.of(context)?.downloadCsv ?? 'Download CSV')),
              PopupMenuItem(
                  value: 'import_csv', child: Text(AppLocalizations.of(context)?.importCsv ?? 'Import CSV')),
              const PopupMenuDivider(),
              PopupMenuItem(
                  value: 'save_week_tpl',
                  child: Text(AppLocalizations.of(context)?.saveWeekAsTemplate ?? 'Save week as template')),
              PopupMenuItem(
                  value: 'apply_week_tpl',
                  child: Text(AppLocalizations.of(context)?.applyWeekTemplate ?? 'Apply week template')),
              PopupMenuItem(
                  value: 'duplicate_week',
                  child: Text(AppLocalizations.of(context)?.duplicateWeekNext ?? 'Duplicate week → next')),
              PopupMenuItem(
                  value: 'duplicate_week_to',
                  child: Text(AppLocalizations.of(context)?.duplicateWeekPickDate ?? 'Duplicate week → pick date')),
              if (kIsWeb)
                PopupMenuItem(
                  value: 'install_pwa',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)?.installApp ?? 'Install app'),
                      FutureBuilder<bool>(
                        future: _canInstallPwa(),
                        builder: (context, snap) {
                          final ok = snap.data == true;
                          return Icon(
                            ok ? Icons.check_circle : Icons.hourglass_bottom,
                            size: 16,
                            color: ok
                                ? context.semanticColors.success
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeWeek(-1),
                      icon: const Icon(Icons.chevron_left),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    Expanded(
                      child: Text(
                        _weekRangeLabel(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeWeek(1),
                      icon: const Icon(Icons.chevron_right),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Summary cards
                Row(
                  children: [
                    _summaryCard(
                        'Calorias (semana)',
                        '$totalCalWeek kcal',
                        Theme.of(context).colorScheme.primary),
                    SizedBox(width: 3.w),
                    _summaryCard('Média diária', '$avgCal kcal',
                        context.semanticColors.success),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    _summaryCard('Água (semana)', '${totalWaterWeek} ml',
                        Theme.of(context).colorScheme.primary),
                    SizedBox(width: 3.w),
                    _summaryCard(
                        'Exercício (semana)',
                        '${totalExerciseWeek} kcal',
                        context.semanticColors.warning),
                  ],
                ),

                SizedBox(height: 3.h),

                // Calories bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)?.caloriesPerDay ?? 'Calories per day',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600)),
                    if (_weeklyHasNew.any((e) => e))
                      Text(
                        AppLocalizations.of(context)?.daysWithNew(_weeklyHasNew.where((e) => e).length) ?? '${_weeklyHasNew.where((e) => e).length} day(s) with new items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                _bars(
                  _weeklyCalories,
                  _dailyCalorieGoal,
                  Theme.of(context).colorScheme.primary,
                  highlightMode: 'over',
                  mark: _weeklyHasNew,
                ),

                SizedBox(height: 3.h),

                // Per-meal averages section
                Text(
                    AppLocalizations.of(context)?.perMealAverages ??
                        'Per-meal averages (kcal/day)',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                _perMealAverages(),

                SizedBox(height: 3.h),

                // Macros averages
                Text(
                    AppLocalizations.of(context)?.weeklyMacroAverages ??
                        'Weekly macro averages',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 3.w,
                  runSpacing: 1.h,
                  children: [
                    _summaryCard(
                        AppLocalizations.of(context)?.carbsAvg ??
                            'Carbs (avg)',
                        '${avgCarbs} g',
                        context.semanticColors.warning),
                    _summaryCard(
                        AppLocalizations.of(context)?.proteinAvg ??
                            'Protein (avg)',
                        '${avgProteins} g',
                        context.semanticColors.success),
                    _summaryCard(
                        AppLocalizations.of(context)?.fatAvg ?? 'Fat (avg)',
                        '${avgFats} g',
                        Theme.of(context).colorScheme.primary),
                  ],
                ),

                SizedBox(height: 3.h),

                // Water bars
                Text(AppLocalizations.of(context)?.waterPerDay ?? 'Water per day',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                _bars(
                  _weeklyWater,
                  _waterGoalMl,
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.6),
                  highlightMode: 'under',
                ),

                SizedBox(height: 3.h),

                // Exercise bars
                Text(
                    AppLocalizations.of(context)?.exercisePerDay ??
                        'Exercise per day',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                _bars(_weeklyExercise, 0, context.semanticColors.warning,
                    highlightMode: 'none'),

                SizedBox(height: 3.h),

                // Daily summary table
                Text(AppLocalizations.of(context)?.dailySummary ?? 'Daily summary',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                _dailySummaryTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWeekActionsMenu() {
    showModalBottomSheet(
      context: context,
      // Use themed elevated surface for sheet background
      backgroundColor:
          Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                    AppLocalizations.of(context)?.weekActions ?? 'Week actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 1.5.h),
                _sheetAction('Export CSV', Icons.upload_outlined, () async {
                  Navigator.pop(context);
                  await _exportWeekCsv();
                }),
                if (kIsWeb)
                  _sheetAction('Download CSV', Icons.download_outlined, () {
                    Navigator.pop(context);
                    _downloadWeekCsv();
                  }),
                _sheetAction('Import CSV', Icons.file_upload_outlined,
                    () async {
                  Navigator.pop(context);
                  await _importWeekCsv();
                }),
                const Divider(),
                _sheetAction(
                    'Salvar semana como template', Icons.bookmark_border, () {
                  Navigator.pop(context);
                  _promptSaveWeekTemplate();
                }),
                _sheetAction('Aplicar template de semana', Icons.bookmarks,
                    () async {
                  Navigator.pop(context);
                  await _promptApplyWeekTemplate();
                }),
                _sheetAction('Duplicar semana → próxima', Icons.copy_all,
                    () async {
                  Navigator.pop(context);
                  await _promptDuplicateWeek();
                }),
                _sheetAction('Duplicar semana → escolher data', Icons.event,
                    () async {
                  Navigator.pop(context);
                  await _promptDuplicateWeekToDate();
                }),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      onTap: onTap,
    );
  }

  Future<void> _exportWeekCsv() async {
    final csv = _buildWeekCsv();
    await Clipboard.setData(ClipboardData(text: csv));
    if (!kIsWeb) {
      await Share.share(csv,
          subject: _defaultCsvFilename(), sharePositionOrigin: Rect.zero);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.weekCsvCopied ?? 'Week CSV copied/shared'),
        backgroundColor: context.semanticColors.success,
      ),
    );
  }

  String _buildWeekCsv() {
    final int weekday = _anchorDate.weekday;
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final buffer = StringBuffer();
    buffer.writeln(
        'date,calories,water_ml,exercise_kcal,carbs_g,proteins_g,fats_g');
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      String two(int v) => v.toString().padLeft(2, '0');
      final dateStr = '${day.year}-${two(day.month)}-${two(day.day)}';
      final cal = _weeklyCalories.length > i ? _weeklyCalories[i] : 0;
      final water = _weeklyWater.length > i ? _weeklyWater[i] : 0;
      final ex = _weeklyExercise.length > i ? _weeklyExercise[i] : 0;
      final c = _weeklyCarbs.length > i ? _weeklyCarbs[i] : 0;
      final p = _weeklyProteins.length > i ? _weeklyProteins[i] : 0;
      final f = _weeklyFats.length > i ? _weeklyFats[i] : 0;
      buffer.writeln('$dateStr,$cal,$water,$ex,$c,$p,$f');
    }
    return buffer.toString();
  }

  void _downloadWeekCsv() {
    final defaultName = _defaultCsvFilename();
    final controller = TextEditingController(text: defaultName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)?.fileName ?? 'File name',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.fileHint ?? 'file.csv',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              final csv = _buildWeekCsv();
              var name = controller.text.trim();
              if (name.isEmpty) name = defaultName;
              if (!name.toLowerCase().endsWith('.csv')) name = '$name.csv';
              await downloadCsvFile(name, csv);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }

  String _defaultCsvFilename() {
    String two(int v) => v.toString().padLeft(2, '0');
    final int weekday = _anchorDate.weekday;
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final DateTime sunday = monday.add(const Duration(days: 6));
    final start = '${monday.year}-${two(monday.month)}-${two(monday.day)}';
    final end = '${sunday.year}-${two(sunday.month)}-${two(sunday.day)}';
    return 'nutritracker_week_${start}_to_${end}.csv';
  }

  Future<void> _importWeekCsv() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text('Importar CSV da semana',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface)),
        content: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText:
                      'date,calories,water_ml,exercise_kcal,carbs_g,proteins_g,fats_g\n2025-01-01,1800,2000,150,230,120,60',
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
                    label: const Text('Escolher arquivo (.csv)'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              final csv = controller.text.trim();
              final imported = await _applyCsv(csv);
              if (!mounted) return;
              Navigator.pop(context);
              await _loadWeek();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Importado ${imported} dia(s) desta semana'),
                  backgroundColor: context.semanticColors.success,
                ),
              );
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  Future<int> _applyCsv(String csv) async {
    if (csv.isEmpty) return 0;
    final lines =
        csv.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return 0;
    int startIdx = 0;
    final header = lines.first.toLowerCase();
    if (header.contains('date') && header.contains('calories')) {
      startIdx = 1; // skip header
    }
    // Determine week range
    final int weekday = _anchorDate.weekday;
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final DateTime sunday = monday.add(const Duration(days: 6));

    int imported = 0;
    for (int i = startIdx; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 7) continue;
      try {
        final dateStr = parts[0].trim();
        final d = DateTime.parse(dateStr);
        final date = DateTime(d.year, d.month, d.day);
        if (date.isBefore(monday) || date.isAfter(sunday)) {
          continue; // ignore out of current week
        }
        final calories = int.tryParse(parts[1].trim()) ?? 0;
        final water = int.tryParse(parts[2].trim()) ?? 0;
        final exercise = int.tryParse(parts[3].trim()) ?? 0;
        final carbs = int.tryParse(parts[4].trim()) ?? 0;
        final protein = int.tryParse(parts[5].trim()) ?? 0;
        final fat = int.tryParse(parts[6].trim()) ?? 0;

        // Apply water and exercise totals
        await NutritionStorage.setWaterMl(date, water);
        await NutritionStorage.setExerciseCalories(date, exercise);

        // Remove previous csv_import entries
        final entries = await NutritionStorage.getEntriesForDate(date);
        for (final e in entries) {
          if ((e['source'] as String?) == 'csv_import') {
            await NutritionStorage.removeEntryById(date, e['id']);
          }
        }

        // Add a summary entry representing daily totals
        final summary = <String, dynamic>{
          'id': DateTime.now().millisecondsSinceEpoch,
          'name': 'CSV Import',
          'calories': calories,
          'carbs': carbs,
          'protein': protein,
          'fat': fat,
          'quantity': 1.0,
          'serving': 'dia',
          'mealTime': 'snack',
          'createdAt': DateTime.now().toIso8601String(),
          'source': 'csv_import',
        };
        await NutritionStorage.addEntry(date, summary);
        imported += 1;
      } catch (_) {
        // skip malformed row
      }
    }
    return imported;
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            SizedBox(height: 0.5.h),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _bars(List<int> values, int goal, Color color,
      {String highlightMode = 'none', List<bool>? mark}) {
    final labels = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final cap =
        goal <= 0 ? (values.fold<int>(0, (m, v) => v > m ? v : m)) : goal;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = values.length > i ? values[i] : 0;
          final ratio = cap == 0 ? 0.0 : (v / cap).clamp(0.0, 1.0);
          final bool over = goal > 0 && v > goal;
          final bool under = goal > 0 && v < goal;
          final bool highlight = highlightMode == 'over'
              ? over
              : highlightMode == 'under'
                  ? under
                  : false;
          final barColor =
              highlight ? Theme.of(context).colorScheme.error : color;
          final isMarked = mark != null && mark.length > i && mark[i];
          final double delay = (_kBarStaggerFrac * i).clamp(0.0, 0.5);
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey('bar_${i}_${v}_${cap}'),
                  tween: Tween<double>(begin: 0, end: ratio),
                  duration: _kAnimDuration,
                  curve: Curves.linear,
                  builder: (context, val, _) {
                    if (ratio <= 0) {
                      return Container(
                        height: 0,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }
                    final p = (val / ratio).clamp(0.0, 1.0);
                    final delayed = p <= delay ? 0.0 : (p - delay) / (1.0 - delay);
                    final eased = _kAnimCurve.transform(delayed);
                    final h = 18.h * (eased * ratio);
                    return Container(
                      height: h,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
                SizedBox(height: 0.6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      labels[i],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    if (isMarked) ...[
                      SizedBox(width: 1.w),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _perMealAverages() {
    Color colorFor(String meal) {
      switch (meal) {
        case 'breakfast':
          return context.semanticColors.warning;
        case 'lunch':
          return context.semanticColors.success;
        case 'dinner':
          return Theme.of(context).colorScheme.primary;
        default:
          return context.semanticColors.premium;
      }
    }

    Widget item(String label, String key, int index) {
      final avg = _mealAvgKcal[key] ?? 0;
      final goal = _mealGoals[key]?.kcal ?? 0;
      final ratio = goal <= 0 ? 0.0 : (avg / goal).clamp(0.0, 1.0);
      final baseColor = colorFor(key);
      final over = goal > 0 && avg > goal;
      final color = over ? Theme.of(context).colorScheme.error : baseColor;
      final double delay = (_kBarStaggerFrac * index).clamp(0.0, 0.5);
      return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ??
                Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              SizedBox(height: 0.4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey('meal_avg_${key}_$avg'),
                    tween: Tween<double>(begin: 0, end: avg.toDouble()),
                    duration: _kAnimDuration,
                    curve: Curves.linear,
                    builder: (context, v, _) {
                      if (avg <= 0) {
                        return Text(
                          goal > 0 ? '0/$goal kcal' : '0 kcal',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      }
                      final p = (v / avg).clamp(0.0, 1.0);
                      final delayed = p <= delay ? 0.0 : (p - delay) / (1.0 - delay);
                      final eased = _kAnimCurve.transform(delayed);
                      final shown = (avg * eased).toInt();
                      return Text(
                        goal > 0 ? '$shown/$goal kcal' : '$shown kcal',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      );
                    },
                  ),
                  if (over)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.overGoal ?? 'Over goal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 0.6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('meal_bar_${key}_$ratio'),
                  tween: Tween<double>(begin: 0, end: ratio),
                  duration: _kAnimDuration,
                  curve: Curves.linear,
                  builder: (context, val, _) {
                    if (ratio <= 0) {
                      return LinearProgressIndicator(
                        value: 0,
                        minHeight: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        color: color,
                      );
                    }
                    final p = (val / ratio).clamp(0.0, 1.0);
                    final delayed = p <= delay ? 0.0 : (p - delay) / (1.0 - delay);
                    final eased = _kAnimCurve.transform(delayed);
                    return LinearProgressIndicator(
                      value: eased * ratio,
                      minHeight: 8,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      color: color,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        item(t?.mealBreakfast ?? 'Breakfast', 'breakfast', 0),
        item(t?.mealLunch ?? 'Lunch', 'lunch', 1),
        item(t?.mealDinner ?? 'Dinner', 'dinner', 2),
        item(t?.mealSnack ?? 'Snack', 'snack', 3),
      ],
    );
            
  }

  Widget _dailySummaryTable() {
    String two(int v) => v.toString().padLeft(2, '0');
    final int weekday = _anchorDate.weekday;
    final DateTime monday = _anchorDate.subtract(Duration(days: (weekday - 1)));
    final labels = [
      AppLocalizations.of(context)?.hdrDate ?? 'Date',
      'Kcal',
      AppLocalizations.of(context)?.hdrWater ?? 'Water',
      AppLocalizations.of(context)?.hdrExercise ?? 'Exer.',
      AppLocalizations.of(context)?.hdrCarb ?? 'Carb',
      AppLocalizations.of(context)?.hdrProt ?? 'Prot',
      AppLocalizations.of(context)?.hdrFat ?? 'Fat',
    ];
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final h in labels)
                Expanded(
                  child: Text(
                    h,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 0.8.h),
          // Rows
          for (int i = 0; i < 7; i++)
            InkWell(
              onTap: () {
                final d = monday.add(Duration(days: i));
                _openDayModal(d);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        () {
                          final d = monday.add(Duration(days: i));
                          return '${two(d.day)}/${two(d.month)}';
                        }(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        (_weeklyCalories.length > i ? _weeklyCalories[i] : 0)
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ((_weeklyWater.length > i ? _weeklyWater[i] : 0))
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ((_weeklyExercise.length > i ? _weeklyExercise[i] : 0))
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ((_weeklyCarbs.length > i ? _weeklyCarbs[i] : 0))
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ((_weeklyProteins.length > i ? _weeklyProteins[i] : 0))
                            .toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ((_weeklyFats.length > i ? _weeklyFats[i] : 0))
                            .toString(),
                        style: AppTheme.darkTheme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDayModal(DateTime day) async {
    final entries = await NutritionStorage.getEntriesForDate(day);
    if (!mounted) return;
    final totalKcal = entries.fold<int>(
        0, (sum, e) => sum + ((e['calories'] as num?)?.toInt() ?? 0));
    final waterMl = await NutritionStorage.getWaterMl(day);
    final exKcal = await NutritionStorage.getExerciseCalories(day);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Registros de ${day.day}/${day.month}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Total: $totalKcal kcal | Água: ${waterMl} ml | Exercício: ${exKcal} kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.5.h),
              FutureBuilder<int>(
                future: UserPreferences.getNewBadgeMinutes(),
                builder: (context, snap) {
                  final mins = snap.data ?? 5;
                  final hl = Duration(minutes: mins);
                  return StatefulBuilder(
                    builder: (context, setStateFilter) {
                      bool showOnlyNew = false;
                      // Persist local state within the StatefulBuilder closure
                      // using a closure variable captured by a ValueNotifier-like
                      // trick: convert to map to avoid reinit; simpler: use a local static
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              StatefulBuilder(builder: (context, setRow) {
                                return Row(
                                  children: [
                                    Text('Somente novos',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            )),
                                    SizedBox(width: 1.w),
                                    Switch(
                                      value: showOnlyNew,
                                      onChanged: (v) {
                                        showOnlyNew = v;
                                        setStateFilter(() {});
                                      },
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          for (final e in entries)
                            if (!showOnlyNew || _isEntryNew(e, hl))
                              _entryRowWithHighlight(context, e, hl),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.dailyTrackingDashboard,
                        arguments: {'date': day.toIso8601String()},
                      );
                    },
                    child: Text('Ver dia',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primary)),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final ml =
                              await NutritionStorage.addWaterMl(day, -250);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Água ajustada: -250ml (total ${ml}ml)'),
                              backgroundColor: context.semanticColors.warning,
                            ),
                          );
                          await _loadWeek();
                          Navigator.pop(context);
                        },
                        child: const Text('-250 ml'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final ml =
                              await NutritionStorage.addWaterMl(day, 250);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Água registrada: +250ml (total ${ml}ml)'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                          await _loadWeek();
                          Navigator.pop(context);
                        },
                        child: const Text('+250 ml'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await NutritionStorage.addExerciseCalories(day, 100);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Exercício registrado: +100 kcal'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                          await _loadWeek();
                          Navigator.pop(context);
                        },
                        child: const Text('+100 kcal'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final ok = await _promptSaveDayTemplate(day);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Template de dia salvo'),
                                backgroundColor: context.semanticColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('Salvar como template'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final minutes =
                              await UserPreferences.getNewBadgeMinutes();
                          final hl = Duration(minutes: minutes);
                          final newEntries =
                              entries.where((e) => _isEntryNew(e, hl)).toList();
                          if (newEntries.isEmpty) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Nenhum item "novo" para duplicar'),
                                backgroundColor: context.semanticColors.warning,
                              ),
                            );
                            return;
                          }
                          // Confirmação com seleção
                          final selected =
                              List<bool>.filled(newEntries.length, true);
                          final gramCtrls =
                              List.generate(newEntries.length, (i) {
                            final s = newEntries[i]['serving'] as String?;
                            final match = s != null
                                ? RegExp(r"(\\d+)\\s*g").firstMatch(s)
                                : null;
                            final g = match != null ? match.group(1) : null;
                            return TextEditingController(text: g ?? '100');
                          });
                          final proceed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Theme.of(context)
                                      .dialogTheme
                                      .backgroundColor ??
                                  Theme.of(context).colorScheme.surface,
                              title: Text('Selecionar itens para duplicar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      )),
                              content: SizedBox(
                                width: 600,
                                child: StatefulBuilder(
                                  builder: (context, setStateSel) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (int i = 0;
                                            i < newEntries.length;
                                            i++)
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: selected[i],
                                                onChanged: (v) => setStateSel(
                                                    () => selected[i] =
                                                        v ?? true),
                                                activeColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (newEntries[i]['name']
                                                              as String?) ??
                                                          '-',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${newEntries[i]['calories']} kcal',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: TextField(
                                                  controller: gramCtrls[i],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'g'),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                      AppLocalizations.of(context)?.cancel ??
                                          'Cancel',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                          if (proceed != true) return;
                          final picked = await _pickTargetDate(initial: day);
                          if (picked == null) return;
                          int dup = 0;
                          for (int i = 0; i < newEntries.length; i++) {
                            if (!selected[i]) continue;
                            final e = Map<String, dynamic>.from(newEntries[i]);
                            // scale by grams if present
                            int newG =
                                int.tryParse(gramCtrls[i].text.trim()) ?? 100;
                            final s = (newEntries[i]['serving'] as String?);
                            final match = s != null
                                ? RegExp(r"(\\d+)\\s*g").firstMatch(s)
                                : null;
                            if (match != null) {
                              final origG = int.tryParse(match.group(1)!) ?? 0;
                              if (origG > 0) {
                                final factor = newG / origG;
                                e['calories'] =
                                    (((e['calories'] as num?)?.toDouble() ??
                                                0) *
                                            factor)
                                        .round();
                                e['carbs'] =
                                    ((e['carbs'] as num?)?.toDouble() ?? 0) *
                                        factor;
                                e['protein'] =
                                    ((e['protein'] as num?)?.toDouble() ?? 0) *
                                        factor;
                                e['fat'] =
                                    ((e['fat'] as num?)?.toDouble() ?? 0) *
                                        factor;
                              }
                            }
                            e['serving'] = '${newG} g';
                            e['id'] =
                                DateTime.now().microsecondsSinceEpoch + dup;
                            e['createdAt'] = DateTime.now().toIso8601String();
                            await NutritionStorage.addEntry(picked, e);
                            dup += 1;
                          }
                          if (!mounted) return;
                          await _loadWeek();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Duplicados ${dup} item(ns) para ${picked.day}/${picked.month}'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                        },
                        child: const Text('Duplicar novos → escolher data'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _promptApplyDayTemplate(day);
                          if (!mounted) return;
                          await _loadWeek();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.templateApplied ?? 'Template applied to day'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                        },
                        child: const Text('Aplicar template'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          // Duplicar dia para amanhã
                          final to = day.add(const Duration(days: 1));
                          await NutritionStorage.duplicateDay(day, to);
                          if (!mounted) return;
                          await _loadWeek();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Dia duplicado para ${to.day}/${to.month}'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)?.duplicateTomorrow ?? 'Duplicate → tomorrow'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await _pickTargetDate(initial: day);
                          if (picked == null) return;
                          await NutritionStorage.duplicateDay(day, picked);
                          if (!mounted) return;
                          await _loadWeek();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Dia duplicado para ${picked.day}/${picked.month}'),
                              backgroundColor: context.semanticColors.success,
                            ),
                          );
                        },
                        child: const Text('Duplicar → escolher data'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final csv = _buildDayCsvFromEntries(day, entries);
                          final def = _defaultDayCsvFilename(day);
                          final controller = TextEditingController(text: def);
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Theme.of(context)
                                      .dialogTheme
                                      .backgroundColor ??
                                  Theme.of(context).colorScheme.surface,
                              title: Text(AppLocalizations.of(context)?.fileName ?? 'File name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)?.fileHint ?? 'file.csv',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      AppLocalizations.of(context)?.cancel ??
                                          'Cancel',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
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
                                      await services.Clipboard.setData(
                                        services.ClipboardData(text: csv),
                                      );
                                    }
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(kIsWeb
                                            ? 'CSV do dia baixado'
                                            : 'CSV do dia copiado'),
                                        backgroundColor:
                                            context.semanticColors.success,
                                      ),
                                    );
                                  },
                                  child: Text(kIsWeb ? 'Baixar' : 'Copiar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Exportar CSV'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final controller = TextEditingController();
                          bool clearBefore = false;
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Theme.of(context)
                                      .dialogTheme
                                      .backgroundColor ??
                                  Theme.of(context).colorScheme.surface,
                              title: Text('Importar CSV do dia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              content: SizedBox(
                                width: 700,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatefulBuilder(
                                        builder: (context, setState) {
                                      return CheckboxListTile(
                                        value: clearBefore,
                                        onChanged: (v) => setState(
                                            () => clearBefore = v ?? false),
                                        title: Text(
                                            'Limpar dia antes de importar',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface)),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                            if (text != null &&
                                                text.isNotEmpty) {
                                              controller.text = text;
                                            }
                                          },
                                          icon: const Icon(Icons.attach_file),
                                          label: const Text(
                                              'Escolher arquivo (.csv)'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      AppLocalizations.of(context)?.cancel ??
                                          'Cancel',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final csv = controller.text.trim();
                                    final n = await _importDayCsv(day, csv,
                                        clearBefore: clearBefore);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    await _loadWeek();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Importado ${n} item(ns) para o dia'),
                                        backgroundColor:
                                            context.semanticColors.success,
                                      ),
                                    );
                                  },
                                  child: const Text('Importar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Importar CSV'),
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

  Future<bool> _promptSaveDayTemplate(DateTime day) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text('Salvar dia como template',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome do template'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
            child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
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
          backgroundColor: context.semanticColors.warning,
        ),
      );
      return;
    }
    bool clearBefore = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text('Aplicar template de dia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface)),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).colorScheme.primary,
                );
              }),
              for (final t in templates)
                ListTile(
                  title: Text(
                    (t['label'] as String?) ?? 'sem nome',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    (t['createdAt'] as String?) ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant),
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
                    color: Theme.of(context).colorScheme.error,
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
            child: Text('Fechar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Future<void> _promptDuplicateWeek() async {
    final toMonday = _anchorDate.add(const Duration(days: 7));
    await NutritionStorage.duplicateWeek(
      _anchorDate.subtract(Duration(days: (_anchorDate.weekday - 1))),
      toMonday.subtract(Duration(days: (toMonday.weekday - 1))),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semana duplicada para a próxima'),
        backgroundColor: context.semanticColors.success,
      ),
    );
  }

  void _promptSaveWeekTemplate() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text('Salvar semana como template',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome do template'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              final label = controller.text.trim();
              if (label.isEmpty) return;
              final int weekday = _anchorDate.weekday;
              final DateTime monday =
                  _anchorDate.subtract(Duration(days: (weekday - 1)));
              await NutritionStorage.saveWeekTemplate(
                label: label,
                monday: monday,
              );
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Template de semana salvo'),
                  backgroundColor: context.semanticColors.success,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _promptApplyWeekTemplate() async {
    final templates = await NutritionStorage.getWeekTemplates();
    if (templates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nenhum template de semana salvo'),
          backgroundColor: context.semanticColors.warning,
        ),
      );
      return;
    }
    bool clearBefore = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        title: Text('Aplicar template de semana',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface)),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(builder: (context, setState) {
                return CheckboxListTile(
                  value: clearBefore,
                  onChanged: (v) => setState(() => clearBefore = v ?? false),
                  title: Text('Limpar semana antes de aplicar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).colorScheme.primary,
                );
              }),
              for (final t in templates)
                ListTile(
                  title: Text(
                    (t['label'] as String?) ?? 'sem nome',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    (t['createdAt'] as String?) ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  onTap: () async {
                    final int weekday = _anchorDate.weekday;
                    final DateTime monday =
                        _anchorDate.subtract(Duration(days: (weekday - 1)));
                    if (clearBefore) {
                      await NutritionStorage.clearWeekFully(monday);
                    }
                    await NutritionStorage.applyWeekTemplateOnMonday(
                      template: t,
                      monday: monday,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                    await _loadWeek();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Template de semana aplicado'),
                        backgroundColor: context.semanticColors.success,
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () async {
                      await NutritionStorage.removeWeekTemplate(t['id']);
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _promptApplyWeekTemplate();
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Future<void> _promptDuplicateWeekToDate() async {
    final picked = await _pickTargetDate(
      initial: _anchorDate.add(const Duration(days: 7)),
    );
    if (picked == null) return;
    final fromMonday =
        _anchorDate.subtract(Duration(days: (_anchorDate.weekday - 1)));
    final toMonday = picked.subtract(Duration(days: (picked.weekday - 1)));
    await NutritionStorage.duplicateWeek(fromMonday, toMonday);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Semana duplicada para iniciar em ${toMonday.day}/${toMonday.month}'),
        backgroundColor: context.semanticColors.success,
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
                primary: Theme.of(context).colorScheme.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return DateTime(picked.year, picked.month, picked.day);
  }

  // JS interop shim – definido no index.html quando possível
  static Future<void> _invokeInstallPrompt() async {
    // Use JS interop via platform view channel fallback
    // ignore: undefined_prefixed_name
    final installed = await services.SystemChannels.platform
        .invokeMethod('BrowserAppInstall#install');
    if (installed != true) {
      throw Exception('Install prompt not available');
    }
  }

  Future<bool> _canInstallPwa() async {
    if (!kIsWeb) return false;
    try {
      // Poll via JS flag exposed in index.html
      // ignore: undefined_prefixed_name
      final result = await services.SystemChannels.platform
          .invokeMethod('BrowserAppInstall#canInstall');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _promptInstallPwa() async {
    if (!kIsWeb) return;
    // Tenta chamar a API de instalação via JS
    // Ignora falhas silenciosamente se o evento não estiver disponível
    // A UI do navegador exibirá o prompt quando suportado
    try {
      // ignore: undefined_prefixed_name
      await _invokeInstallPrompt();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Para instalar: Use o menu do navegador → "Instalar aplicativo"'),
          backgroundColor: context.semanticColors.warning,
        ),
      );
    }
  }

  String _defaultDayCsvFilename(DateTime day) {
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${day.year}-${two(day.month)}-${two(day.day)}';
    return 'nutritracker_day_$date.csv';
  }

  String _buildDayCsvFromEntries(
      DateTime day, List<Map<String, dynamic>> entries) {
    final buffer = StringBuffer();
    buffer.writeln('name,meal,kcal,carbs,proteins,fats,quantity,serving');
    for (final e in entries) {
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
        // skip malformed
      }
    }
    return imported;
  }
}
