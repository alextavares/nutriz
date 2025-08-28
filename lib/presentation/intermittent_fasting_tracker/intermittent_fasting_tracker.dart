import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievements_widget.dart';
import './widgets/fasting_control_button_widget.dart';
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
  Duration _remainingTime = const Duration(hours: 16);
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
    // Ask permission early if notifications are enabled
    if (_notificationsEnabled) {
      NotificationsService.requestPermissionsIfNeeded();
    }
    _initTimezoneName();
    _initMuteUntil();
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
          _remainingTime = Duration.zero;
        });
      } else {
        setState(() {
          _isFasting = true;
          _selectedMethod = active.method;
          _fastingStartTime = active.start;
          _remainingTime = active.target; // keep for display
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
      if (_notificationsEnabled && _isFasting && _fastingStartTime != null && _activeTarget != null) {
        final now = DateTime.now();
        if (_muteUntil != null && now.isBefore(_muteUntil!)) return;
        NotificationsService.cancelFastingEnd();
        final endAt = _fastingStartTime!.add(_activeTarget!);
        NotificationsService.scheduleFastingEnd(endAt: endAt, method: _selectedMethod);
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
          (e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day,
          orElse: () => (date: day, duration: Duration.zero, method: _selectedMethod),
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
      _remainingTime = target;
      _activeTarget = target;
    });
    FastingStorage.start(method: _selectedMethod, start: start, target: target);
    // Schedule end notification
    final endAt = start.add(target);
    if (_notificationsEnabled) {
      final now = DateTime.now();
      final mutedActive = _muteUntil != null && now.isBefore(_muteUntil!);
      if (!mutedActive) {
        NotificationsService.scheduleFastingEnd(endAt: endAt, method: _selectedMethod);
      } else {
        // Warn user that notifications are muted
        final u = _muteUntil!;
        String two(int v) => v.toString().padLeft(2, '0');
        final label = '${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificações silenciadas até $label'),
            action: SnackBarAction(
              label: 'Reativar',
              onPressed: () async {
                await NotificationsService.setFastingMuteUntil(null);
                if (!mounted) return;
                setState(() => _muteUntil = null);
                _updateDailyFastingReminders();
                // schedule end-of-fast now
                NotificationsService.scheduleFastingEnd(endAt: endAt, method: _selectedMethod);
              },
              textColor: AppTheme.successGreen,
            ),
            backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Jejum iniciado! Método $_selectedMethod',
            style: AppTheme.darkTheme.textTheme.bodyMedium
                ?.copyWith(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.successGreen,
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
        _remainingTime = Duration.zero;
      });
      await _loadWeekAndStats();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Jejum finalizado! Duração: ${hours}h ${fd.inMinutes.remainder(60)}min',
              style: AppTheme.darkTheme.textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.textPrimary)),
          backgroundColor: AppTheme.activeBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
    });
  }

  void _onTimerComplete() {
    NotificationsService.cancelFastingEnd();
    FastingStorage.stopNow();
    setState(() {
      _isFasting = false;
      _remainingTime = Duration.zero;
    });
    _loadWeekAndStats();

    // Show completion celebration
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: AppTheme.secondaryBackgroundDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Row(children: [
                CustomIconWidget(
                    iconName: 'celebration',
                    color: AppTheme.premiumGold,
                    size: 24),
                SizedBox(width: 2.w),
                Text('Parabéns!',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary, fontSize: 18.sp)),
          ]),
          content: Text(
              'Você completou seu jejum $_selectedMethod com sucesso! 🎉',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary, fontSize: 14.sp)),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: AppTheme.textPrimary),
                    child: Text('Continuar',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w500))),
              ]);
        });
  }

  void _onMethodSelected(String method) {
    if (_isFasting) {
      // Avoid changing method during active fast
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Finalize o jejum atual para alterar o método'),
        backgroundColor: AppTheme.warningAmber,
      ));
      return;
    }
    if (method == 'custom') {
      _promptCustomMethod();
    } else {
      setState(() {
        _selectedMethod = method;
        _remainingTime = _getMethodDuration(method);
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
      backgroundColor: AppTheme.secondaryBackgroundDark,
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
                Text('Definir método personalizado',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    )),
                SizedBox(height: 1.h),
                Text('Duração do jejum',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
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
                        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.activeBlue,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                SizedBox(height: 1.h),
                Text('Minutos',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
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
                        selectedColor: AppTheme.activeBlue.withValues(alpha: 0.2),
                        labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: minutes == m ? AppTheme.activeBlue : AppTheme.textSecondary,
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
                        _remainingTime = _getMethodDuration('custom');
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: const Text('Salvar'),
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
                backgroundColor: AppTheme.secondaryBackgroundDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text('Jejum de ${day.day}/${day.month}',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary, fontSize: 16.sp)),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.successGreen,
                            size: 20),
                        SizedBox(width: 2.w),
                        Text('Duração: ${dayData["duration"]}h',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14.sp)),
                      ]),
                      SizedBox(height: 1.h),
                      Row(children: [
                        CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.successGreen,
                            size: 20),
                        SizedBox(width: 2.w),
                        Text('Jejum completado com sucesso',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                                    color: AppTheme.successGreen,
                                    fontSize: 14.sp)),
                      ]),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Fechar',
                          style: TextStyle(
                              color: AppTheme.activeBlue, fontSize: 14.sp))),
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
        backgroundColor: AppTheme.primaryBackgroundDark,
        appBar: AppBar(
            backgroundColor: AppTheme.primaryBackgroundDark,
            elevation: 0,
            title: Text('Jejum Intermitente',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600)),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textPrimary,
                    size: 24)),
            actions: [
              IconButton(
                  onPressed: () {
                    // Navigate to settings or help
                  },
                  icon: CustomIconWidget(
                      iconName: 'help_outline',
                      color: AppTheme.textSecondary,
                      size: 24)),
            ]),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(height: 2.h),

          // Fasting Timer
          Builder(builder: (context) {
            final total = _activeTarget ?? _getMethodDuration(_selectedMethod);
            // Compute dynamic remaining if active
            final remaining = (_isFasting && _fastingStartTime != null)
                ? (total - DateTime.now().difference(_fastingStartTime!))
                : total;
            final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
            return FastingTimerWidget(
              isFasting: _isFasting,
              remainingTime: safeRemaining,
              totalDuration: total,
              onTimerComplete: _onTimerComplete,
            );
          }),
          SizedBox(height: 1.h),
          if (_tzName.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundDark,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Fuso: $_tzName',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          if (_isFasting && _fastingStartTime != null) ...[
            Builder(builder: (context) {
              final total = _activeTarget ?? _getMethodDuration(_selectedMethod);
              final endAt = _fastingStartTime!.add(total);
              final hh = endAt.hour.toString().padLeft(2, '0');
              final mm = endAt.minute.toString().padLeft(2, '0');
              return Text(
                'Termina às $hh:$mm',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],

          SizedBox(height: 4.h),

          // Fasting Method Selector
          FastingMethodSelectorWidget(
              selectedMethod: _selectedMethod,
              onMethodSelected: _onMethodSelected),

          SizedBox(height: 4.h),

          // Control Button
          Builder(builder: (context) {
            final now = DateTime.now();
            final mutedActive = _notificationsEnabled && _muteUntil != null && now.isBefore(_muteUntil!);
            return FastingControlButtonWidget(
              isFasting: _isFasting,
              onStartFasting: _startFasting,
              onStopFasting: _stopFasting,
              muted: !_isFasting && mutedActive,
              muteUntil: _muteUntil,
            );
          }),

          SizedBox(height: 4.h),

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
                if (!_isFasting || _fastingStartTime == null || _activeTarget == null) return null;
                // If muted, don't show end notification time
                final now = DateTime.now();
                if (_muteUntil != null && now.isBefore(_muteUntil!)) return null;
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
                    content: const Text('Lembretes silenciados por 24h'),
                    backgroundColor: AppTheme.warningAmber,
                  ),
                );
              },
              onUnmuteNow: () async {
                await NotificationsService.setFastingMuteUntil(null);
                if (!mounted) return;
                setState(() => _muteUntil = null);
                _updateDailyFastingReminders();
                // If there is an active fast, reschedule end notification
                if (_notificationsEnabled && _isFasting && _fastingStartTime != null && _activeTarget != null) {
                  final endAt = _fastingStartTime!.add(_activeTarget!);
                  NotificationsService.scheduleFastingEnd(endAt: endAt, method: _selectedMethod);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Lembretes reativados'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              onMuteTomorrow: () async {
                final now = DateTime.now();
                final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
                final until = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
                await NotificationsService.setFastingMuteUntil(until);
                await NotificationsService.cancelDailyFastingReminders();
                await NotificationsService.cancelFastingEnd();
                if (!mounted) return;
                setState(() => _muteUntil = until);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lembretes silenciados até amanhã 08:00'),
                    backgroundColor: AppTheme.warningAmber,
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
                color: AppTheme.secondaryBackgroundDark,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.shadowDark,
                      blurRadius: 8,
                      offset: const Offset(0, -2)),
                ]),
            child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.activeBlue,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.activeBlue,
                indicatorWeight: 3,
                labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                    ?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTheme.darkTheme.textTheme.bodySmall
                    ?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w400),
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
                      icon: CustomIconWidget(
                          iconName: 'dashboard',
                          color: _tabController.index == 0
                              ? AppTheme.activeBlue
                              : AppTheme.textSecondary,
                          size: 20),
                      text: 'Diário'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'schedule',
                          color: _tabController.index == 1
                              ? AppTheme.activeBlue
                              : AppTheme.textSecondary,
                          size: 20),
                      text: 'Jejum'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'restaurant_menu',
                          color: _tabController.index == 2
                              ? AppTheme.activeBlue
                              : AppTheme.textSecondary,
                          size: 20),
                      text: 'Receitas'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'person',
                          color: _tabController.index == 3
                              ? AppTheme.activeBlue
                              : AppTheme.textSecondary,
                          size: 20),
                      text: 'Perfil'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'star',
                          color: _tabController.index == 4
                              ? AppTheme.premiumGold
                              : AppTheme.textSecondary,
                          size: 20),
                      text: 'PRO'),
                ])));
  }
}
