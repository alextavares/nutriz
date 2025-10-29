import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../core/app_export.dart';
import '../../theme/design_tokens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../components/app_card.dart';
import '../../components/animated_scale_button.dart';
import '../../components/pill_button.dart';
import './widgets/circular_progress_chart_widget.dart';
import './widgets/dashboard_ring_v2.dart';
import './widgets/macronutrient_progress_widget.dart';
import './widgets/water_tracker_card_v2.dart';
import '../../services/nutrition_storage.dart';
import '../../services/user_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../services/notes_storage.dart';
import '../../services/body_metrics_storage.dart';
import '../../services/fasting_storage.dart';
import '../../services/streak_service.dart';
import '../../services/achievement_service.dart';
import './widgets/achievement_badges_widget.dart';
import '../../services/notifications_service.dart';
import '../../services/weekly_goal_service.dart';
import '../../services/daily_goal_service.dart';
import '../common/celebration_overlay.dart';
import 'package:nutriz/util/download_stub.dart'
    if (dart.library.html) 'package:nutriz/util/download_web.dart';
import 'package:nutriz/util/upload_stub.dart'
    if (dart.library.html) 'package:nutriz/util/upload_web.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../components/multi_action_fab.dart';
import '../../components/pressable_widget.dart';
import '../../components/animated_card.dart';
import '../../core/app_strings.dart';
import '../../components/coach_mark.dart';
import '../../components/meal_item_skeleton.dart';
import '../../core/haptic_helper.dart';
import '../../core/toast_manager.dart';

class DailyTrackingDashboard extends StatefulWidget {
  const DailyTrackingDashboard({super.key});

  @override
  State<DailyTrackingDashboard> createState() => _DailyTrackingDashboardState();
}

class _DailyTrackingDashboardState extends State<DailyTrackingDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _initArgsHandled = false;
  int _currentWeek = 32;
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  bool _isLoadingMeals = false;
  // Removed old day/week toggle state — we follow YAZIO-like date nav
  final Set<String> _expandedMealKeys = <String>{};
  List<Map<String, dynamic>> _todayEntries = [];
  List<int> _weeklyCalories = List.filled(7, 0);
  List<int> _weeklyWater = List.filled(7, 0);
  Map<String, dynamic> _lastExerciseMeta = const {};

  String _fmtInt(int v) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.decimalPattern(locale).format(v);
  }

  // Exercise UI state
  int _exerciseStreak = 0;
  bool _exerciseExpanded = false;
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
  int _hydrationStreak = 0;
  int _fastingStreak = 0;
  int _caloriesStreak = 0;
  int _proteinStreak = 0;
  List<Map<String, dynamic>> _achievements = const [];
  List<Map<String, dynamic>> _exerciseLogs = const [];
  bool _showNextMilestoneCaptions = true;
  // Fasting mute banner state
  bool _fastingActiveMuted = false;
  DateTime? _fastMuteUntil;
  DateTime? _fastEndAt;
  String _fastMethod = 'custom';
  String? _bannerDismissedOn; // YYYY-MM-DD
  bool _bannerCollapsed = false;
  bool _bannerAlwaysCollapsed = false;
  // Eating window (for banner schedule labels)
  int? _eatStartH;
  int? _eatStartM;
  int? _eatStopH;
  int? _eatStopM;

  // Global animation constants for dashboard sections
  static const Duration _kAnimDuration = Duration(milliseconds: 900);
  static const Curve _kAnimCurve = Curves.easeOut;
  static const double _kDelayLeft = 0.03; // ~27ms
  static const double _kDelayCenter = 0.06; // ~54ms
  static const double _kDelayRight = 0.09; // ~81ms
  // Toggle to draw extremely visible macro bars for debugging screenshots
  static const bool _kMacroBarsDebug = false;

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

  // Simple ISO-like week number (Mon-first). Good enough for UI label.
  int _computeIsoWeekNumber(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // Thursday in current week determines the year.
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstThursdayAdj =
        firstThursday.add(Duration(days: -((firstThursday.weekday + 6) % 7)));
    final week =
        1 + ((thursday.difference(firstThursdayAdj).inDays) / 7).floor();
    return week;
  }

  int? _nextMilestoneFor(int current, List<int> thresholds) {
    for (final t in thresholds) {
      if (current < t) return t;
    }
    return null;
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
              AppLocalizations.of(context) !.streakNext(next), 
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

  ButtonStyle _pillActionStyle(ColorScheme cs) {
    return OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const StadiumBorder(),
      side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
      foregroundColor: cs.primary,
      textStyle: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _quickActivityChip(String label, VoidCallback onTap) {
    final w = MediaQuery.of(context).size.width;
    final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
    final double padH = w < 360 ? 8 : 10;
    final double padV = w < 360 ? 4 : 6;
    final semantic = context.semanticColors;
    final colors = context.colors;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      backgroundColor: semantic.success.withValues(alpha: 0.10),
      labelPadding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: fs,
          ),
      shape: StadiumBorder(
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // Achievements are loaded dynamically from AchievementService

  String _localizedTodayLabel(BuildContext context) {
    return AppLocalizations.of(context)!.appbarToday;
  }

  String _localizedMacroLabel(BuildContext context, String macroType) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    switch (macroType) {
      case 'carbs':
        return lang == 'pt' ? 'Carboidratos' : 'Carbs';
      case 'protein':
        return lang == 'pt' ? 'Proteínas' : 'Protein';
      case 'fat':
        return lang == 'pt' ? 'Gorduras' : 'Fat';
      default:
        return macroType;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One-time read of route arguments for deep-link date navigation
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
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_diary_onboarding') ?? false;
    if (!seen && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showOnboarding = true);
      });
    }
  }

  Future<void> _dismissOnboarding() async {
    if (_onboardingStep < 2) {
      setState(() => _onboardingStep++);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_diary_onboarding', true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  Future<void> _refreshGamificationRow() async {
    final streak = await StreakService.currentStreak('water');
    final fast = await StreakService.currentStreak('fasting');
    final cal = await StreakService.currentStreak('calories_ok_day');
    final prot = await StreakService.currentStreak('protein');
    final ach = await AchievementService.listAll();
    if (!mounted) return;
    setState(() {
      _hydrationStreak = streak;
      _fastingStreak = fast;
      _caloriesStreak = cal;
      _proteinStreak = prot;
      ach.sort((a, b) =>
          (b['dateIso'] as String?)?.compareTo(a['dateIso'] as String? ?? '') ??
          0);
      _achievements = ach.take(6).toList();
    });

    // Celebrate newly added achievements (optional)
    final lastAdded = await AchievementService.getLastAddedTs();
    final lastSeen = await AchievementService.getLastSeenTs();
    if (lastAdded > 0 && lastAdded > lastSeen) {
      // Use overlay only; respect reduce animations handled inside
      await CelebrationOverlay.maybeShow(context,
          variant: CelebrationVariant.achievement);
      await AchievementService.setLastSeenTs(lastAdded);
    }
  }

  Widget _waterStreakChip() {
    final milestones = const [3, 5, 7, 14, 30];
    final isMilestone = milestones.toSet().contains(_hydrationStreak);
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
    final isMilestone = milestones.toSet().contains(_fastingStreak);
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
    final isMilestone = milestones.toSet().contains(_caloriesStreak);
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
    final isMilestone = milestones.toSet().contains(_proteinStreak);
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

  void _showBadgeDetails(Map<String, dynamic> a) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final when = (a['dateIso'] as String?) ?? '';
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CustomIconWidget(
                    iconName: 'emoji_events',
                    color: AppTheme.premiumGold,
                    size: 22),
                const SizedBox(width: 8),
                Text('Conquista',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 8),
              Text(a['title'] as String? ?? 'Conquista',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Obtida em: $when',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: AppTheme.textPrimary),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Small debug banner with build info (debug-only)
  Widget _debugBuildInfo(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    const String buildHash =
        String.fromEnvironment('BUILD_HASH', defaultValue: 'n/a');
    const String buildTime =
        String.fromEnvironment('BUILD_TIME', defaultValue: 'n/a');
    const String appVersion =
        String.fromEnvironment('APP_VERSION', defaultValue: '1.1.0+2');
    const String buildId =
        String.fromEnvironment('BUILD_ID', defaultValue: 'n/a');
    final String idOrHash = (buildHash.toLowerCase() != 'unknown' &&
            buildHash.toLowerCase() != 'n/a')
        ? buildHash
        : buildId;
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.cardInternal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'v$appVersion • DEBUG • $idOrHash • $buildTime',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact version chip inside the header for easy visual check
  Widget _versionChip(BuildContext context) {
    // Show in debug, or when a UI_TAG is explicitly provided via --dart-define
    const String uiTag = String.fromEnvironment('UI_TAG', defaultValue: '');
    if (!kDebugMode && uiTag.isEmpty) return const SizedBox.shrink();
    const String buildHash =
        String.fromEnvironment('BUILD_HASH', defaultValue: 'n/a');
    const String buildTime =
        String.fromEnvironment('BUILD_TIME', defaultValue: 'n/a');
    const String appVersion =
        String.fromEnvironment('APP_VERSION', defaultValue: '1.1.0+2');
    const String buildId =
        String.fromEnvironment('BUILD_ID', defaultValue: 'n/a');
    final String idOrHash = (buildHash.toLowerCase() != 'unknown' &&
            buildHash.toLowerCase() != 'n/a')
        ? buildHash
        : buildId;
    String hhmmZ = '';
    if (buildTime.contains('T') && buildTime.endsWith('Z')) {
      final t = buildTime.split('T');
      if (t.length == 2) {
        final h = t[1];
        if (h.length >= 5) {
          hhmmZ = h.substring(0, 5) + 'Z';
        }
      }
    }
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Text(
        (() {
          final tag = uiTag.isNotEmpty ? uiTag : 'debug';
          if (hhmmZ.isNotEmpty)
            return '$tag • v$appVersion • $idOrHash • $hhmmZ';
          return '$tag • v$appVersion • $idOrHash';
        })(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _topActionsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = cs.onSurfaceVariant;
    final w = MediaQuery.of(context).size.width;
    final bool compact = w < 380; // telas estreitas: mover ações para menu
    final bool ultraCompact =
        w < 350; // ainda mais estreito: simplificar ainda mais
    const double _iconSize = 20; // YAZIO-like compact size
    const BoxConstraints _iconConstraints =
        BoxConstraints(minWidth: 36, minHeight: 36);
    Widget action(IconData icon, String tip, VoidCallback onTap) => IconButton(
          tooltip: tip,
          icon: Icon(icon, size: _iconSize, color: iconColor),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: _iconConstraints,
          onPressed: onTap,
        );

    Future<void> _pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 1),
        initialDate: _selectedDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(primary: AppTheme.activeBlue),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() =>
            _selectedDate = DateTime(picked.year, picked.month, picked.day));
        await _loadToday();
        await _loadWeek();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.cardInternal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Date navigation and actions
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_left,
                    size: _iconSize, color: cs.onSurfaceVariant),
                onPressed: () async {
                  setState(() => _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1)));
                  await _loadToday();
                  await _loadWeek();
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_right,
                    size: _iconSize, color: cs.onSurfaceVariant),
                onPressed: () async {
                  setState(() =>
                      _selectedDate = _selectedDate.add(const Duration(days: 1)));
                  await _loadToday();
                  await _loadWeek();
                },
              ),
              const Spacer(),
              // Ações principais - apenas as mais importantes visíveis
              if (w >= 400) ...[
                action(Icons.query_stats_outlined, AppLocalizations.of(context)!.statistics, () {
                  Navigator.pushNamed(context, AppRoutes.progressOverview);
                }),
                action(Icons.calendar_today_outlined, AppLocalizations.of(context)!.appbarSelectDate, _pickDate),
              ] else ...[
                action(Icons.calendar_today_outlined, AppLocalizations.of(context)!.appbarSelectDate, _pickDate),
              ],
              if (w >= 420) ...[
                action(Icons.local_fire_department, AppLocalizations.of(context)!.dayActions, _openDayActionsMenu),
              ],
              // Menu dropdown com ações secundárias - sempre visível
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: PopupMenuButton<String>(
                  tooltip: AppLocalizations.of(context)!.moreActions,
                  position: PopupMenuPosition.under,
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                        value: 'achievements', child: Text(AppLocalizations.of(context)!.achievementsTitle)),
                    PopupMenuItem<String>(
                        value: 'metrics', child: Text(AppLocalizations.of(context)!.bodyMetrics)),
                    PopupMenuItem<String>(
                        value: 'notes', child: Text(AppLocalizations.of(context)!.notesTitle)),
                    if (w < 400)
                      PopupMenuItem<String>(
                          value: 'stats', child: Text(AppLocalizations.of(context)!.statistics)),
                    PopupMenuItem<String>(
                        value: 'coach', child: Text(AppLocalizations.of(context)!.navCoach)),
                    if (w < 420)
                      PopupMenuItem<String>(
                          value: 'actions', child: Text(AppLocalizations.of(context)!.dayActions)),
                  ],
                  onSelected: (v) {
                    switch (v) {
                      case 'achievements':
                        Navigator.pushNamed(context, AppRoutes.achievements);
                        break;
                      case 'metrics':
                        Navigator.pushNamed(context, AppRoutes.bodyMetrics);
                        break;
                      case 'notes':
                        Navigator.pushNamed(context, AppRoutes.notes, arguments: {
                          'date': _selectedDate.toIso8601String(),
                        });
                        break;
                      case 'stats':
                        Navigator.pushNamed(context, AppRoutes.progressOverview);
                        break;
                      case 'coach':
                        Navigator.pushNamed(context, AppRoutes.aiCoachChat);
                        break;
                      case 'actions':
                        _openDayActionsMenu();
                        break;
                    }
                  },
                  icon: Icon(Icons.more_vert, size: _iconSize, color: iconColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Today, Week, Summary/Details
          Builder(builder: (context) {
            final DateTime t = DateTime.now();
            final today = DateTime(t.year, t.month, t.day);
            final sel = DateTime(
                _selectedDate.year, _selectedDate.month, _selectedDate.day);
            final isToday = sel == today;
            final weekNumber = _computeIsoWeekNumber(sel);
            final lang = Localizations.localeOf(context)
                .languageCode
                .toLowerCase();

            String label;
            if (isToday) {
              label = _localizedTodayLabel(context);
            } else {
              final wdPt = const [
                'Seg',
                'Ter',
                'Qua',
                'Qui',
                'Sex',
                'Sáb',
                'Dom'
              ];
              final wdEn = const [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ];
              final wd = (lang == 'pt' ? wdPt : wdEn)[sel.weekday - 1];
              final dd = sel.day.toString().padLeft(2, '0');
              final mm = sel.month.toString().padLeft(2, '0');
              label = '$wd $dd/$mm';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Today" text - larger size like YAZIO
                Text(
                  label,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 4),
                // "Week 158" text
                Text(
                  '${AppLocalizations.of(context)!.dashboardWeek} $weekNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 12),
                // "Summary" with "Details" link
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dashboardSummary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Navigate to details page
                        Navigator.pushNamed(context, AppRoutes.progressOverview);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.dashboardDetails,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _weekAgenda(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final DateTime selected = _selectedDate;
    final DateTime t = DateTime.now();
    final DateTime today = DateTime(t.year, t.month, t.day);
    final int weekday = selected.weekday; // 1=Mon..7=Sun
    final DateTime monday = selected.subtract(Duration(days: (weekday - 1)));
    List<Widget> items = [];
    // Locale-aware day labels
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final labelsPt = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final labelsEn = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabels = lang == 'pt' ? labelsPt : labelsEn;
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
              setState(() => _selectedDate = DateTime(d.year, d.month, d.day));
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    dayLabels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(children: items),
    );
  }

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
    final int display = exceeded ? -remaining : remaining;
    final TextStyle label =
        theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant);
    final TextStyle numStyle = theme.textTheme.titleLarge!.copyWith(
      color: exceeded ? AppTheme.errorRed : cs.primary,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final base = theme.textTheme.bodyMedium!;
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
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Removed duplicated remaining label under the ring (YAZIO does not show it here)
          // Keep only the compact equation row below for clarity
          // Equation row
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: eqStyle.copyWith(color: cs.onSurfaceVariant),
              children: [
                const TextSpan(text: 'Objetivo '),
                TextSpan(
                    text: _fmtInt(goal),
                    style: eqStyle.copyWith(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
                TextSpan(text: ' − ', style: opStyle),
                const TextSpan(text: 'Alimentação '),
                TextSpan(
                    text: _fmtInt(food),
                    style: eqStyle.copyWith(
                        color: AppTheme.warningAmber,
                        fontWeight: FontWeight.w700)),
                TextSpan(text: ' + ', style: opStyle),
                const TextSpan(text: 'Exercício '),
                TextSpan(
                    text: _fmtInt(exercise),
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

  // Removed unused quick action row

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
    _startHydrationReminderLoop();
    _refreshFastingBanner();
    _loadBannerPrefs();
    _loadEatingTimes();
    // Gamification evals
    _refreshGamificationRow();
    WeeklyGoalService.evaluatePerfectCaloriesWeek().then((created) {
      if (created && mounted) _refreshGamificationRow();
    });
    DailyGoalService.evaluateProteinOkToday()
        .then((_) => _refreshGamificationRow());
    DailyGoalService.evaluateCaloriesOkToday()
        .then((_) => _refreshGamificationRow());
    // Refresh whenever NutritionStorage mutates
    NutritionStorage.changes.addListener(_onStorageChanged);
    // Listen to UI preference changes
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

  void _onStorageChanged() {
    if (!mounted) return;
    _loadToday();
    _loadWeek();
    _loadGoals(); // reload global goals
    _loadMealGoals(); // reload per-meal goals
  }

  @override
  void dispose() {
    NutritionStorage.changes.removeListener(_onStorageChanged);
    UserPreferences.changes.removeListener(_onUiPrefsChanged);
    super.dispose();
  }

  // Removed unused highlight clearer

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

  // Reusable compact section header (icon + title + right actions)
  Widget _sectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    List<Widget> actions = const [],
    Color? avatarBackground,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor:
              (avatarBackground ?? iconColor.withValues(alpha: 0.12)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
          ),
        ),
        if (actions.isNotEmpty) Row(children: actions),
      ],
    );
  }

  Widget _circleActionBtn({
    required Color bg,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _overallMacrosRow(BuildContext context) {
    // Summary macros in stacked rows with thick progress bars
    final carbsC = (_dailyData["macronutrients"]["carbohydrates"]["consumed"]
            as int? ??
        0);
    final carbsT =
        (_dailyData["macronutrients"]["carbohydrates"]["total"] as int? ?? 0);
    final protC =
        (_dailyData["macronutrients"]["proteins"]["consumed"] as int? ?? 0);
    final protT =
        (_dailyData["macronutrients"]["proteins"]["total"] as int? ?? 0);
    final fatC = (_dailyData["macronutrients"]["fats"]["consumed"] as int? ??
        0);
    final fatT =
        (_dailyData["macronutrients"]["fats"]["total"] as int? ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)?.macronutrients ?? 'Macros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: _openEditMacroGoalsDialog,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(AppLocalizations.of(context)?.goals ?? 'Goals'),
              style: _pillActionStyle(Theme.of(context).colorScheme),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMacroRow(
          name: _localizedMacroLabel(context, 'carbs'),
          color: AppColors.macroCarb,
          consumed: carbsC.toDouble(),
          goal: carbsT.toDouble(),
        ),
        const SizedBox(height: 16),
        _buildMacroRow(
          name: _localizedMacroLabel(context, 'protein'),
          color: AppColors.macroProtein,
          consumed: protC.toDouble(),
          goal: protT.toDouble(),
        ),
        const SizedBox(height: 16),
        _buildMacroRow(
          name: _localizedMacroLabel(context, 'fat'),
          color: AppColors.macroFat,
          consumed: fatC.toDouble(),
          goal: fatT.toDouble(),
        ),
      ],
    );
  }

  Widget _buildMacroRow({
    required String name,
    required Color color,
    required double consumed,
    required double goal,
  }) {
    final percentage = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                children: [
                  TextSpan(text: consumed.toInt().toString()),
                  TextSpan(
                    text: '/${goal.toInt()} g',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_kMacroBarsDebug)
          // Loud, highly visible debug bars to confirm rendering on screenshots
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.5,
                minHeight: 20,
                backgroundColor: Colors.yellow,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          )
        else
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 16,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _refreshFastingBanner() async {
    final active = await FastingStorage.getActive();
    final muteUntil = await NotificationsService.getFastingMuteUntil();
    final prefs = await SharedPreferences.getInstance();
    final dism = prefs.getString('fasting_banner_dismissed_on');
    if (!mounted) return;
    final now = DateTime.now();
    final muted = muteUntil != null && now.isBefore(muteUntil);
    setState(() {
      _fastingActiveMuted = active != null && muted;
      _fastMuteUntil = muteUntil;
      _fastEndAt = active != null ? active.start.add(active.target) : null;
      _fastMethod = active?.method ?? 'custom';
      _bannerDismissedOn = dism;
    });
  }

  Future<void> _loadBannerPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final always = prefs.getBool('fasting_banner_always_collapsed') ?? false;
    if (!mounted) return;
    setState(() {
      _bannerAlwaysCollapsed = always;
      if (always) _bannerCollapsed = true;
    });
  }

  Future<void> _loadEatingTimes() async {
    final t = await UserPreferences.getEatingTimes();
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
    // Dismissal for today
    String two(int v) => v.toString().padLeft(2, '0');
    final todayKey =
        '${DateTime.now().year}-${two(DateTime.now().month)}-${two(DateTime.now().day)}';
    if (_bannerDismissedOn == todayKey) return const SizedBox.shrink();
    final until = _fastMuteUntil;
    final untilLabel = (until != null)
        ? '${two(until.day)}/${two(until.month)} ${two(until.hour)}:${two(until.minute)}'
        : '';
    final endAt = _fastEndAt;
    String endLabel = '';
    if (endAt != null) {
      final now = DateTime.now();
      final datePrefix = (endAt.day != now.day || endAt.month != now.month)
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
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: _bannerCollapsed ? 8 : 10),
        decoration: BoxDecoration(
          color: AppTheme.warningAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
        ),
        constraints: BoxConstraints(
          // Ensure a tidy, consistent height when collapsed
          minHeight: _bannerCollapsed ? 52 : 0,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 18,
                      color: (Color.lerp(
                              AppTheme.warningAmber, Colors.white, 0.2) ??
                          AppTheme.warningAmber)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Builder(builder: (context) {
                      final w = MediaQuery.of(context).size.width;
                      double? fs;
                      if (_bannerCollapsed) {
                        fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
                      }
                      return Text(
                        until != null
                            ? 'Jejum em andamento — silenciado até $untilLabel — término sem notificação$endLabel$schLabel'
                            : 'Jejum em andamento — silenciado — término sem notificação$endLabel$schLabel',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: fs,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                  IconButton(
                    tooltip: _bannerCollapsed ? 'Expandir' : 'Recolher',
                    onPressed: () =>
                        setState(() => _bannerCollapsed = !_bannerCollapsed),
                    icon: Icon(
                        _bannerCollapsed
                            ? Icons.expand_more
                            : Icons.expand_less,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Dismiss for today
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'fasting_banner_dismissed_on', todayKey);
                      if (!mounted) return;
                      setState(() => _bannerDismissedOn = todayKey);
                    },
                    child: Text(AppLocalizations.of(context)!.dismissToday),
                  ),
                ],
              ),
              if (!_bannerCollapsed) const SizedBox(height: 8),
              if (!_bannerCollapsed)
                Builder(builder: (context) {
                  final w = MediaQuery.of(context).size.width;
                  final space = w < 360 ? 6.0 : 8.0;
                  final rspace = w < 360 ? 4.0 : 6.0;
                  final padH = w < 360 ? 8.0 : 10.0;
                  final padV = w < 360 ? 4.0 : 6.0;
                  return Wrap(
                    spacing: space,
                    runSpacing: rspace,
                    children: [
                      // Reativar inline
                      ElevatedButton.icon(
                        onPressed: () async {
                          await NotificationsService.setFastingMuteUntil(null);
                          if (!mounted) return;
                          setState(() => _fastMuteUntil = null);
                          // Reschedule daily reminders
                          final t = await UserPreferences.getEatingTimes();
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
                            );
                          }
                          // Also schedule end-of-fast if still active
                          if (_fastEndAt != null) {
                            NotificationsService.scheduleFastingEnd(
                                endAt: _fastEndAt!, method: _fastMethod);
                          }
                          _refreshFastingBanner();
                        },
                        icon: const Icon(Icons.notifications_active_outlined,
                            size: 16),
                        label: const Text('Reativar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
                        ),
                        child: const Text('24h'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final tomorrow =
                              DateTime(now.year, now.month, now.day)
                                  .add(const Duration(days: 1));
                          final until = DateTime(tomorrow.year, tomorrow.month,
                              tomorrow.day, 8, 0);
                          await NotificationsService.setFastingMuteUntil(until);
                          await NotificationsService
                              .cancelDailyFastingReminders();
                          await NotificationsService.cancelFastingEnd();
                          _refreshFastingBanner();
                        },
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
                        ),
                        child: const Text('Amanhã 08:00'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, AppRoutes.intermittentFastingTracker);
                          if (!mounted) return;
                          _refreshFastingBanner();
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                              horizontal: padH, vertical: padV),
                        ),
                        child: const Text('Gerenciar'),
                      ),
                      ],
                    );
                  }),
              if (!_bannerCollapsed) const SizedBox(height: 6),
              if (!_bannerCollapsed)
                Row(
                  children: [
                    Switch(
                      value: _bannerAlwaysCollapsed,
                      onChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(
                            'fasting_banner_always_collapsed', v);
                        if (!mounted) return;
                        setState(() {
                          _bannerAlwaysCollapsed = v;
                          _bannerCollapsed = v ? true : _bannerCollapsed;
                        });
                      },
                      activeColor: AppTheme.activeBlue,
                    ),
                    Text('Sempre recolher',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroSummary(String label, int consumed, int goal) {
    String _short(String l) {
      final lc = l.toLowerCase();
      if (lc.startsWith('carb')) return 'C';
      if (lc.startsWith('prot')) return 'P';
      if (lc.startsWith('gord') || lc.startsWith('fat')) return 'G';
      return l.characters.first;
    }

    final color = _macroColorFor(label);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_macroIconFor(label), color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            _short(label),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "$consumed/$goal g",
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerMealProgressSection() {
    if (_isLoadingMeals) {
      return AppCard(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            MealItemSkeleton(),
            SizedBox(height: 8),
            MealItemSkeleton(),
            SizedBox(height: 8),
            MealItemSkeleton(),
            SizedBox(height: 8),
            MealItemSkeleton(),
          ],
        ),
      );
    }
    List<Map<String, dynamic>> _mealPreview(String mealKey, int maxItems) {
      final entries = _todayEntries
          .where((e) => (e['mealTime'] as String?) == mealKey)
          .toList();
      // Most recent first by createdAt, fallback as is
      entries.sort((a, b) => ((b['createdAt'] as String?) ?? '')
          .compareTo((a['createdAt'] as String?) ?? ''));
      if (entries.length > maxItems) return entries.sublist(0, maxItems);
      return entries;
    }

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

    void _goToLoggingForMeal(String mealKey) {
      Navigator.pushNamed(context, AppRoutes.addFoodEntry, arguments: {
        'mealKey': mealKey,
        'targetDate': _selectedDate.toIso8601String(),
      }).then((_) async {
        // Recarrega sempre ao voltar do registro de alimentos,
        // independente do valor retornado.
        await _loadToday();
        await _loadWeek();
      });
    }

    IconData mealIconFor(String mealKey) {
      switch (mealKey) {
        case 'breakfast':
          return MdiIcons.coffee; // café da manhã
        case 'lunch':
          return MdiIcons.foodForkDrink; // almoço
        case 'dinner':
          return MdiIcons.food; // jantar
        default:
          return MdiIcons.cookie; // lanches
      }
    }

    Widget row(String title, String mealKey) {
      final totals = _mealTotals[mealKey]!;
      final goal = _mealGoals[mealKey]?.kcal ?? 0;
      // Top bar similar ao app de referência

      final value = totals['kcal'] ?? 0;
      final ratio = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
      final color = barColorFor(mealKey);
      void _openMealDetails() {
        Navigator.pushNamed(context, AppRoutes.detailedMealTrackingScreen,
            arguments: {
              'mealKey': mealKey,
              'date': _selectedDate.toIso8601String(),
            });
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _openMealDetails,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8), // Add vertical padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Builder(builder: (context) {
                    final ic = barColorFor(mealKey);
                    return CircleAvatar(
                      radius: 24, // Increased from 18 to 24
                      backgroundColor: ic.withValues(alpha: 0.12),
                      child: Icon(
                        mealIconFor(mealKey),
                        color: ic,
                        size: 28, // Increased from 20 to 28
                      ),
                    );
                  }),
                  const SizedBox(width: 16), // Increased from 12 to 16
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 17, // Increased size
                              ),
                        ),
                        const SizedBox(height: 4), // Increased from 2 to 4
                        Text(
                          '$value / $goal Cal',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: 15, // Increased size
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PressableWidget(
                    scale: 0.92,
                    onPressed: () {
                      HapticHelper.medium();
                      _goToLoggingForMeal(mealKey);
                    },
                    child: SizedBox(
                      width: 44, // Increased from 40 to 44
                      height: 44, // Increased from 40 to 44
                      child: Material(
                        color: AppTheme.activeBlue,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add,
                            size: 24, color: Colors.white), // Increased from 22 to 24
                      ),
                    ),
                  ),
                  // Removed trailing chevron to match YAZIO-like layout
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 3,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.35),
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              // Compact preview of items for this meal (tap to editar)
              ...(() {
                final all = _todayEntries
                    .where((e) => (e['mealTime'] as String?) == mealKey)
                    .toList()
                  ..sort((a, b) => ((b['createdAt'] as String?) ?? '')
                      .compareTo((a['createdAt'] as String?) ?? ''));
                final bool expanded = _expandedMealKeys.contains(mealKey);
                final list = expanded ? all : _mealPreview(mealKey, 2);
                if (list.isEmpty) return <Widget>[];
                return [
                  ...list.map((e) => InkWell(
                        onTap: () => _editEntry(e),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (e['name'] as String?) ?? '-',
                                  style: AppTheme.darkTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(e['calories'] as num?)?.toInt() ?? 0} kcal',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (all.length > 2)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            if (expanded) {
                              _expandedMealKeys.remove(mealKey);
                            } else {
                              _expandedMealKeys.add(mealKey);
                            }
                          });
                        },
                        child: Text(expanded ? 'Mostrar menos' : 'Ver todos'),
                      ),
                    ),
                  SizedBox(height: 2.4.h), // Increased spacing between meals (like YAZIO)
                ];
              }()),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add "Nutrition" header like YAZIO
          Text(
            AppLocalizations.of(context)!.dashboardNutrition,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          row(AppLocalizations.of(context)!.mealBreakfast, 'breakfast'),
          row(AppLocalizations.of(context)!.mealLunch, 'lunch'),
          row(AppLocalizations.of(context)!.mealDinner, 'dinner'),
          row(AppLocalizations.of(context)!.mealSnack, 'snack'),
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
          width: 12.w,
          child: Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 3,
              backgroundColor: AppTheme.dividerGray.withValues(alpha: 0.35),
              color: color,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          goal > 0 ? '$value/$goal g' : '$value g',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: over ? AppTheme.errorRed : AppTheme.textSecondary,
            fontWeight: over ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // _waterCupsRow removed (replaced by horizontal bar + quick pill actions)

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

    String _fmtDate(DateTime d) {
      String two(int n) => n < 10 ? '0$n' : '$n';
      return '${two(d.day)}/${two(d.month)}';
    }

    void _prevDay() {
      setState(() =>
          _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
      _loadToday();
      _loadWeek();
    }

    void _nextDay() {
      setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 1)));
      _loadToday();
      _loadWeek();
    }

    void _goToday() {
      final t = DateTime.now();
      setState(() => _selectedDate = DateTime(t.year, t.month, t.day));
      _loadToday();
      _loadWeek();
    }

    // Removed unused local helpers: _goToday, _openSearch

    final scaffold = Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context)?.appbarPrevDay ?? 'Previous day',
          icon: const Icon(Icons.chevron_left),
          onPressed: _prevDay,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Diário',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              (() {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final selected =
                    DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                if (selected == today) {
                  return AppLocalizations.of(context)?.appbarToday ?? 'Hoje';
                }
                return _fmtDate(_selectedDate);
              })(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _goToday,
            child: Text(AppLocalizations.of(context)?.appbarToday ?? 'Hoje'),
          ),
          IconButton(
            tooltip: 'Next day',
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextDay,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header actions moved to AppBar (sticky). Keep banner below.
                // Show fasting banner prominently below header/top actions
                _fastingMuteBanner(context),
                SizedBox(height: 0.6.h),

                // Top dashboard header estilo imagem de referência
                Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                    width: double.infinity,
                    // Reduce outer horizontal margin to widen the ring card on phones
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.2)),
                      boxShadow: const [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Date navigation moved to top actions row
                        const SizedBox.shrink(),
                        // Chip "Semana N" removido (YAZIO-like)
                        SizedBox(height: 0.2.h),
                        // New ring per spec (provider-based, custom painter)
                        DashboardRingV2(
                          consumedCalories: _dailyData["consumedCalories"],
                          spentCalories: _dailyData["spentCalories"],
                          totalCalories: _dailyData["totalCalories"],
                          onTap: _showCalorieBreakdown,
                        ),

                        // Removed equation card under ring to match YAZIO (no text under the ring)
                        SizedBox(height: 0.8.h),
                        _overallMacrosRow(context),
                      ],
                    ),
                  );
                }),
                // Botão de ações removido para interface mais limpa/semelhante ao YAZIO

                // Removed duplicate calorie budget card to avoid repeating remaining kcal and label
                const SizedBox.shrink(),

                // Quick actions removidas para layout mais limpo (estilo YAZIO)

                // Circular chart moved to header
                const SizedBox.shrink(),

                // Per-meal progress (kcal and macros) — aligns with YAZIO cards
                const SizedBox(height: AppSpacing.md),

                _buildPerMealProgressSection(),
                const SizedBox(height: AppSpacing.md),
                // Water tracker moved below Nutrition (under Snacks)
                Builder(builder: (context) {
                  return AnimatedCard(
                    delay: 150,
                    child: WaterTrackerCardV2(
                      currentMl: _dailyData["waterMl"] as int,
                      goalMl: _dailyData["waterGoalMl"] as int,
                      onEditGoal: _openEditWaterGoalDialog,
                      onChange: (delta) async {
                        final ml = await NutritionStorage.addWaterMl(_selectedDate, delta);
                        if (!mounted) return ml;
                        setState(() => _dailyData["waterMl"] = ml);
                        _updateHydrationAchievements();
                        return ml;
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                // Thin divider after water card
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // [REMOVED] Legacy water progress card replaced by WaterTrackerCardV2
                /*Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return AnimatedCard(
                    delay: 200,
                    child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal),
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.2)),
                      boxShadow: const [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(Icons.water_drop_outlined,
                                    color: cs.primary, size: 18),
                                Text(
                                  AppLocalizations.of(context)!.water,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (_hydrationStreak > 0)
                                  Builder(builder: (context) {
                                    final w = MediaQuery.of(context).size.width;
                                    final double fs = w < 340
                                        ? 9.sp
                                        : (w < 380 ? 10.sp : 11.sp);
                                    final double padH = w < 360 ? 6 : 8;
                                    final double padV = w < 360 ? 2 : 3;
                                    return Chip(
                                      label:
                                          Text('Streak: ${_hydrationStreak}d'),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor:
                                          cs.primary.withValues(alpha: 0.12),
                                      side: BorderSide(
                                          color: cs.primary
                                              .withValues(alpha: 0.3)),
                                      labelPadding: EdgeInsets.symmetric(
                                          horizontal: padH, vertical: padV),
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: fs,
                                          ),
                                    );
                                  }),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  key: ValueKey(_dailyData["waterMl"] as int?),
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: (_dailyData["waterMl"] as int)
                                        .toDouble(),
                                  ),
                                  duration: _kAnimDuration,
                                  curve: Curves.linear,
                                  builder: (context, v, _) {
                                    final int current =
                                        _dailyData["waterMl"] as int;
                                    final int goal =
                                        _dailyData["waterGoalMl"] as int;
                                    if (current <= 0) {
                                      return Text(
                                        '0/$goal ml',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      );
                                    }
                                    final p = (v / current).clamp(0.0, 1.0);
                                    final delayed = p <= _kDelayRight
                                        ? 0.0
                                        : (p - _kDelayRight) /
                                            (1.0 - _kDelayRight);
                                    final eased =
                                        _kAnimCurve.transform(delayed);
                                    final shown = (current * eased).toInt();
                                    return Text(
                                      '$shown/$goal ml',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    );
                                  },
                                ),
                                Builder(builder: (context) {
                                  final int current = _dailyData["waterMl"] as int;
                                  final int goal = _dailyData["waterGoalMl"] as int;
                                  final int cups = (current / 250).floor();
                                  final int totalCups = (goal / 250).floor();
                                  return Text(
                                    '$cups/$totalCups cups',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  );
                                }),
                                OutlinedButton.icon(
                                  onPressed: ((_dailyData["waterMl"] as int? ??
                                              0) >=
                                          (_dailyData["waterGoalMl"] as int? ??
                                              0))
                                      ? null
                                      : _addWater,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('+250 ml'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: const StadiumBorder(),
                                    side: BorderSide(
                                        color:
                                            cs.primary.withValues(alpha: 0.5)),
                                    foregroundColor: cs.primary,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar meta',
                                  icon: Icon(Icons.edit_outlined,
                                      color: cs.onSurfaceVariant, size: 18),
                                  onPressed: _openEditWaterGoalDialog,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Emphasize hydration: progress + remaining hint
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          final int goal = (_dailyData["waterGoalMl"] as int);
                          final int current = (_dailyData["waterMl"] as int);
                          final double ratio =
                              goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey(ratio),
                                  tween: Tween<double>(begin: 0, end: ratio),
                                  duration: _kAnimDuration,
                                  curve: Curves.linear,
                                  builder: (context, val, _) {
                                    if (ratio <= 0) {
                                      return LinearProgressIndicator(
                                        value: 0,
                                        minHeight: 12,
                                        backgroundColor: cs.outlineVariant
                                            .withValues(alpha: 0.25),
                                        color: cs.primary,
                                      );
                                    }
                                    final p = (val / ratio).clamp(0.0, 1.0);
                                    final eased = _kAnimCurve.transform(p);
                                    return LinearProgressIndicator(
                                      value: eased * ratio,
                                      minHeight: 12,
                                      backgroundColor: cs.outlineVariant
                                          .withValues(alpha: 0.20),
                                      color: cs.primary,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PillButton(
                                label: '1 Cup',
                                backgroundColor: AppColors.primary50,
                                color: AppColors.primary600,
                                onTap: () async {
                                  final ml = await NutritionStorage.addWaterMl(
                                      _selectedDate, 250);
                                  if (!mounted) return;
                                  setState(() => _dailyData["waterMl"] = ml);
                                  _updateHydrationAchievements();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PillButton(
                                label: '2 Cups',
                                backgroundColor: AppColors.primary50,
                                color: AppColors.primary600,
                                onTap: () async {
                                  final ml = await NutritionStorage.addWaterMl(
                                      _selectedDate, 500);
                                  if (!mounted) return;
                                  setState(() => _dailyData["waterMl"] = ml);
                                  _updateHydrationAchievements();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PillButton(
                                label: '3 Cups',
                                backgroundColor: AppColors.primary50,
                                color: AppColors.primary600,
                                onTap: () async {
                                  final ml = await NutritionStorage.addWaterMl(
                                      _selectedDate, 750);
                                  if (!mounted) return;
                                  setState(() => _dailyData["waterMl"] = ml);
                                  _updateHydrationAchievements();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
                }),*/

                // Thin divider between activities and notes
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Notes card (link to Notes screen)
                Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return AnimatedCard(
                    delay: 300,
                    child: FadeInWidget(
                      delay: const Duration(milliseconds: 100),
                      child: AppCard(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          icon: Icons.note_outlined,
                          iconColor: AppIcons.standard(),
                          title: AppLocalizations.of(context)!.notesTitle,
                          actions: [
                            Semantics(
                              label: AppLocalizations.of(context)!.addNote,
                              button: true,
                              hint: AppLocalizations.of(context)!.addNoteHint,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.notes,
                                      arguments: {
                                        'date': _selectedDate.toIso8601String(),
                                        'openEditor': true,
                                      });
                                },
                                icon: Icon(Icons.add, size: AppIcons.sm),
                                label: Text(AppLocalizations.of(context)!.navAdd),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  minimumSize: const Size(0, 36),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: NotesStorage.getAll(),
                              builder: (context, snap) {
                                final list = snap.data ?? const [];
                                // count notes for selected date
                                int countToday = 0;
                                final d = _selectedDate;
                                final today = DateTime(d.year, d.month, d.day);
                                Map<String, dynamic>? last;
                                for (final n in list) {
                                  final u = DateTime.tryParse((n['updatedAt'] ??
                                              n['createdAt']) as String? ??
                                          '') ??
                                      DateTime(1970);
                                  final dd = DateTime(u.year, u.month, u.day);
                                  if (dd == today) {
                                    countToday++;
                                    if (last == null) {
                                      last = n;
                                    } else {
                                      final lu = DateTime.tryParse(
                                              (last['updatedAt'] ??
                                                          last['createdAt'])
                                                      as String? ??
                                                  '') ??
                                          DateTime(1970);
                                      if (u.isAfter(lu)) last = n;
                                    }
                                  }
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.todayNotesCount(countToday),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (last != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        ((last['title'] as String?)
                                                    ?.trim()
                                                    .isNotEmpty ==
                                                true)
                                            ? (last['title'] as String)
                                            : ((last['content'] as String?)
                                                    ?.trim() ??
                                                ''),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ]
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                      ),
                    ),
                  );
                }),

                // Body Metrics card (Valores corporais) — make it discoverable like YAZIO
                const SizedBox(height: AppSpacing.md),
                Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  double? _bmi(Map<String, dynamic> m) {
                    final w = (m['weightKg'] as num?)?.toDouble();
                    final hCm = (m['heightCm'] as num?)?.toDouble();
                    if (w == null || hCm == null || hCm <= 0) return null;
                    final h = hCm / 100.0;
                    return w / (h * h);
                  }

                  return AnimatedCard(
                    delay: 400,
                    child: FutureBuilder<Map<String, dynamic>>(
                    future: BodyMetricsStorage.getForDate(_selectedDate),
                    builder: (context, snap) {
                      final m = snap.data ?? const {};
                      final has = m.isNotEmpty;
                      final w = (m['weightKg'] as num?)?.toString();
                      final h = (m['heightCm'] as num?)?.toString();
                      final fat = (m['bodyFatPct'] as num?)?.toString();
                      final bmi = _bmi(m);
                      return FadeInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: AppCard(
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                    icon: Icons.monitor_weight_outlined,
                                    iconColor: AppIcons.standard(),
                                    title: AppLocalizations.of(context)!.bodyMetrics,
                                    actions: [
                                      Semantics(
                                        label: AppLocalizations.of(context)!.addBodyMetrics,
                                        button: true,
                                        hint: 'Abre editor para registrar peso, altura, IMC e percentual de gordura',
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, AppRoutes.bodyMetrics,
                                                arguments: {
                                                  'date': _selectedDate
                                                      .toIso8601String(),
                                                  'openEditor': true,
                                                });
                                          },
                                          icon: Icon(Icons.add, size: AppIcons.sm),
                                          label: Text(AppLocalizations.of(context)!.navAdd),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            minimumSize: const Size(0, 36),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (has)
                                    Text(
                                      [
                                        if (w != null) 'Peso: ${w} kg',
                                        if (h != null) 'Alt: ${h} cm',
                                        if (bmi != null)
                                          'IMC: ${bmi.toStringAsFixed(1)}',
                                        if (fat != null) 'Gord: ${fat}%'
                                      ].join('  •  '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    )
                                  else
                                    Text(
                                      AppLocalizations.of(context)!.noEntryTodayTapToLog,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.activeBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
                  );
                }),

                // Thin divider between water and activities
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Exercise / Activities (simple)
                Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  final int spent = _dailyData["spentCalories"] as int? ?? 0;
                  return FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: AppCard(
                    isHighlighted: false, // Mudado para false - melhor contraste com background claro
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.md),
                    child: Stack(
                      children: [
                        // Watermark icon - aumentando opacity para melhor visibilidade
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Icon(
                            Icons.fitness_center_outlined,
                            size: 42,
                            color: cs.primary
                                .withValues(alpha: 0.08),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: cs.primary
                                  .withValues(alpha: 0.12),
                              child: Icon(
                                Icons.fitness_center,
                                color: cs.primary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(AppLocalizations.of(context)!.activities,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: cs.onSurface,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                      ),
                                      if (_exerciseStreak > 0)
                                        Builder(builder: (context) {
                                          final w =
                                              MediaQuery.of(context).size.width;
                                          final double fs = w < 340
                                              ? 9.sp
                                              : (w < 380 ? 10.sp : 11.sp);
                                          final double padH = w < 360 ? 6 : 8;
                                          final double padV = w < 360 ? 2 : 3;
                                          final successColor =
                                              context.semanticColors.success;
                                          return Chip(
                                            label: Text(
                                                'Streak: ${_exerciseStreak}d'),
                                            visualDensity:
                                                VisualDensity.compact,
                                            backgroundColor: successColor
                                                .withValues(alpha: 0.12),
                                            side: BorderSide(
                                              color: successColor.withValues(
                                                  alpha: 0.3),
                                            ),
                                            labelPadding: EdgeInsets.symmetric(
                                                horizontal: padH,
                                                vertical: padV),
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: successColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: fs,
                                                ),
                                          );
                                        }),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  FutureBuilder<int>(
                                    future: UserPreferences.getExerciseGoal(),
                                    builder: (context, snap) {
                                      final goal = snap.data ?? 300;
                                      final ratio = goal > 0
                                          ? (spent / goal).clamp(0.0, 1.0)
                                          : 0.0;
                                      final remain =
                                          (goal - spent).clamp(0, goal);
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: [
                                                    TweenAnimationBuilder<double>(
                                                      key: ValueKey(spent),
                                                      tween: Tween(
                                                          begin: 0.0,
                                                          end: spent.toDouble()),
                                                      duration: _kAnimDuration,
                                                      curve: Curves.linear,
                                                      builder: (context, v, _) {
                                                        if (spent <= 0) {
                                                          return Text(
                                                            '${_fmtInt(0)}/${_fmtInt(goal)} kcal',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  color: context.semanticColors.success,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                ),
                                                          );
                                                        }
                                                        final p = (v / spent)
                                                            .clamp(0.0, 1.0);
                                                        final delayed = p <=
                                                                _kDelayLeft
                                                            ? 0.0
                                                            : (p - _kDelayLeft) /
                                                                (1.0 - _kDelayLeft);
                                                        final eased = _kAnimCurve
                                                            .transform(delayed);
                                                        final shown =
                                                            (spent * eased).toInt();
                                                        return Text(
                                                          '${_fmtInt(shown)}/${_fmtInt(goal)} kcal',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                color: context.semanticColors.success,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                    if (remain > 0)
                                                      TweenAnimationBuilder<double>(
                                                        key: ValueKey(remain),
                                                        tween: Tween(
                                                            begin: 0.0,
                                                            end: remain.toDouble()),
                                                        duration: _kAnimDuration,
                                                        curve: Curves.linear,
                                                        builder: (context, v, _) {
                                                          final p = (v / remain)
                                                              .clamp(0.0, 1.0);
                                                          final delayed = p <=
                                                                  _kDelayCenter
                                                              ? 0.0
                                                              : (p - _kDelayCenter) /
                                                                  (1.0 -
                                                                      _kDelayCenter);
                                                          final eased = _kAnimCurve
                                                              .transform(delayed);
                                                          final shown =
                                                              (remain * eased)
                                                                  .toInt();
                                                          return Text(
                                                              'Faltam ${_fmtInt(shown)} kcal',
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    color: cs
                                                                        .onSurfaceVariant,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ));
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: 'Editar meta',
                                                icon: Icon(Icons.edit_outlined,
                                                    size: 18,
                                                    color: cs.onSurfaceVariant),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () =>
                                                    _openEditExerciseGoalDialog(
                                                        goal),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child:
                                                TweenAnimationBuilder<double>(
                                              key: ValueKey(ratio),
                                              tween: Tween<double>(
                                                  begin: 0, end: ratio),
                                              duration: _kAnimDuration,
                                              curve: Curves.linear,
                                              builder: (context, val, _) {
                                                if (ratio <= 0) {
                                                  return LinearProgressIndicator(
                                                    value: 0,
                                                    minHeight: 6,
                                                    backgroundColor: cs
                                                        .outlineVariant
                                                        .withValues(
                                                            alpha: 0.25),
                                                    color:
                                                        AppTheme.successGreen,
                                                  );
                                                }
                                                final p = (val / ratio)
                                                    .clamp(0.0, 1.0);
                                                final eased =
                                                    _kAnimCurve.transform(p);
                                                return LinearProgressIndicator(
                                                  value: eased * ratio,
                                                  minHeight: 6,
                                                  backgroundColor: cs
                                                      .outlineVariant
                                                      .withValues(alpha: 0.25),
                                                  color: AppTheme.successGreen,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (_lastExerciseMeta.isNotEmpty)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.fitness_center,
                                                  size: 16,
                                                  color: context
                                                      .semanticColors.success,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Builder(
                                                      builder: (context) {
                                                    final dt = DateTime.tryParse(
                                                            ((_lastExerciseMeta[
                                                                        'savedAt']
                                                                    as String?) ??
                                                                '')) ??
                                                        DateTime.now();
                                                    final hh = dt.hour
                                                        .toString()
                                                        .padLeft(2, '0');
                                                    final mm = dt.minute
                                                        .toString()
                                                        .padLeft(2, '0');
                                                    return Text(
                                                      'Último: ' +
                                                          ((_lastExerciseMeta[
                                                                      'name']
                                                                  as String?) ??
                                                              '-') +
                                                          ' · +' +
                                                          (((_lastExerciseMeta[
                                                                              'kcal']
                                                                          as num?)
                                                                      ?.toInt() ??
                                                                  0)
                                                              .toString()) +
                                                          ' kcal' +
                                                          ((_lastExerciseMeta[
                                                                      'minutes'] !=
                                                                  null)
                                                              ? ' · ' +
                                                                  ((_lastExerciseMeta[
                                                                              'minutes']
                                                                          as num)
                                                                      .toInt()
                                                                      .toString()) +
                                                                  ' min'
                                                              : '') +
                                                          ' · ' +
                                                          hh +
                                                          ':' +
                                                          mm,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: cs
                                                                .onSurfaceVariant,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          if (_exerciseLogs.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Column(
                                              children: [
                                                for (final log in _exerciseLogs)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .watch_later_outlined,
                                                        size: 14,
                                                        color: context
                                                            .semanticColors
                                                            .success,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          '${(log['name'] ?? '-')}: +${((log['kcal'] as num?)?.toInt() ?? 0)} kcal · ${((log['minutes'] as num?)?.toInt() ?? 0)} min',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                  color: cs
                                                                      .onSurfaceVariant),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          if (_exerciseLogs.isNotEmpty) ...[
                                            Column(
                                              children: [
                                                for (final log
                                                    in (_exerciseExpanded
                                                        ? _exerciseLogs
                                                        : _exerciseLogs
                                                            .take(2)))
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .watch_later_outlined,
                                                        size: 14,
                                                        color: context
                                                            .semanticColors
                                                            .success,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Builder(
                                                            builder: (context) {
                                                          final dt = DateTime.tryParse(
                                                                  (log['savedAt']
                                                                          as String?) ??
                                                                      '') ??
                                                              DateTime.now();
                                                          final hh = dt.hour
                                                              .toString()
                                                              .padLeft(2, '0');
                                                          final mm = dt.minute
                                                              .toString()
                                                              .padLeft(2, '0');
                                                          return Text(
                                                            '${(log['name'] ?? '-')}: +${((log['kcal'] as num?)?.toInt() ?? 0)} kcal · ${((log['minutes'] as num?)?.toInt() ?? 0)} min · $hh:$mm',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .labelSmall
                                                                ?.copyWith(
                                                                    color: cs
                                                                        .onSurfaceVariant),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                onPressed: () => setState(() =>
                                                    _exerciseExpanded =
                                                        !_exerciseExpanded),
                                                icon: Icon(_exerciseExpanded
                                                    ? Icons.expand_less
                                                    : Icons.expand_more),
                                                label:
                                                    Builder(builder: (context) {
                                                  final extra =
                                                      (_exerciseLogs.length > 2)
                                                          ? (_exerciseLogs
                                                                  .length -
                                                              2)
                                                          : 0;
                                                  return Text(_exerciseExpanded
                                                      ? 'Mostrar menos'
                                                      : (extra > 0
                                                          ? 'Ver todos (+$extra)'
                                                          : 'Ver todos'));
                                                }),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Builder(builder: (context) {
                                            final w = MediaQuery.of(context)
                                                .size
                                                .width;
                                            final double space =
                                                w < 360 ? 6.0 : 8.0;
                                            final double rspace =
                                                w < 360 ? 4.0 : 6.0;
                                            return Wrap(
                                              spacing: space,
                                              runSpacing: rspace,
                                              children: [
                                                _quickActivityChip(
                                                    AppLocalizations.of(context)!.walkingMinutes(30), () {
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.exerciseLogging,
                                                      arguments: {
                                                        'date': _selectedDate
                                                            .toIso8601String(),
                                                        'activityName':
                                                            AppLocalizations.of(context)!.walking,
                                                        'minutes': 30,
                                                        'intensity': 1,
                                                      }).then(
                                                      (_) => _loadExercise());
                                                }),
                                                _quickActivityChip(
                                                    AppLocalizations.of(context)!.runningMinutes(20), () {
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.exerciseLogging,
                                                      arguments: {
                                                        'date': _selectedDate
                                                            .toIso8601String(),
                                                        'activityName':
                                                            AppLocalizations.of(context)!.running,
                                                        'minutes': 20,
                                                        'intensity': 2,
                                                      }).then(
                                                      (_) => _loadExercise());
                                                }),
                                                _quickActivityChip(AppLocalizations.of(context)!.cyclingMinutes(30),
                                                    () {
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.exerciseLogging,
                                                      arguments: {
                                                        'date': _selectedDate
                                                            .toIso8601String(),
                                                        'activityName':
                                                            AppLocalizations.of(context)!.cycling,
                                                        'minutes': 30,
                                                        'intensity': 1,
                                                      }).then(
                                                      (_) => _loadExercise());
                                                }),
                                              ],
                                            );
                                          }),
                                          if (_exerciseLogs.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Divider(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant
                                                  .withValues(alpha: 0.2),
                                              height: 1,
                                            ),
                                            const SizedBox(height: 12),
                                            Builder(builder: (context) {
                                              final totalMinutes = _exerciseLogs
                                                  .fold<int>(
                                                      0,
                                                      (sum, log) =>
                                                          sum +
                                                          (((log['minutes']
                                                                      as num?)
                                                                  ?.toInt() ??
                                                              0)));
                                              final totalKcal = _exerciseLogs
                                                  .fold<int>(
                                                      0,
                                                      (sum, log) =>
                                                          sum +
                                                          (((log['kcal']
                                                                      as num?)
                                                                  ?.toInt() ??
                                                              0)));
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Today',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  Text(
                                                    '$totalMinutes min • $totalKcal kcal',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: context
                                                              .semanticColors
                                                              .success,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Material(
                                color: AppTheme.activeBlue,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _addExercise,
                                  child: const Icon(Icons.add,
                                      size: 22, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
                }),

                // Macronutrient progress bars removed to avoid duplication (summary already shows macros)
                const SizedBox.shrink(),

                // YAZIO-like: omit weekly progress and floating actions from top area
                SizedBox(height: 0.6.h),
              ],
            ),
          ),
        ),
      ),
      // Multi-Action FAB - substitui botão fixo "Add Meal"
      floatingActionButton: MultiActionFab(
        onAddMeal: _showMealSelectionDialog,
        onAddWater: () async {
          final ml = await NutritionStorage.addWaterMl(_selectedDate, 250);
          if (!mounted) return;
          setState(() {
            _dailyData["waterMl"] = ml;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Água registrada: +250ml (total ' + ml.toString() + 'ml)'),
              backgroundColor: AppTheme.successGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onAddActivity: () async {
          await Navigator.pushNamed(context, AppRoutes.exerciseLogging,
              arguments: {'date': _selectedDate.toIso8601String()});
          if (!mounted) return;
          await _loadExercise();
          await _loadToday();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );

    return Stack(
      children: [
        scaffold,
        if (_showOnboarding) _buildOnboardingOverlay(),
      ],
    );
  }

  Widget _buildOnboardingOverlay() {
    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.6)),
        if (_onboardingStep == 0)
          CoachMark(
            message:
                'Use este botão para adicionar refeições, água e atividades rapidamente.',
            buttonText: 'Próximo',
            onDismiss: _dismissOnboarding,
            targetPosition:
                Offset(0, MediaQuery.of(context).size.height - 220),
            direction: CoachMarkDirection.top,
          ),
        if (_onboardingStep == 1)
          CoachMark(
            message:
                'Veja seu anel de calorias e macronutrientes no topo do Diário.',
            buttonText: 'Próximo',
            onDismiss: _dismissOnboarding,
            targetPosition: const Offset(0, 140),
            direction: CoachMarkDirection.bottom,
          ),
        if (_onboardingStep == 1)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissOnboarding,
              ),
            ),
          ),
        if (_onboardingStep == 2)
          CoachMark(
            message: 'Navegue entre os dias usando as setas do app bar.',
            buttonText: 'Entendi',
            onDismiss: _dismissOnboarding,
            targetPosition: const Offset(0, 100),
            direction: CoachMarkDirection.bottom,
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final navBg = theme.bottomNavigationBarTheme.backgroundColor ?? cs.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão "Add Meal" removido conforme solicitado

        // Bottom Navigation Bar
        Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
              break; // Diário
            case 1:
              Navigator.pushNamed(
                  context, AppRoutes.intermittentFastingTracker);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.recipeBrowser);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
            case 4:
              Navigator.pushNamed(context, AppRoutes.aiCoachChat);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined,
                 size: AppIcons.md,
                 color: AppIcons.standard()),
            activeIcon: Icon(Icons.calendar_today,
                 size: AppIcons.md,
                 color: AppIcons.active()),
            label: AppLocalizations.of(context)!.navDiary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined,
                 size: AppIcons.md,
                 color: AppIcons.standard()),
            activeIcon: Icon(Icons.schedule,
                 size: AppIcons.md,
                 color: AppIcons.active()),
            label: AppLocalizations.of(context)!.navFasting,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined,
                 size: AppIcons.md,
                 color: AppIcons.standard()),
            activeIcon: Icon(Icons.restaurant_menu,
                 size: AppIcons.md,
                 color: AppIcons.active()),
            label: AppLocalizations.of(context)!.navRecipes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline,
                 size: AppIcons.md,
                 color: AppIcons.standard()),
            activeIcon: Icon(Icons.person,
                 size: AppIcons.md,
                 color: AppIcons.active()),
            label: AppLocalizations.of(context)!.navProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined,
                 size: AppIcons.md,
                 color: AppIcons.standard()),
            activeIcon: Icon(Icons.smart_toy,
                 size: AppIcons.md,
                 color: AppIcons.active()),
            label: AppLocalizations.of(context)!.navCoach,
          ),
        ],
          ),
        ),
      ],
    );
  }

  // Modal para selecionar tipo de refeição
  void _showMealSelectionDialog() {
    final meals = [
      (AppLocalizations.of(context)!.mealBreakfast, AppIcons.mealBreakfast, 'breakfast'),
      (AppLocalizations.of(context)!.mealLunch, AppIcons.mealLunch, 'lunch'),
      (AppLocalizations.of(context)!.mealDinner, AppIcons.mealDinner, 'dinner'),
      (AppLocalizations.of(context)!.mealSnack, AppIcons.mealSnack, 'snack'),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.dashboardAddMeal,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...meals.map((meal) => ListTile(
              leading: Icon(meal.$2,
                  size: AppIcons.md,
                  color: AppIcons.standard()),
              title: Text(meal.$1),
              trailing: Icon(Icons.chevron_right,
                  size: AppIcons.sm,
                  color: AppIcons.secondary()),
              onTap: () {
                Navigator.pop(context);
                // Navegar para tela de adicionar alimento para esta refeição
                // Por enquanto, apenas fecha o modal
              },
            )),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
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
                AppLocalizations.of(context)!.remainingPlural,
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
            '${_fmtInt(value)} kcal',
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
                AppLocalizations.of(context)!
                    .remainingGrams((macro["total"] - macro["consumed"]) as int),
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
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: AppTheme.activeBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
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
                AppLocalizations.of(context)!.close,
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
              content: Text(AppLocalizations.of(context)!.noMealsToDuplicateToday),
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
            content: Text(AppLocalizations.of(context)!.mealDuplicated(lastMealTime)),
            backgroundColor: AppTheme.successGreen),
      );
    } catch (_) {}
  }

  // ignore: unused_element
  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final sheetColors = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.search, color: sheetColors.onSurface),
                title: const Text('Buscar alimento'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openFoodLogging();
                },
              ),
              ListTile(
                leading: Icon(Icons.star, color: sheetColors.onSurface),
                title: const Text('Favoritos'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/food-logging-screen',
                      arguments: {'activeTab': 'favorites'});
                },
              ),
              ListTile(
                leading: Icon(Icons.restaurant, color: sheetColors.onSurface),
                title: const Text('Meus Alimentos'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/food-logging-screen',
                      arguments: {'activeTab': 'mine'});
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.playlist_add, color: sheetColors.onSurface),
                title: Text(AppLocalizations.of(context)!.duplicateLastMealTitle),
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
    final prevConsumed = _dailyData["consumedCalories"] as int? ?? 0;
    final prevAllMeals = _mealTotals.values
        .every((m) => (m['kcal'] ?? 0) > 0);
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

    // Optional toasts
    try {
      final totalGoal = _dailyData["totalCalories"] as int? ?? 0;
      if (totalGoal > 0 && prevConsumed < totalGoal && consumed >= totalGoal) {
        HapticHelper.success();
        ToastManager.showAchievement(
          context: context,
          title: AppStrings.achievementCaloriesTitle,
          message: AppStrings.achievementCaloriesMessage(totalGoal),
          emoji: AppStrings.emojiCalories,
        );
      }
      final nowAllMeals = _mealTotals.values
          .every((m) => (m['kcal'] ?? 0) > 0);
      if (!prevAllMeals && nowAllMeals) {
        HapticHelper.success();
        ToastManager.showAchievement(
          context: context,
          title: AppStrings.achievementAllMealsTitle,
          message: AppStrings.achievementAllMealsMessage,
          emoji: AppStrings.emojiMeals,
        );
      }
    } catch (_) {}
  }

  void _checkMealExceeds() {
    final Map<String, String> labels = {
      'breakfast': AppLocalizations.of(context)!.mealBreakfast,
      'lunch': AppLocalizations.of(context)!.mealLunch,
      'dinner': AppLocalizations.of(context)!.mealDinner,
      'snack': AppLocalizations.of(context)!.mealSnack,
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
        _currentWeek = _computeIsoWeekNumber(_selectedDate);
      });
    }
  }

  Future<void> _loadExercise() async {
    final prev = _dailyData["spentCalories"] as int? ?? 0;
    final kcal = await NutritionStorage.getExerciseCalories(_selectedDate);
    if (!mounted) return;
    final meta = await NutritionStorage.getExerciseMeta(_selectedDate);
    final logs = await NutritionStorage.getExerciseLogs(_selectedDate);
    if (!mounted) return;
    setState(() {
      _dailyData["spentCalories"] = kcal;
      _lastExerciseMeta = meta;
      _exerciseLogs = logs.reversed.toList();
    });
    try {
      final goals = await UserPreferences.getGoals();
      final g = goals.exerciseGoalKcal;
      if (g > 0 && prev < g && kcal >= g) {
        HapticHelper.success();
        if (mounted) {
          ToastManager.showAchievement(
            context: context,
            title: AppStrings.achievementActivitiesTitle,
            message: AppStrings.achievementActivitiesMessage(g),
            emoji: AppStrings.emojiActivities,
          );
        }
      }
    } catch (_) {}
    await _updateHydrationAchievements();
    await _updateExerciseStreak();
  }

  void _addWater() {
    final prev = _dailyData["waterMl"] as int? ?? 0;
    final goal = _dailyData["waterGoalMl"] as int? ?? 0;
    NutritionStorage.addWaterMl(_selectedDate, 250).then((ml) {
      if (!mounted) return;
      setState(() {
        _dailyData["waterMl"] = ml;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Água registrada: +250ml (total ' + ml.toString() + 'ml)'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      if (prev < goal && ml >= goal && goal > 0) {
        HapticHelper.success();
        ToastManager.showAchievement(
          context: context,
          title: 'Meta de água atingida!',
          message: 'Você bateu sua meta diária de hidratação.',
          emoji: '💧',
        );
      } else {
        HapticHelper.light();
      }
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
            child: Text(AppLocalizations.of(context)!.cancel,
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
            child: Text(AppLocalizations.of(context)!.save),
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
        title: Text(AppLocalizations.of(context)!.adjustMacroGoals,
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
            child: Text(AppLocalizations.of(context)!.cancel,
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
                  content: Text(AppLocalizations.of(context)!.macroGoalsUpdated),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.save),
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
        title: Text(AppLocalizations.of(context)!.goalsPerMealTitle,
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
              Text(AppLocalizations.of(context)!.mealSnack,
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
            child: Text(AppLocalizations.of(context)!.cancel,
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
                  content: Text(AppLocalizations.of(context)!.goalsPerMealUpdated),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.save),
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
          content: Text('Água ajustada: -250ml (total ' + ml.toString() + 'ml)'),
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
    if (mounted) {
      setState(() {
        _hydrationStreak = streak;
      });
    }
  }

  Future<void> _updateExerciseStreak() async {
    final goal = await UserPreferences.getExerciseGoal();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final d =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
              .subtract(Duration(days: i));
      final ex = await NutritionStorage.getExerciseCalories(d);
      if (goal > 0 && ex >= goal) {
        streak += 1;
      } else {
        break;
      }
    }
    if (!mounted) return;
    setState(() => _exerciseStreak = streak);
  }

  void _addExercise() async {
    await Navigator.pushNamed(context, AppRoutes.exerciseLogging,
        arguments: {'date': _selectedDate.toIso8601String()});
    if (!mounted) return;
    await _loadExercise();
    await _loadToday();
  }

  void _openEditExerciseGoalDialog(int current) {
    final ctl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta de exercício (kcal)'),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ex.: 300'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () async {
              final v = int.tryParse(ctl.text.trim());
              if (v != null) await UserPreferences.setExerciseGoal(v);
              if (!mounted) return;
              Navigator.pop(ctx);
              setState(() {});
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
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
                      _addMealButton(AppLocalizations.of(context)!.mealBreakfast, 'breakfast', tappedDay),
                      _addMealButton(AppLocalizations.of(context)!.mealLunch, 'lunch', tappedDay),
                      _addMealButton(AppLocalizations.of(context)!.mealDinner, 'dinner', tappedDay),
                      _addMealButton(AppLocalizations.of(context)!.mealSnack, 'snack', tappedDay),
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
                                  child: Text(AppLocalizations.of(context)!.cancel,
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
                                        content: const Text('Meta de água atualizada'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)!.save),
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
                                  child: Text(AppLocalizations.of(context)!.cancel,
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
                                  child: Text(AppLocalizations.of(context)!.save),
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
    final t = AppLocalizations.of(context)!;
    final mealOptions = [
      {'key': 'breakfast', 'label': t.mealBreakfast},
      {'key': 'lunch', 'label': t.mealLunch},
      {'key': 'dinner', 'label': t.mealDinner},
      {'key': 'snack', 'label': t.mealSnack},
    ];
    String selectedMeal = (entry['mealTime'] as String?) ?? 'snack';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final colors = context.colors;
            final textStyles = context.textStyles;
            return AlertDialog(
              backgroundColor: colors.surfaceContainerHigh,
              title: Text(
                'Editar item',
                style: textStyles.titleLarge?.copyWith(
                  color: colors.onSurface,
                ),
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
                    value: selectedMeal,
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
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: textStyles.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
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
                  child: Text(AppLocalizations.of(context)!.duplicate),
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
                  child: Text(AppLocalizations.of(context)!.save),
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
                // Streak chips + badges row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _waterStreakChip(),
                    const SizedBox(width: 8),
                    _fastingStreakChip(),
                    const SizedBox(width: 8),
                    _caloriesStreakChip(),
                    const SizedBox(width: 8),
                    _proteinStreakChip(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AchievementBadgesWidget(
                        achievements: _achievements,
                        onBadgeTap: (a) => _showBadgeDetails(a),
                      ),
                    ),
                  ],
                ),
                Text(AppLocalizations.of(context)!.dayActions,
                    style: AppTheme.darkTheme.textTheme.titleLarge
                        ?.copyWith(color: AppTheme.textPrimary)),
                SizedBox(height: 1.5.h),
                ListTile(
                  leading: Icon(Icons.local_fire_department,
                      color: context.semanticColors.warning),
                  title: Text('Visão geral da sequência',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.streakOverview);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.bookmark_border,
                      color: Theme.of(context).colorScheme.onSurface),
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
                  title: Text(AppLocalizations.of(context)!.duplicateDayTomorrowTitle, style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
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
                  title: Text(AppLocalizations.of(context)!.duplicateDayPickDateTitle, style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
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
                  title: Text(AppLocalizations.of(context)!.duplicateNewPickDateTitle,
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
                              Text(AppLocalizations.of(context)!.noNewItemsToDuplicate),
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
                        title: Text(AppLocalizations.of(context)!.selectItemsToDuplicateTitle,
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
                            child: Text(AppLocalizations.of(context)!.cancel,
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
                            child: Text(AppLocalizations.of(context)!.cancel,
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
                                        Text(AppLocalizations.of(context)!.chooseFileCsv),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel,
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
            child: Text(AppLocalizations.of(context)!.cancel,
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
            child: Text(AppLocalizations.of(context)!.save),
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
            child: Text(
              AppLocalizations.of(context)!.close,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
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










