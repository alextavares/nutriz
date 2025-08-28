import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/nutrition_summary_card.dart';
import './widgets/quick_actions_grid.dart';
import './widgets/todays_meals_list.dart';
import './widgets/water_intake_tracker.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

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
      return 'Hoje';
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
    const weekdays = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return weekdays[date.weekday % 7];
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
          'Dashboard',
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

                SizedBox(height: 3.h),

                // Quick Actions
                Text(
                  'Ações Rápidas',
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
                      'Refeições de Hoje',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.foodLogging);
                      },
                      child: Text(
                        'Ver Todas',
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
          Navigator.pushNamed(context, AppRoutes.foodLogging);
        },
        backgroundColor: AppTheme.activeBlue,
        foregroundColor: AppTheme.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Refeição'),
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
}