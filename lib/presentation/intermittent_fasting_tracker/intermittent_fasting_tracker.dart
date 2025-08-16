
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievements_widget.dart';
import './widgets/fasting_control_button_widget.dart';
import './widgets/fasting_method_selector_widget.dart';
import './widgets/fasting_timer_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/weekly_calendar_widget.dart';

class IntermittentFastingTracker extends StatefulWidget {
  const IntermittentFastingTracker({Key? key}) : super(key: key);

  @override
  State<IntermittentFastingTracker> createState() =>
      _IntermittentFastingTrackerState();
}

class _IntermittentFastingTrackerState extends State<IntermittentFastingTracker>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Fasting state
  bool _isFasting = false;
  String _selectedMethod = "16:8";
  Duration _remainingTime = const Duration(hours: 16);
  DateTime? _fastingStartTime;

  // Notification settings
  bool _notificationsEnabled = true;
  TimeOfDay? _startEatingTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _stopEatingTime = const TimeOfDay(hour: 20, minute: 0);

  // Statistics
  int _currentStreak = 7;
  int _totalFastingDays = 45;
  int _longestStreak = 12;

  // Mock data
  final List<Map<String, dynamic>> _weeklyData = [
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
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _initializeFastingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeFastingData() {
    // Initialize with mock fasting session if needed
    if (_isFasting && _fastingStartTime != null) {
      final elapsed = DateTime.now().difference(_fastingStartTime!);
      final totalDuration = _getMethodDuration(_selectedMethod);
      _remainingTime = totalDuration - elapsed;

      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        _isFasting = false;
      }
    }
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
        return const Duration(hours: 14); // Default custom duration
      default:
        return const Duration(hours: 16);
    }
  }

  void _startFasting() {
    setState(() {
      _isFasting = true;
      _fastingStartTime = DateTime.now();
      _remainingTime = _getMethodDuration(_selectedMethod);
    });

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
    if (_fastingStartTime != null) {
      final fastingDuration = DateTime.now().difference(_fastingStartTime!);
      final hours = fastingDuration.inHours;

      setState(() {
        _isFasting = false;
        _fastingStartTime = null;
        _remainingTime = Duration.zero;

        // Update statistics if fasting was significant
        if (hours >= 12) {
          _totalFastingDays++;
          _currentStreak++;
          if (_currentStreak > _longestStreak) {
            _longestStreak = _currentStreak;
          }
        }
      });

      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Jejum finalizado! Duração: ${hours}h ${fastingDuration.inMinutes.remainder(60)}min',
              style: AppTheme.darkTheme.textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.textPrimary)),
          backgroundColor: AppTheme.activeBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
    }
  }

  void _onTimerComplete() {
    setState(() {
      _isFasting = false;
      _remainingTime = Duration.zero;
      _totalFastingDays++;
      _currentStreak++;
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
    });

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
    setState(() {
      _selectedMethod = method;
      if (!_isFasting) {
        _remainingTime = _getMethodDuration(method);
      }
    });
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
          FastingTimerWidget(
              isFasting: _isFasting,
              remainingTime: _remainingTime,
              onTimerComplete: _onTimerComplete),

          SizedBox(height: 4.h),

          // Fasting Method Selector
          FastingMethodSelectorWidget(
              selectedMethod: _selectedMethod,
              onMethodSelected: _onMethodSelected),

          SizedBox(height: 4.h),

          // Control Button
          FastingControlButtonWidget(
              isFasting: _isFasting,
              onStartFasting: _startFasting,
              onStopFasting: _stopFasting),

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
              onNotificationToggle: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              onStartTimeChanged: (time) {
                setState(() {
                  _startEatingTime = time;
                });
              },
              onStopTimeChanged: (time) {
                setState(() {
                  _stopEatingTime = time;
                });
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
