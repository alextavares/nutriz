import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'widgets/meal_timing_selector_widget.dart';

class AddFoodEntryScreen extends StatefulWidget {
  const AddFoodEntryScreen({super.key});

  @override
  State<AddFoodEntryScreen> createState() => _AddFoodEntryScreenState();
}

class _AddFoodEntryScreenState extends State<AddFoodEntryScreen> {
  String _selectedMealTime = 'lunch';
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    // Read initial meal and date from route args
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final dynamic meal = args['mealKey'] ?? args['mealName'];
        if (meal is String && meal.isNotEmpty) {
          _mapMealNameToKey(meal);
        }
        final dynamic dateArg = args['targetDate'];
        if (dateArg is DateTime) {
          _targetDate = DateTime(dateArg.year, dateArg.month, dateArg.day);
        } else if (dateArg is String) {
          try {
            final parsed = DateTime.parse(dateArg);
            _targetDate = DateTime(parsed.year, parsed.month, parsed.day);
          } catch (_) {}
        }
        setState(() {});
      }
    });
  }

  void _mapMealNameToKey(String mealName) {
    final normalized = mealName.toLowerCase();
    if (normalized.contains('café') ||
        normalized.contains('manha') ||
        normalized.contains('manhã') ||
        normalized.contains('breakfast')) {
      _selectedMealTime = 'breakfast';
      return;
    }
    if (normalized.contains('almoço') ||
        normalized.contains('almoco') ||
        normalized.contains('lunch')) {
      _selectedMealTime = 'lunch';
      return;
    }
    if (normalized.contains('jantar') || normalized.contains('dinner')) {
      _selectedMealTime = 'dinner';
      return;
    }
    if (normalized.contains('lanche') || normalized.contains('snack')) {
      _selectedMealTime = 'snack';
      return;
    }
  }

  String _mealLabel() {
    switch (_selectedMealTime) {
      case 'breakfast':
        return 'café da manhã';
      case 'lunch':
        return 'almoço';
      case 'dinner':
        return 'jantar';
      case 'snack':
        return 'lanche';
      default:
        return _selectedMealTime;
    }
  }

  Map<String, dynamic> _baseArgs() => {
        'mealKey': _selectedMealTime,
        if (_targetDate != null) 'targetDate': _targetDate!.toIso8601String(),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: cs.onSurface,
                          size: 5.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mealLabel(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Meal selector (chips)
              MealTimingSelectorWidget(
                selectedMealTime: _selectedMealTime,
                onMealTimeChanged: (m) => setState(() => _selectedMealTime = m),
              ),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Como deseja registrar?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 1.2.h),

              // Big actions: Photo, Search, Scan
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    _actionCard(
                      color: AppTheme.activeBlue,
                      icon: 'photo_camera',
                      title: 'Registre por foto',
                      subtitle:
                          'Use a câmera para identificar e registrar seu alimento',
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.aiFoodDetection,
                        );
                        if (!mounted) return;
                        if (result is Map<String, dynamic>) {
                          final args = {
                            ..._baseArgs(),
                            'prefillFood': result,
                          };
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.foodLogging,
                            arguments: args,
                          );
                        } else if (result is List) {
                          final args = {
                            ..._baseArgs(),
                            'prefillFoods': result,
                          };
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.foodLogging,
                            arguments: args,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 1.2.h),
                    _actionCard(
                      color: AppTheme.successGreen,
                      icon: 'search',
                      title: 'Pesquisar alimento',
                      subtitle: 'Busque por nome, marca ou tipo de alimento',
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.foodLogging,
                          arguments: {
                            ..._baseArgs(),
                            'activeTab': 'recent',
                          },
                        );
                      },
                    ),
                    SizedBox(height: 1.2.h),
                    _actionCard(
                      color: AppTheme.warningAmber,
                      icon: 'qr_code_scanner',
                      title: 'Escanear código de barras',
                      subtitle: 'Leia o código de barras do produto',
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.foodLogging,
                          arguments: {
                            ..._baseArgs(),
                            'openScanner': true,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard({
    required Color color,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 7.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      letterSpacing: -0.1,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ],
        ),
      ),
    );
  }
}
