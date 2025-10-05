import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';

import '../../core/app_export.dart';
import '../../theme/design_tokens.dart';
import '../../services/streak_service.dart';
import '../../services/nutrition_storage.dart';

class StreakOverviewScreen extends StatefulWidget {
  const StreakOverviewScreen({super.key});

  @override
  State<StreakOverviewScreen> createState() => _StreakOverviewScreenState();
}

class _StreakOverviewScreenState extends State<StreakOverviewScreen> {
  int _current = 0;
  int _longest = 0;
  late DateTime _monday;
  final List<bool> _weekHasLog = List<bool>.filled(7, false);
  bool _loading = true;
  bool _nuxChecked = false;

  @override
  void initState() {
    super.initState();
    _load();
    _maybeShowNux();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: (now.weekday - 1)));
    final cur = await StreakService.currentStreak('food_log');
    final best = await StreakService.longestStreak('food_log', days: 365);
    final week = <bool>[];
    for (int i = 0; i < 7; i++) {
      final d = DateTime(monday.year, monday.month, monday.day)
          .add(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(d);
      week.add(entries.isNotEmpty);
    }
    if (!mounted) return;
    setState(() {
      _current = cur;
      _longest = best;
      _monday = DateTime(monday.year, monday.month, monday.day);
      for (int i = 0; i < 7; i++) {
        _weekHasLog[i] = week[i];
      }
      _loading = false;
    });
  }

  Future<void> _maybeShowNux() async {
    if (_nuxChecked) return;
    _nuxChecked = true;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('streak_overview_nux_seen') ?? false;
    if (!seen && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        _showCoachmark();
      });
    }
  }

  OverlayEntry? _overlay;
  final GlobalKey _weekKey = GlobalKey();

  void _showCoachmark() {
    _overlay?.remove();
    _overlay = null;
    final ctx = _weekKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final target = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.of(context).size;

    const bubbleWidth = 300.0;
    const bubbleHeight = 120.0;
    double left = target.dx + size.width / 2 - bubbleWidth / 2;
    left = (left.clamp(16.0, screen.width - bubbleWidth - 16.0));
    double top = target.dy - bubbleHeight - 12.0;
    if (top < kToolbarHeight + 16.0) {
      top = target.dy + size.height + 12.0;
    }

    final t = AppLocalizations.of(context);
    final title = t?.streakOverviewTitle ?? 'Streak Overview';
    final body = t?.streakNuxBody ??
        'Tap the dots to jump to a specific day.\nYour streak grows when you log any food entry for the day.';
    final gotIt = t?.gotIt ?? 'Got it';

    _overlay = OverlayEntry(builder: (_) {
      return Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissCoachmark,
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: bubbleWidth,
          height: bubbleHeight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.dividerGray.withValues(alpha: 0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: _dismissCoachmark,
                      child: Text(gotIt),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
    });
    Overlay.of(context).insert(_overlay!);
  }

  Future<void> _dismissCoachmark() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('streak_overview_nux_seen', true);
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  void _goAddFood() {
    Navigator.pushNamed(context, AppRoutes.addFoodEntry).then((_) => _load());
  }

  Widget _header() {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.4.h),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: semantics.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: semantics.warning,
                size: 28,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      AppLocalizations.of(context)?.streakCurrentLabel ??
                          'Current streak',
                      style: textStyles.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      )),
                  SizedBox(height: 0.6.h),
                  Text(
                    _current > 0
                        ? (AppLocalizations.of(context)?.streakDays(_current) ??
                            '${_current} days')
                        : (AppLocalizations.of(context)?.streakNoStreak ??
                            'No streak yet'),
                    style: textStyles.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _goAddFood,
              icon: const Icon(Icons.add),
              label: Text(
                  AppLocalizations.of(context)?.streakLogFood ?? 'Log food'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard() {
    const thresholds = [3, 5, 7, 14, 30];
    int? next;
    for (final t in thresholds) {
      if (_current < t) {
        next = t;
        break;
      }
    }
    final t = AppLocalizations.of(context);
    final subtitle = next != null
        ? (t?.streakDayProgress(_current, next) ?? 'Day ${_current}/${next}')
        : (t?.streakGoalCompleted ?? 'Goal completed');
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;

    Widget chip(int t) {
      final reached = _current >= t;
      return Chip(
        label: Text('${t}d'),
        backgroundColor: reached
            ? semantics.success.withValues(alpha: 0.15)
            : colors.outlineVariant.withValues(alpha: 0.2),
        labelStyle: textStyles.labelMedium?.copyWith(
          color: reached ? colors.onSurface : colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        avatar: reached
            ? Icon(
                Icons.check_circle,
                color: semantics.success,
                size: 18,
              )
            : null,
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                    AppLocalizations.of(context)?.streakMilestonesTitle ??
                        'Milestones',
                    style: textStyles.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            SizedBox(height: 1.h),
            Text(subtitle,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                )),
            SizedBox(height: 1.6.h),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: thresholds.map(chip).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekOverview() {
    final today = DateTime.now();
    final t2 = AppLocalizations.of(context);
    final labels = [
      t2?.weekMon ?? 'Mon',
      t2?.weekTue ?? 'Tue',
      t2?.weekWed ?? 'Wed',
      t2?.weekThu ?? 'Thu',
      t2?.weekFri ?? 'Fri',
      t2?.weekSat ?? 'Sat',
      t2?.weekSun ?? 'Sun'
    ];
    List<Widget> dots = [];
    for (int i = 0; i < 7; i++) {
      final d = _monday.add(Duration(days: i));
      final isToday =
          d.year == today.year && d.month == today.month && d.day == today.day;
      final has = _weekHasLog[i];
      dots.add(GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.dailyTrackingDashboard,
            arguments: {
              'date': DateTime(d.year, d.month, d.day).toIso8601String(),
            },
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: has ? AppTheme.activeBlue : AppTheme.dividerGray,
                border: isToday
                    ? Border.all(color: AppTheme.activeBlue, width: 2.0)
                    : null,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(labels[i],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ),
      ));
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                    AppLocalizations.of(context)?.streakWeeklyOverviewTitle ??
                        'Weekly overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
              ],
            ),
            SizedBox(height: 1.8.h),
            Row(
              key: _weekKey,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dots,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: AppTheme.premiumGold),
            const SizedBox(width: 10),
            Text(
                AppLocalizations.of(context)?.streakLongestTitle ??
                    'Longest streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
            const Spacer(),
            Text(
              _longest > 0
                  ? (AppLocalizations.of(context)?.streakDays(_longest) ??
                      '${_longest} days')
                  : '—',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.streakOverviewTitle ??
            'Streak Overview'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goAddFood,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  SizedBox(height: 1.h),
                  _header(),
                  _challengeCard(),
                  _weekOverview(),
                  _summary(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }
}
