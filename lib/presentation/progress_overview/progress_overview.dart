import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';
import '../daily_tracking_dashboard/widgets/weekly_progress_widget.dart';
import '../../services/user_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ProgressOverviewScreen extends StatefulWidget {
  const ProgressOverviewScreen({super.key});

  @override
  State<ProgressOverviewScreen> createState() => _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends State<ProgressOverviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  String _range = 'week'; // week | month
  int _currentWeek = 32;
  List<int> _weeklyCalories = const [0, 0, 0, 0, 0, 0, 0];
  List<int> _weeklyWater = const [0, 0, 0, 0, 0, 0, 0];
  int _dailyGoal = 2000;
  int _waterGoal = 2000;
  // Dados mensais mock (30 dias)
  late DateTime _month;
  late List<int> _monthCalories;
  Map<String, double> _monthMacros = const {'Carb': 0, 'Prot': 0, 'Gord': 0};
  Map<String, double> _monthMacroGrams = const {'Carb': 0, 'Prot': 0, 'Gord': 0};
  Map<String, double> _weekMacros = const {'Carb': 0, 'Prot': 0, 'Gord': 0};
  Map<String, double> _weekMacroGrams = const {'Carb': 0, 'Prot': 0, 'Gord': 0};
  int? _weekPieTouched;
  int? _monthPieTouched;
  late DateTime _weekMonday;
  Map<String, double> _macroGoalDaily = const {'Carb': 0, 'Prot': 0, 'Gord': 0};
  int _weeklySum = 0;
  int _monthSum = 0;

  // Helpers for weekly chart Y-axis
  double _calcWeekYMax() {
    int maxVal = _dailyGoal;
    for (final v in _weeklyCalories) {
      if (v > maxVal) maxVal = v;
    }
    // Round up to nearest 200 and add a small headroom
    final rounded = ((maxVal + 100) / 200).ceil() * 200;
    return rounded.toDouble();
  }

  double _calcWeekYMin() => 0.0;

  double _calcWeekYStep() {
    final maxY = _calcWeekYMax();
    // Aim ~5 grid lines
    final step = (maxY / 5).clamp(100, 400);
    // Snap to nearest 100
    return (step / 100).round() * 100.0;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _monthCalories = List<int>.filled(DateUtils.getDaysInMonth(_month.year, _month.month), 0);
    _weekMonday = now.subtract(Duration(days: now.weekday - 1));
    _loadGoalsAndData();
  }

  Future<void> _loadGoalsAndData() async {
    final g = await UserPreferences.getGoals();
    if (mounted) {
      setState(() {
        _dailyGoal = g.totalCalories;
        _waterGoal = g.waterGoalMl;
        _macroGoalDaily = {
          'Carb': g.carbs.toDouble(),
          'Prot': g.proteins.toDouble(),
          'Gord': g.fats.toDouble(),
        };
      });
    }
    await _loadWeek(_weekMonday);
    await _loadMonth(_month);
  }

  List<int> _genMonthCalories(DateTime month) {
    // Gera números pseudo-aleatórios consistentes por mês/ano
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final seed = month.year * 100 + month.month;
    int next = seed;
    int rnd() {
      // Linear congruential generator simples
      next = (next * 1103515245 + 12345) & 0x7fffffff;
      return next;
    }
    return List.generate(days, (i) {
      final base = 1800 + (rnd() % 700); // 1800..2499
      return base;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
    });
    _loadMonth(_month);
  }

  Future<void> _loadWeek(DateTime monday) async {
    final List<int> kcal = [];
    final List<int> water = [];
    double carb = 0, prot = 0, fat = 0;
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(d);
      final sum = entries.fold<int>(0, (s, e) => s + ((e['calories'] as num?)?.toInt() ?? 0));
      for (final e in entries) {
        carb += (e['carbs'] as num?)?.toDouble() ?? 0.0;
        prot += (e['protein'] as num?)?.toDouble() ?? 0.0;
        fat += (e['fat'] as num?)?.toDouble() ?? 0.0;
      }
      final w = await NutritionStorage.getWaterMl(d);
      kcal.add(sum);
      water.add(w);
    }
    if (!mounted) return;
    setState(() {
      _weeklyCalories = kcal;
      _weeklyWater = water;
      final total = carb + prot + fat;
      _weekMacros = total > 0
          ? {
              'Carb': (carb / total) * 100,
              'Prot': (prot / total) * 100,
              'Gord': (fat / total) * 100,
            }
          : const {'Carb': 0, 'Prot': 0, 'Gord': 0};
      _weekMacroGrams = {'Carb': carb, 'Prot': prot, 'Gord': fat};
      _weeklySum = kcal.fold<int>(0, (s, v) => s + v);
    });
  }

  Future<void> _loadMonth(DateTime month) async {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final List<int> cals = List.filled(days, 0);
    double carb = 0, prot = 0, fat = 0;
    for (int i = 0; i < days; i++) {
      final d = DateTime(month.year, month.month, i + 1);
      final entries = await NutritionStorage.getEntriesForDate(d);
      int sum = 0;
      for (final e in entries) {
        sum += (e['calories'] as num?)?.toInt() ?? 0;
        carb += (e['carbs'] as num?)?.toDouble() ?? 0.0;
        prot += (e['protein'] as num?)?.toDouble() ?? 0.0;
        fat += (e['fat'] as num?)?.toDouble() ?? 0.0;
      }
      cals[i] = sum;
    }
    final totalMacro = (carb + prot + fat);
    final Map<String, double> macros;
    if (totalMacro > 0) {
      macros = {
        'Carb': (carb / totalMacro) * 100,
        'Prot': (prot / totalMacro) * 100,
        'Gord': (fat / totalMacro) * 100,
      };
    } else {
      macros = {'Carb': 0, 'Prot': 0, 'Gord': 0};
    }
    if (!mounted) return;
    setState(() {
      _monthCalories = cals;
      _monthMacros = macros;
      _monthMacroGrams = {'Carb': carb, 'Prot': prot, 'Gord': fat};
      _monthSum = cals.fold<int>(0, (s, v) => s + v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        title: const Text('Progresso'),
        actions: [
          IconButton(
            tooltip: 'Exportar/Compartilhar',
            icon: const Icon(Icons.ios_share),
            onPressed: _exportProgress,
          ),
        ],
      ),
      body: SafeArea(
        child: RepaintBoundary(
          key: _repaintKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _rangeChip('week', 'Semana'),
                    _rangeChip('month', 'Mês'),
                  ],
                ),
              ),

              // Weekly/Monthly progress
              if (_range == 'week')
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _weekMonday = _weekMonday.subtract(const Duration(days: 7)));
                              _loadWeek(_weekMonday);
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            _formatWeek(_weekMonday),
                            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            onPressed: _canGoNextWeek()
                                ? () {
                                    setState(() => _weekMonday = _weekMonday.add(const Duration(days: 7)));
                                    _loadWeek(_weekMonday);
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    WeeklyProgressWidget(
                      currentWeek: _currentWeek,
                      onWeekChanged: (w) => setState(() => _currentWeek = w),
                      weeklyCalories: _weeklyCalories,
                      dailyGoal: _dailyGoal,
                      weeklyWater: _weeklyWater,
                      waterGoalMl: _waterGoal,
                    ),
                    // Barras por dia (semana)
                    SizedBox(height: 1.2.h),
                    _sectionCard(
                      title: 'Calorias por dia (semana)',
                      icon: Icons.calendar_view_day,
                      child: SizedBox(
                        height: 20.h,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: AppTheme.dividerGray.withValues(alpha: 0.4),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  interval: _calcWeekYStep(),
                                  getTitlesWidget: (v, meta) => Text(
                                    '${v.toInt()}',
                                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                                    final i = v.toInt();
                                    return i >= 0 && i < labels.length
                                        ? Text(labels[i], style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary))
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              final v = (_weeklyCalories.length > i ? _weeklyCalories[i] : 0).toDouble();
                              final exceeded = v > _dailyGoal.toDouble();
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: v,
                                    color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                                    width: 10,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _dailyGoal.toDouble(),
                                      color: AppTheme.activeBlue.withValues(alpha: 0.12),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: AppTheme.primaryBackgroundDark.withValues(alpha: 0.9),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                                  final day = (group.x >= 0 && group.x < labels.length) ? labels[group.x] : 'Dia';
                                  return BarTooltipItem(
                                    '$day\n',
                                    AppTheme.darkTheme.textTheme.labelLarge!.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
                                    children: [
                                      TextSpan(
                                        text: '${rod.toY.toInt()} kcal',
                                        style: AppTheme.darkTheme.textTheme.bodySmall!.copyWith(color: AppTheme.activeBlue, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.0.h),
                    _sectionCard(
                      title: 'Resumo (semana)',
                      icon: Icons.calendar_today_outlined,
                      child: Builder(builder: (context) {
                        final weekGoal = _dailyGoal * 7;
                        final remain = weekGoal - _weeklySum;
                        final exceeded = remain < 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _summaryChip(
                              label: 'Meta diária',
                              value: '$_dailyGoal kcal',
                              color: AppTheme.textSecondary,
                            ),
                            _summaryChip(
                              label: 'Semana',
                              value: '$_weeklySum/$weekGoal kcal',
                              color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                            ),
                            _summaryChip(
                              label: exceeded ? 'Excesso' : 'Restante',
                              value: exceeded ? '${(_weeklySum - weekGoal)} kcal' : '${remain} kcal',
                              color: exceeded ? AppTheme.errorRed : AppTheme.textSecondary,
                            ),
                            if (exceeded)
                              _exceededBadge(),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: 1.2.h),
                    _sectionCard(
                      title: 'Distribuição de Macros (semana)',
                      icon: Icons.pie_chart_outline,
                      child: SizedBox(
                        height: 22.h,
                        child: Row(
                          children: [
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 1,
                                  centerSpaceRadius: 30,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, resp) {
                                      setState(() => _weekPieTouched = resp?.touchedSection?.touchedSectionIndex);
                                    },
                                  ),
                                  sections: List.generate(3, (i) {
                                    final keys = ['Carb', 'Prot', 'Gord'];
                                    final colors = [AppTheme.warningAmber, AppTheme.successGreen, AppTheme.activeBlue];
                                    final val = _weekMacros[keys[i]] ?? 0;
                                    final isTouched = _weekPieTouched == i;
                                    return PieChartSectionData(
                                      value: val,
                                      color: colors[i],
                                      radius: isTouched ? 46 : 40,
                                      title: '${val.toStringAsFixed(0)}% ',
                                      titleStyle: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textPrimary),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            _macroLegend(
                              dataPct: _weekMacros,
                              dataGrams: _weekMacroGrams,
                              goalGrams: _goalGramsForDays(7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                _monthlySection(),

              SizedBox(height: 1.6.h),

              // Line chart for calories trend
              _sectionCard(
                title: 'Tendência de Calorias',
                icon: Icons.show_chart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        label: Text('Meta diária: $_dailyGoal kcal'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppTheme.secondaryBackgroundDark,
                        shape: StadiumBorder(
                          side: BorderSide(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                        ),
                        labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ),
                    SizedBox(
                      height: 22.h,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: AppTheme.primaryBackgroundDark.withValues(alpha: 0.9),
                              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                                final x = s.x.toInt();
                                final kcal = s.y.toInt();
                                const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                                final day = (x >= 0 && x < labels.length) ? labels[x] : 'Dia';
                                return LineTooltipItem(
                                  '$day\n',
                                  AppTheme.darkTheme.textTheme.labelLarge!.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
                                  children: [
                                    TextSpan(
                                      text: '$kcal kcal',
                                      style: AppTheme.darkTheme.textTheme.bodySmall!.copyWith(color: AppTheme.activeBlue, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          gridData: FlGridData(show: true, drawVerticalLine: false,
                              horizontalInterval: 200,
                              getDrawingHorizontalLine: (v) => FlLine(
                                    color: AppTheme.dividerGray.withValues(alpha: 0.4),
                                    strokeWidth: 1,
                                  )),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, interval: 200, reservedSize: 36,
                                getTitlesWidget: (v, meta) => Text('${v.toInt()}',
                                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                                  final idx = v.toInt();
                                  return idx >= 0 && idx < labels.length
                                      ? Text(labels[idx], style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary))
                                      : const SizedBox.shrink();
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                           minY: _calcWeekYMin(),
                           maxY: _calcWeekYMax(),
                           lineBarsData: [
                             LineChartBarData(
                               spots: List.generate(_weeklyCalories.length, (i) => FlSpot(i.toDouble(), _weeklyCalories[i].toDouble())),
                               isCurved: true,
                               color: AppTheme.activeBlue,
                               barWidth: 3,
                               dotData: FlDotData(
                                 show: true,
                                 getDotPainter: (spot, percent, barData, index) {
                                   final above = spot.y > _dailyGoal;
                                   return FlDotCirclePainter(
                                     radius: 3,
                                     color: above ? AppTheme.errorRed : AppTheme.activeBlue,
                                     strokeWidth: 0,
                                   );
                                 },
                               ),
                               belowBarData: BarAreaData(show: true, color: AppTheme.activeBlue.withValues(alpha: 0.12)),
                             ),
                             LineChartBarData(
                               spots: List.generate(7, (i) => FlSpot(i.toDouble(), _dailyGoal.toDouble())),
                               isCurved: false,
                               color: AppTheme.dividerGray.withValues(alpha: 0.6),
                               barWidth: 1.5,
                               dashArray: [6, 4],
                               dotData: FlDotData(show: false),
                             ),
                           ],
                         ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.2.h),

              // (weekly pie moved above)
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _rangeChip(String key, String label) {
    final selected = _range == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _range = key),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: selected ? AppTheme.activeBlue : AppTheme.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: AppTheme.secondaryBackgroundDark,
      selectedColor: AppTheme.activeBlue.withValues(alpha: 0.12),
      shape: StadiumBorder(
        side: BorderSide(
          color: (selected ? AppTheme.activeBlue : AppTheme.dividerGray).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.0.h),
          child,
        ],
      ),
    );
  }

  Widget _monthlyPlaceholder() {
    // não usado mais
    return const SizedBox.shrink();
  }

  Widget _monthlySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _formatMonth(_month),
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: _canGoNextMonth() ? () => _changeMonth(1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Resumo mensal
        _sectionCard(
          title: 'Resumo (mês)',
          icon: Icons.calendar_month_outlined,
          child: Builder(builder: (context) {
            final days = DateUtils.getDaysInMonth(_month.year, _month.month);
            final goal = _dailyGoal * days;
            final remain = goal - _monthSum;
            final exceeded = remain < 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryChip(
                  label: 'Meta diária',
                  value: '$_dailyGoal kcal',
                  color: AppTheme.textSecondary,
                ),
                _summaryChip(
                  label: 'Mês',
                  value: '$_monthSum/$goal kcal',
                  color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                ),
                _summaryChip(
                  label: exceeded ? 'Excesso' : 'Restante',
                  value: exceeded ? '${(_monthSum - goal)} kcal' : '${remain} kcal',
                  color: exceeded ? AppTheme.errorRed : AppTheme.textSecondary,
                ),
                if (exceeded)
                  _exceededBadge(),
              ],
            );
          }),
        ),
        // Barras por dia do mês
        _sectionCard(
          title: 'Calorias por dia (mês)',
          icon: Icons.calendar_view_month,
          child: SizedBox(
            height: 22.h,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                          color: AppTheme.dividerGray.withValues(alpha: 0.4),
                          strokeWidth: 1,
                        )),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36, interval: 500,
                        getTitlesWidget: (v, meta) => Text('${v.toInt()}',
                            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 7,
                        getTitlesWidget: (v, meta) {
                          final d = v.toInt() + 1;
                          if (d == 1 || d == 8 || d == 15 || d == 22 || d == 29) {
                            return Text('$d', style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary));
                          }
                          return const SizedBox.shrink();
                        }),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_monthCalories.length, (i) {
                  final v = _monthCalories[i].toDouble();
                  final exceeded = v > _dailyGoal.toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v,
                        color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                        width: 6,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        rodStackItems: [],
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _dailyGoal.toDouble(),
                          color: AppTheme.activeBlue.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  );
                }),
                alignment: BarChartAlignment.spaceBetween,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.primaryBackgroundDark.withValues(alpha: 0.9),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = group.x + 1;
                      return BarTooltipItem(
                        'Dia $day\n',
                        AppTheme.darkTheme.textTheme.labelLarge!.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} kcal',
                            style: AppTheme.darkTheme.textTheme.bodySmall!.copyWith(color: AppTheme.activeBlue, fontWeight: FontWeight.w700),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 1.2.h),

        _sectionCard(
          title: 'Distribuição de Macros (mês)',
          icon: Icons.pie_chart_outline,
          child: SizedBox(
            height: 22.h,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 1,
                      centerSpaceRadius: 30,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, resp) {
                          setState(() => _monthPieTouched = resp?.touchedSection?.touchedSectionIndex);
                        },
                      ),
                      sections: [
                        PieChartSectionData(value: _monthMacros['Carb'] ?? 0, color: AppTheme.warningAmber, title: '${(_monthMacros['Carb'] ?? 0).toStringAsFixed(0)}%', titleStyle: AppTheme.darkTheme.textTheme.labelSmall, radius: _monthPieTouched == 0 ? 46 : 40),
                        PieChartSectionData(value: _monthMacros['Prot'] ?? 0, color: AppTheme.successGreen, title: '${(_monthMacros['Prot'] ?? 0).toStringAsFixed(0)}%', titleStyle: AppTheme.darkTheme.textTheme.labelSmall, radius: _monthPieTouched == 1 ? 46 : 40),
                        PieChartSectionData(value: _monthMacros['Gord'] ?? 0, color: AppTheme.activeBlue, title: '${(_monthMacros['Gord'] ?? 0).toStringAsFixed(0)}%', titleStyle: AppTheme.darkTheme.textTheme.labelSmall, radius: _monthPieTouched == 2 ? 46 : 40),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                _macroLegend(
                  dataPct: _monthMacros,
                  dataGrams: _monthMacroGrams,
                  goalGrams: _goalGramsForDays(DateUtils.getDaysInMonth(_month.year, _month.month)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatMonth(DateTime m) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[m.month - 1]} ${m.year}';
  }

  String _formatWeek(DateTime monday) {
    final start = monday;
    final end = monday.add(const Duration(days: 6));
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(start.day)}/${d2(start.month)} - ${d2(end.day)}/${d2(end.month)}';
  }

  bool _canGoNextWeek() {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: DateTime.now().weekday - 1));
    return !_isSameDate(_weekMonday, thisMonday);
  }

  bool _canGoPrevWeek() {
    // optionally always allow going backward; keep true
    return true;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _canGoNextMonth() {
    final now = DateTime.now();
    final cur = DateTime(now.year, now.month, 1);
    return !(_month.year == cur.year && _month.month == cur.month);
  }

  Future<void> _exportProgress() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/progress_overview.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Progresso — ${_range == 'week' ? _formatWeek(_weekMonday) : _formatMonth(_month)}');
    } catch (_) {}
  }

  Widget _summaryChip({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _exceededBadge() {
    return Chip(
      label: const Text('Excedeu'),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: StadiumBorder(
        side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.7)),
      ),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.errorRed,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Map<String, double> _goalGramsForDays(int days) => {
        'Carb': (_macroGoalDaily['Carb'] ?? 0) * days,
        'Prot': (_macroGoalDaily['Prot'] ?? 0) * days,
        'Gord': (_macroGoalDaily['Gord'] ?? 0) * days,
      };

  Widget _macroLegend({
    required Map<String, double> dataPct,
    required Map<String, double> dataGrams,
    Map<String, double>? goalGrams,
  }) {
    TextStyle label = AppTheme.darkTheme.textTheme.bodySmall!;
    Widget row(Color color, String name) {
      final pct = (dataPct[name] ?? 0).toStringAsFixed(0);
      final grams = dataGrams[name] ?? 0;
      String gramsStr = grams > 0 ? ' • ${grams.toStringAsFixed(0)} g' : '';
      if (goalGrams != null) {
        final g = goalGrams[name] ?? 0;
        if (g > 0) gramsStr += ' / ${g.toStringAsFixed(0)} g';
      }
      final exceeded = goalGrams != null && (grams > (goalGrams[name] ?? double.infinity));
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text('$name', style: label.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(width: 6),
            Text('$pct%', style: label.copyWith(color: color, fontWeight: FontWeight.w700)),
            Text(gramsStr, style: label.copyWith(color: exceeded ? AppTheme.errorRed : AppTheme.textSecondary)),
            if (exceeded) ...[
              const SizedBox(width: 6),
              _exceededBadge(),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        row(AppTheme.warningAmber, 'Carb'),
        row(AppTheme.successGreen, 'Prot'),
        row(AppTheme.activeBlue, 'Gord'),
      ],
    );
  }

  // (Removed duplicate _exportProgress method)
}
