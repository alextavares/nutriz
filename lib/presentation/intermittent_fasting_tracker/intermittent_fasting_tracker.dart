import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import '../common/celebration_overlay.dart';
import '../../services/gamification_engine.dart';
import '../../services/streak_service.dart';

import '../../core/app_export.dart';
import '../../theme/design_tokens.dart';
import './widgets/achievements_widget.dart';
import './widgets/fasting_method_selector_widget.dart';
import './widgets/fasting_timer_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/weekly_calendar_widget.dart';
import '../../services/fasting_storage.dart';
import '../../services/notifications_service.dart';
import '../../services/user_preferences.dart';

class IntermittentFastingTracker extends StatefulWidget {
  const IntermittentFastingTracker({Key? key}) : super(key: key);

  @override
  State<IntermittentFastingTracker> createState() =>
      _IntermittentFastingTrackerState();
}

class _IntermittentFastingTrackerState extends State<IntermittentFastingTracker>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // Fasting state
  bool _isFasting = false;
  String _selectedMethod = "16:8";
  DateTime? _fastingStartTime;
  Duration? _activeTarget; // when fasting: total target duration
  Duration _customTarget = const Duration(hours: 14);
  String _tzName = '';
  DateTime? _muteUntil;

  // Notification settings
  bool _notificationsEnabled = true;
  TimeOfDay? _startEatingTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _stopEatingTime = const TimeOfDay(hour: 20, minute: 0);

  // Statistics
  int _currentStreak = 7;
  int _totalFastingDays = 45;
  int _longestStreak = 12;
  int _fastingStreak = 0;
  bool _showNextMilestoneCaptions = true;

  // Weekly fasting summary (loaded from storage)
  List<Map<String, dynamic>> _weeklyData = [
    {
      "date": DateTime.now().subtract(const Duration(days: 6)),
      "completed": true,
      "duration": 16
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "completed": true,
      "duration": 18
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 4)),
      "completed": true,
      "duration": 16
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "completed": false,
      "duration": 0
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "completed": true,
      "duration": 20
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "completed": true,
      "duration": 16
    },
    {"date": DateTime.now(), "completed": false, "duration": 0},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      "title": "Primeiro Jejum",
      "description": "Complete seu primeiro jejum",
      "unlocked": true,
      "progress": 1.0,
      "target": 1
    },
    {
      "title": "Sequência 7",
      "description": "7 dias consecutivos",
      "unlocked": true,
      "progress": 1.0,
      "target": 7
    },
    {
      "title": "Mestre 16:8",
      "description": "30 jejuns 16:8",
      "unlocked": false,
      "progress": 0.6,
      "target": 30
    },
    {
      "title": "Guerreiro",
      "description": "Complete um 20:4",
      "unlocked": true,
      "progress": 1.0,
      "target": 1
    },
    {
      "title": "Consistente",
      "description": "30 dias de jejum",
      "unlocked": false,
      "progress": 0.75,
      "target": 30
    },
    {
      "title": "Lenda",
      "description": "100 dias total",
      "unlocked": false,
      "progress": 0.45,
      "target": 100
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _initializeFastingData();
    _loadUiPrefs();
    UserPreferences.changes.addListener(_onUiPrefsChanged);
    // Ask permission early if notifications are enabled
    if (_notificationsEnabled) {
      NotificationsService.requestPermissionsIfNeeded();
    }
    _initTimezoneName();
    _initMuteUntil();
    _refreshFastingStreak();
  }

  Future<void> _loadUiPrefs() async {
    final show = await UserPreferences.getShowNextMilestoneCaptions();
    if (!mounted) return;
    setState(() => _showNextMilestoneCaptions = show);
  }

  Widget _journeyClockPanel() {
    final Duration target =
        _activeTarget ?? _getMethodDuration(_selectedMethod);
    final double targetHours =
        target.inMinutes <= 0 ? 1 : target.inMinutes / 60.0;
    final colorScheme = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final List<Map<String, dynamic>> bars = _weeklyData.take(7).toList();
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double scale = textScaler.scale(1);
    final double barAreaHeight = math.max(150.0, 120.0 * scale.clamp(1.0, 1.4));
    final bool showTopLabels = scale <= 1.2;
    final double topLabelHeight = showTopLabels ? 18.0 * scale : 0.0;
    final double effectiveBarHeight = barAreaHeight - topLabelHeight;
    final List<DateTime> labelDays = bars.isEmpty
        ? List.generate(
            7, (index) => DateTime.now().subtract(Duration(days: 6 - index)))
        : bars.map((entry) => entry['date'] as DateTime).toList();

    Widget buildBarsRow() {
      final List<Widget> children = (bars.isEmpty
              ? _buildPlaceholderBars(barAreaHeight)
              : bars.map((entry) {
                  return _buildJourneyBarColumn(
                    entry: entry,
                    targetHours: targetHours,
                    textScale: scale,
                    barAreaHeight: barAreaHeight,
                    effectiveBarHeight: effectiveBarHeight,
                    topLabelHeight: topLabelHeight,
                    showTopLabel: showTopLabels,
                  );
                }).toList())
          .map((child) => Expanded(child: child))
          .toList();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final bool compact = maxWidth < 360;
              final double chipWidth =
                  math.max(120, math.min(220, maxWidth * 0.45));
              final Widget chip = _buildMethodBadge(context, chipWidth);
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: Colors.lightBlueAccent, size: 20),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.fastingSchedules,
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.0.h),
                    chip,
                  ],
                );
              }
              return Row(
                children: [
                  const Icon(Icons.schedule,
                      color: Colors.lightBlueAccent, size: 20),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.fastingSchedules,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: chip,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 1.6.h),
          SizedBox(
            height: barAreaHeight,
            child: buildBarsRow(),
          ),
          SizedBox(height: 1.0.h),
          Row(
            children: labelDays
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          _weekdayLabel(day),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 1.0.h),
          Row(
            children: [
              Icon(Icons.restaurant,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.eatingWindow(_formatTimeOfDay(_stopEatingTime), _formatTimeOfDay(_startEatingTime)),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyBarColumn({
    required Map<String, dynamic> entry,
    required double targetHours,
    required double textScale,
    required double barAreaHeight,
    required double effectiveBarHeight,
    required double topLabelHeight,
    required bool showTopLabel,
  }) {
    final double durationHours =
        ((entry['duration'] as num?)?.toDouble() ?? 0).clamp(0, 72);
    final bool completed = (entry['completed'] as bool?) ?? false;
    final double ratio = targetHours <= 0 ? 0 : durationHours / targetHours;
    final double clampedRatio = ratio.clamp(0.0, 1.3);
    final double minVisible = 6.0;
    final double barHeight =
        math.max(minVisible, effectiveBarHeight * (clampedRatio / 1.3));
    final double barWidth = math.max(14.0, 12.0 * textScale.clamp(1.0, 1.3));
    final colorScheme = context.colors;
    final textStyles = context.textStyles;
    final Color base = completed
        ? colorScheme.primary
        : colorScheme.primary.withValues(alpha: 0.55);

    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withValues(alpha: 0.95),
        base.withValues(alpha: 0.65),
      ],
    );

    final String hoursLabel = durationHours == 0
        ? '--'
        : (durationHours % 1 == 0
            ? '${durationHours.toInt()}h'
            : '${durationHours.toStringAsFixed(1)}h');

    return SizedBox(
      height: barAreaHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showTopLabel)
            SizedBox(
              height: topLabelHeight,
              child: Center(
                child: Text(
                  hoursLabel,
                  style: textStyles.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Container(
            height: barHeight,
            width: barWidth,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: barHeight > 20
                  ? [
                      BoxShadow(
                        color: base.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaceholderBars(double barAreaHeight) {
    final Color fill = context.colors.outline.withValues(alpha: 0.35);
    return List.generate(7, (_) {
      return SizedBox(
        height: barAreaHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 36,
              width: 16,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMethodBadge(BuildContext context, double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _methodDisplayName(_selectedMethod),
            style: context.textStyles.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  String _methodDisplayName(String method) {
    final t = AppLocalizations.of(context)!;
    switch (method) {
      case '16:8':
        return t.fastingMethod168;
      case '18:6':
        return t.fastingMethod186;
      case '20:4':
        return t.fastingMethod204;
      case 'custom':
        final hours = _customTarget.inHours;
        return hours > 0 ? t.fastingMethodCustom(hours) : 'Custom';
      default:
        return t.fastingMethodLabel(method);
    }
  }

  String _weekdayLabel(DateTime day) {
    final String? code = Localizations.maybeLocaleOf(context)?.languageCode;
    final bool isPortuguese = code != null && code.toLowerCase() == 'pt';
    const pt = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final labels = isPortuguese ? pt : en;
    return labels[(day.weekday - 1) % 7];
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    try {
      UserPreferences.changes.removeListener(_onUiPrefsChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTimezoneChangeAndReschedule();
    }
  }

  void _initializeFastingData() {
    // load active session + weekly summary from storage
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _customTarget = await FastingStorage.getCustomTarget();
    final active = await FastingStorage.getActive();
    if (!mounted) return;
    if (active != null) {
      final now = DateTime.now();
      final elapsed = now.difference(active.start);
      final remain = active.target - elapsed;
      if (remain.isNegative || remain == Duration.zero) {
        // Consider completed
        await FastingStorage.stopNow();
        setState(() {
          _isFasting = false;
          _fastingStartTime = null;
          });
      } else {
        setState(() {
          _isFasting = true;
          _selectedMethod = active.method;
          _fastingStartTime = active.start;
          _activeTarget = active.target;
        });
      }
    }
    await _loadWeekAndStats();
    // Apply daily reminders if enabled and times are set
    if (_notificationsEnabled) {
      _updateDailyFastingReminders();
    }
    _initTimezoneName();
  }

  void _onUiPrefsChanged() {
    _loadUiPrefs();
  }

  Future<void> _initTimezoneName() async {
    final name = await NotificationsService.getLocalTimezoneName();
    if (!mounted) return;
    setState(() => _tzName = name);
  }

  Future<void> _checkTimezoneChangeAndReschedule() async {
    final name = await NotificationsService.getLocalTimezoneName();
    if (name != _tzName) {
      setState(() => _tzName = name);
      // Reschedule daily reminders
      if (_notificationsEnabled) {
        _updateDailyFastingReminders();
      }
      // Reschedule end-of-fast if active
      if (_notificationsEnabled &&
          _isFasting &&
          _fastingStartTime != null &&
          _activeTarget != null) {
        final now = DateTime.now();
        if (_muteUntil != null && now.isBefore(_muteUntil!)) return;
        NotificationsService.cancelFastingEnd();
        final endAt = _fastingStartTime!.add(_activeTarget!);
        NotificationsService.scheduleFastingEnd(
          endAt: endAt,
          method: _selectedMethod,
          title: AppLocalizations.of(context)!.notifFastingEndTitle,
          body: AppLocalizations.of(context)!
              .notifFastingEndBody(_selectedMethod),
          channelName: AppLocalizations.of(context)!.channelFastingName,
          channelDescription:
              AppLocalizations.of(context)!.channelFastingDescription,
        );
      }
    }
  }

  Future<void> _loadWeekAndStats() async {
    // Build week summary from storage
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final hist = await FastingStorage.getHistoryInRange(monday, sunday);
    if (!mounted) return;
    setState(() {
      _weeklyData = List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final h = hist.firstWhere(
          (e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day,
          orElse: () =>
              (date: day, duration: Duration.zero, method: _selectedMethod),
        );
        return {
          'date': day,
          'completed': h.duration.inHours >= 12,
          'duration': h.duration.inHours,
        };
      });
    });
    final total = await FastingStorage.getTotalFastingDays();
    final streak = await FastingStorage.getCurrentStreak();
    if (!mounted) return;
    setState(() {
      _totalFastingDays = total;
      _currentStreak = streak;
      if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
    });
  }

  Duration _getMethodDuration(String method) {
    switch (method) {
      case "16:8":
        return const Duration(hours: 16);
      case "18:6":
        return const Duration(hours: 18);
      case "20:4":
        return const Duration(hours: 20);
      case "custom":
        return _customTarget; // Custom duration from storage/state
      default:
        return const Duration(hours: 16);
    }
  }

  void _startFasting() {
    final start = DateTime.now();
    final target = _getMethodDuration(_selectedMethod);
    setState(() {
      _isFasting = true;
      _fastingStartTime = start;
      _activeTarget = target;
    });
    FastingStorage.start(method: _selectedMethod, start: start, target: target);
    // Schedule end notification
    final endAt = start.add(target);
    if (_notificationsEnabled) {
      final now = DateTime.now();
      final mutedActive = _muteUntil != null && now.isBefore(_muteUntil!);
      if (!mutedActive) {
        NotificationsService.scheduleFastingEnd(
          endAt: endAt,
          method: _selectedMethod,
          title: AppLocalizations.of(context)!.notifFastingEndTitle,
          body: AppLocalizations.of(context)!
              .notifFastingEndBody(_selectedMethod),
          channelName: AppLocalizations.of(context)!.channelFastingName,
          channelDescription:
              AppLocalizations.of(context)!.channelFastingDescription,
        );
      } else {
        // Warn user that notifications are muted
        final u = _muteUntil!;
        String two(int v) => v.toString().padLeft(2, '0');
        final label =
            '${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notificationsMutedUntil(label)),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.reactivate,
              onPressed: () async {
                await NotificationsService.setFastingMuteUntil(null);
                if (!mounted) return;
                setState(() => _muteUntil = null);
                _updateDailyFastingReminders();
                // schedule end-of-fast now
                NotificationsService.scheduleFastingEnd(
                  endAt: endAt,
                  method: _selectedMethod,
                  title: AppLocalizations.of(context)!.notifFastingEndTitle,
                  body: AppLocalizations.of(context)!
                      .notifFastingEndBody(_selectedMethod),
                  channelName: AppLocalizations.of(context)!.channelFastingName,
                  channelDescription: AppLocalizations.of(context)!
                      .channelFastingDescription,
                );
              },
              textColor: context.semanticColors.success,
            ),
            backgroundColor:
                context.colors.onSurfaceVariant.withValues(alpha: 0.3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.fastStarted(_selectedMethod),
            style: context.textStyles.bodyMedium
                ?.copyWith(color: context.colors.onSurface)),
        backgroundColor: context.semanticColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
  }

  void _stopFasting() {
    if (_fastingStartTime == null) return;
    NotificationsService.cancelFastingEnd();
    FastingStorage.stopNow().then((fastingDuration) async {
      final fd = fastingDuration ?? Duration.zero;
      final hours = fd.inHours;
      setState(() {
        _isFasting = false;
        _fastingStartTime = null;
      });
      await _loadWeekAndStats();
      await _refreshFastingStreak();
      // Gamification: celebrate once per day
      final celebrate = await GamificationEngine.I.fire(
        GamificationEvent(
            type: GamificationEventType.goalCompleted,
            metaKey: 'fasting',
            value: fd.inSeconds),
      );
      if (celebrate && mounted)
        await CelebrationOverlay.maybeShow(context,
            variant: CelebrationVariant.goal);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.fastCompleted(hours, fd.inMinutes.remainder(60)),
              style: context.textStyles.bodyMedium
                  ?.copyWith(color: context.colors.onSurface)),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
    });
  }

  void _onTimerComplete() {
    NotificationsService.cancelFastingEnd();
    FastingStorage.stopNow().then((d) async {
      final celebrate = await GamificationEngine.I.fire(
        GamificationEvent(
            type: GamificationEventType.goalCompleted,
            metaKey: 'fasting',
            value: (d ?? Duration.zero).inSeconds),
      );
      if (celebrate && mounted)
        await CelebrationOverlay.maybeShow(context,
            variant: CelebrationVariant.goal);
    });
    setState(() {
      _isFasting = false;
    });
    _loadWeekAndStats();
    _refreshFastingStreak();

    // Show completion celebration
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: context.colors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Row(children: [
                CustomIconWidget(
                    iconName: 'celebration',
                    color: context.semanticColors.premium,
                    size: 24),
                SizedBox(width: 2.w),
                Text(AppLocalizations.of(context)!.congratulations,
                    style: context.textStyles.titleLarge?.copyWith(
                        color: context.colors.onSurface, fontSize: 18.sp)),
              ]),
              content: Text(
                  AppLocalizations.of(context)!.fastCompletedSuccess(_selectedMethod),
                  style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant, fontSize: 14.sp)),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: context.semanticColors.success,
                        foregroundColor: context.colors.onSurface),
                    child: Text(AppLocalizations.of(context)!.continueLabel,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w500))),
              ]);
        });
  }

  Future<void> _refreshFastingStreak() async {
    final v = await StreakService.currentStreak('fasting');
    if (!mounted) return;
    setState(() => _fastingStreak = v);
  }

  void _onMethodSelected(String method) {
    if (_isFasting) {
      // Avoid changing method during active fast
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.stopCurrentFastToChangeMethod),
        backgroundColor: context.semanticColors.warning,
      ));
      return;
    }
    if (method == 'custom') {
      _promptCustomMethod();
    } else {
      setState(() {
        _selectedMethod = method;
      });
    }
  }

  void _promptCustomMethod() {
    int hours = _customTarget.inHours.clamp(10, 24);
    int minutes = (_customTarget.inMinutes % 60);
    final minuteOptions = <int>[0, 15, 30, 45];
    if (!minuteOptions.contains(minutes)) minutes = 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateBS) {
          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.defineCustomMethod,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: context.colors.onSurface,
                    )),
                SizedBox(height: 1.h),
                Text(AppLocalizations.of(context)!.fastingDuration,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    )),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: hours.toDouble(),
                        min: 10,
                        max: 24,
                        divisions: 14,
                        label: '${hours}h',
                        onChanged: (v) => setStateBS(() => hours = v.round()),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text('${hours}h',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(AppLocalizations.of(context)!.minutes,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    )),
                SizedBox(height: 0.5.h),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in minuteOptions)
                      ChoiceChip(
                        label: Text('${m}m'),
                        selected: minutes == m,
                        onSelected: (sel) => setStateBS(() => minutes = m),
                        selectedColor:
                            context.colors.primary.withValues(alpha: 0.2),
                        labelStyle: context.textStyles.bodySmall?.copyWith(
                          color: minutes == m
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clamp minutes to 0 if hours == 24
                      final mm = hours >= 24 ? 0 : minutes;
                      final d = Duration(hours: hours, minutes: mm);
                      await FastingStorage.setCustomTarget(d);
                      if (!mounted) return;
                      setState(() {
                        _customTarget = d;
                        _selectedMethod = 'custom';
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.semanticColors.success,
                      foregroundColor: context.colors.onSurface,
                    ),
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  void _updateDailyFastingReminders() {
    final se = _startEatingTime;
    final st = _stopEatingTime;
    if (se == null || st == null) {
      NotificationsService.cancelDailyFastingReminders();
      return;
    }
    final now = DateTime.now();
    if (_muteUntil != null && now.isBefore(_muteUntil!)) {
      // keep muted; do not schedule
      NotificationsService.cancelDailyFastingReminders();
      return;
    }
    NotificationsService.scheduleDailyFastingReminders(
      startEatingHour: se.hour,
      startEatingMinute: se.minute,
      stopEatingHour: st.hour,
      stopEatingMinute: st.minute,
      openTitle: AppLocalizations.of(context)!.notifFastingOpenTitle,
      openBody: AppLocalizations.of(context)!.notifFastingOpenBody,
      startTitle: AppLocalizations.of(context)!.notifFastingStartTitle,
      startBody: AppLocalizations.of(context)!.notifFastingStartBody,
      channelName: AppLocalizations.of(context)!.channelFastingName,
      channelDescription:
          AppLocalizations.of(context)!.channelFastingDescription,
    );
  }

  Future<void> _initMuteUntil() async {
    final m = await NotificationsService.getFastingMuteUntil();
    if (!mounted) return;
    setState(() => _muteUntil = m);
  }

  void _onDayTap(DateTime day) {
    final dayData = _weeklyData.firstWhere(
        (data) => _isSameDay(data["date"] as DateTime, day),
        orElse: () => {"date": day, "completed": false, "duration": 0});

    if (dayData["completed"] as bool) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                backgroundColor: context.colors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(AppLocalizations.of(context)!.fastingOfDay('${day.day}/${day.month}'),
                    style: context.textStyles.titleMedium?.copyWith(
                        color: context.colors.onSurface, fontSize: 16.sp)),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CustomIconWidget(
                            iconName: 'schedule',
                            color: context.semanticColors.success,
                            size: 20),
                        SizedBox(width: 2.w),
                        Text(AppLocalizations.of(context)!.duration(dayData["duration"]),
                            style: context.textStyles.bodyMedium?.copyWith(
                                color: context.colors.onSurface,
                                fontSize: 14.sp)),
                      ]),
                      SizedBox(height: 1.h),
                      Row(children: [
                        CustomIconWidget(
                            iconName: 'check_circle',
                            color: context.semanticColors.success,
                            size: 20),
                        SizedBox(width: 2.w),
                        Text(AppLocalizations.of(context)!.fastCompletedSuccessfully,
                            style: context.textStyles.bodyMedium?.copyWith(
                                color: context.semanticColors.success,
                                fontSize: 14.sp)),
                      ]),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.close,
                          style: TextStyle(
                              color: context.colors.primary, fontSize: 14.sp))),
                ]);
          });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
            backgroundColor: context.colors.surface,
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.intermittentFasting,
                style: context.textStyles.titleLarge?.copyWith(
                    color: context.colors.onSurface,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600)),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: context.colors.onSurface,
                    size: 24)),
            actions: [
              IconButton(
                  onPressed: () {
                    // Navigate to settings or help
                  },
                  icon: CustomIconWidget(
                      iconName: 'help_outline',
                      color: context.colors.onSurfaceVariant,
                      size: 24)),
            ]),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(height: 2.h),

          // Fasting Timer (YAZIO-like card)
          Builder(builder: (context) {
            final total = _activeTarget ?? _getMethodDuration(_selectedMethod);
            // Compute dynamic remaining if active
            final remaining = (_isFasting && _fastingStartTime != null)
                ? (total - DateTime.now().difference(_fastingStartTime!))
                : total;
            final safeRemaining =
                remaining.isNegative ? Duration.zero : remaining;
            final DateTime? startAt = _isFasting ? _fastingStartTime : null;
            final DateTime? endAt =
                (_isFasting && _fastingStartTime != null) ? _fastingStartTime!.add(total) : null;
            return FastingTimerCard(
              isFasting: _isFasting,
              remainingTime: safeRemaining,
              totalDuration: total,
              onTimerComplete: _onTimerComplete,
              onPrimaryAction: _isFasting ? _stopFasting : _startFasting,
              primaryActionLabel: _isFasting ? AppLocalizations.of(context)!.endFastButton : AppLocalizations.of(context)!.startFastButton,
              startAt: startAt,
              endAt: endAt,
            );
          }),
          SizedBox(height: 1.h),
          if (_tzName.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: context.colors.outline.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.timezone(_tzName),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          if (_isFasting && _fastingStartTime != null) ...[
            Builder(builder: (context) {
              final total =
                  _activeTarget ?? _getMethodDuration(_selectedMethod);
              final endAt = _fastingStartTime!.add(total);
              final hh = endAt.hour.toString().padLeft(2, '0');
              final mm = endAt.minute.toString().padLeft(2, '0');
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_circle,
                      size: 16, color: context.colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.endsAt('$hh:$mm'),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.semanticColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: context.semanticColors.warning
                          .withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: context.semanticColors.warning, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _fastingStreak > 0
                          ? AppLocalizations.of(context)!.fastingDays(_fastingStreak)
                          : AppLocalizations.of(context)!.noFastingStreak,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (const {3, 5, 7, 14, 30}.contains(_fastingStreak)) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.star, color: context.semanticColors.warning, size: 14),
                    ],
                    if (_showNextMilestoneCaptions)
                      ...(() {
                        final thresholds = [3, 5, 7, 14, 30];
                        int? next;
                        for (final t in thresholds) {
                          if (_fastingStreak < t) {
                            next = t;
                            break;
                          }
                        }
                        if (next == null) return <Widget>[];
                        return [
                          const SizedBox(width: 6),
                          Text('• próx: ${next}d',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              )),
                        ];
                      })(),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 3.h),
          _journeyClockPanel(),
          SizedBox(height: 3.h),

          // Fasting Method Selector
          FastingMethodSelectorWidget(
              selectedMethod: _selectedMethod,
              onMethodSelected: _onMethodSelected),

          SizedBox(height: 4.h),

          // Control button moved into FastingTimerCard (CTA)
          SizedBox(height: 2.h),

          // Weekly Calendar
          WeeklyCalendarWidget(
              weeklyData: _weeklyData,
              currentStreak: _currentStreak,
              onDayTap: _onDayTap),

          SizedBox(height: 3.h),

          // Achievements
          AchievementsWidget(
              achievements: _achievements,
              totalFastingDays: _totalFastingDays,
              longestStreak: _longestStreak),

          SizedBox(height: 3.h),

          // Notification Settings
          NotificationSettingsWidget(
              notificationsEnabled: _notificationsEnabled,
              startEatingTime: _startEatingTime,
              stopEatingTime: _stopEatingTime,
              timezoneName: _tzName,
              muteUntil: _muteUntil,
              fastEndAt: (() {
                if (!_notificationsEnabled) return null;
                if (!_isFasting ||
                    _fastingStartTime == null ||
                    _activeTarget == null) return null;
                // If muted, don't show end notification time
                final now = DateTime.now();
                if (_muteUntil != null && now.isBefore(_muteUntil!))
                  return null;
                return _fastingStartTime!.add(_activeTarget!);
              })(),
              onMute24h: () async {
                final until = DateTime.now().add(const Duration(hours: 24));
                await NotificationsService.setFastingMuteUntil(until);
                await NotificationsService.cancelDailyFastingReminders();
                await NotificationsService.cancelFastingEnd();
                if (!mounted) return;
                setState(() => _muteUntil = until);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.remindersMuted24h),
                    backgroundColor: context.semanticColors.warning,
                  ),
                );
              },
              onUnmuteNow: () async {
                await NotificationsService.setFastingMuteUntil(null);
                if (!mounted) return;
                setState(() => _muteUntil = null);
                _updateDailyFastingReminders();
                // If there is an active fast, reschedule end notification
                if (_notificationsEnabled &&
                    _isFasting &&
                    _fastingStartTime != null &&
                    _activeTarget != null) {
                  final endAt = _fastingStartTime!.add(_activeTarget!);
                  NotificationsService.scheduleFastingEnd(
                    endAt: endAt,
                    method: _selectedMethod,
                    title: AppLocalizations.of(context)!.notifFastingEndTitle,
                    body: AppLocalizations.of(context)!
                        .notifFastingEndBody(_selectedMethod),
                    channelName:
                        AppLocalizations.of(context)!.channelFastingName,
                    channelDescription: AppLocalizations.of(context)!
                        .channelFastingDescription,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.remindersReactivated),
                    backgroundColor: context.semanticColors.success,
                  ),
                );
              },
              onMuteTomorrow: () async {
                final now = DateTime.now();
                final tomorrow = DateTime(now.year, now.month, now.day)
                    .add(const Duration(days: 1));
                final until =
                    DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
                await NotificationsService.setFastingMuteUntil(until);
                await NotificationsService.cancelDailyFastingReminders();
                await NotificationsService.cancelFastingEnd();
                if (!mounted) return;
                setState(() => _muteUntil = until);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.remindersMutedTomorrow),
                    backgroundColor: context.semanticColors.warning,
                  ),
                );
              },
              onNotificationToggle: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                if (value) {
                  NotificationsService.requestPermissionsIfNeeded();
                  _updateDailyFastingReminders();
                } else {
                  NotificationsService.cancelDailyFastingReminders();
                }
              },
              onStartTimeChanged: (time) async {
                setState(() {
                  _startEatingTime = time;
                });
                // Persist
                if (time != null) {
                  await UserPreferences.setEatingTimes(
                      startHour: time.hour, startMinute: time.minute);
                }
                if (_notificationsEnabled) _updateDailyFastingReminders();
              },
              onStopTimeChanged: (time) async {
                setState(() {
                  _stopEatingTime = time;
                });
                if (time != null) {
                  await UserPreferences.setEatingTimes(
                      stopHour: time.hour, stopMinute: time.minute);
                }
                if (_notificationsEnabled) _updateDailyFastingReminders();
              }),

          SizedBox(height: 4.h),
        ])),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                boxShadow: [
                  BoxShadow(
                      color: context.theme.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, -2)),
                ]),
            child: TabBar(
                controller: _tabController,
                indicatorWeight: 2,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacementNamed(
                          context, '/daily-tracking-dashboard');
                      break;
                    case 1:
                      // Current screen - Jejum
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(
                          context, '/recipe-browser');
                      break;
                    case 3:
                      // Navigate to profile
                      break;
                    case 4:
                      // Navigate to PRO
                      break;
                  }
                },
                tabs: [
                  Tab(
                      icon: const CustomIconWidget(
                          iconName: 'dashboard',
                          size: 20),
                      text: AppLocalizations.of(context)!.navDiary),
                  Tab(
                      icon: const CustomIconWidget(
                          iconName: 'schedule',
                          size: 20),
                      text: AppLocalizations.of(context)!.navFasting),
                  Tab(
                      icon: const CustomIconWidget(
                          iconName: 'restaurant_menu',
                          size: 20),
                      text: AppLocalizations.of(context)!.navRecipes),
                  Tab(
                      icon: const CustomIconWidget(
                          iconName: 'person',
                          size: 20),
                      text: AppLocalizations.of(context)!.navProfile),
                  Tab(
                      icon: const CustomIconWidget(
                          iconName: 'star',
                          size: 20),
                      text: 'PRO'),
                ])));
  }
}

