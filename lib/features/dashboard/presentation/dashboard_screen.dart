import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../presentation/nutrition_details_screen/nutrition_details_screen.dart';
import 'dashboard_view_model.dart';
import 'widgets/dashboard_hero_widget.dart';
import 'widgets/meal_card_widget.dart';
import 'widgets/water_tracker_widget.dart';
import 'widgets/activities_widget.dart';
import 'widgets/measurements_widget.dart';
import 'widgets/daily_note_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = DashboardViewModel();
        // Para testar o banner, descomente uma das linhas abaixo:
        // vm.debugStartFasting(elapsed: const Duration(hours: 4, minutes: 32));
        vm.debugStartEatingWindow(elapsed: const Duration(hours: 2, minutes: 15));
        return vm;
      },
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  Timer? _fastingTimer;
  late PageController _pageController;
  
  // Página central (hoje) - permite navegar para trás infinitamente
  static const int _initialPage = 10000;
  int _currentPage = _initialPage;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    
    // Atualiza o timer do jejum a cada 30 segundos
    _fastingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final vm = Provider.of<DashboardViewModel>(context, listen: false);
      vm.refreshFastingTimer();
    });
  }

  @override
  void dispose() {
    _fastingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getDateForPage(int page) {
    final diff = page - _initialPage;
    return DateTime.now().add(Duration(days: diff));
  }

  void _onPageChanged(int page, DashboardViewModel vm) {
    if (_isAnimating) return;
    
    final newDate = _getDateForPage(page);
    
    // Não permitir ir para o futuro além de hoje
    if (newDate.isAfter(DateTime.now())) {
      // Volta para a página atual
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }
    
    setState(() {
      _currentPage = page;
    });
    vm.changeDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, vm),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => _onPageChanged(page, vm),
              itemBuilder: (context, index) {
                return _buildDayContent(context, vm);
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DashboardViewModel vm) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 4.w,
      title: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: vm.selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context),
                child: child!,
              );
            },
          );
          if (date != null) {
            _goToDate(date, vm);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('EEE, d MMM').format(vm.selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                  ),
                ),
                Icon(Icons.arrow_drop_down, 
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ],
            ),
            Text(
              'Week ${_getWeekNumber(vm.selectedDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Gamification Icons - Diamond (Points)
        Padding(
          padding: EdgeInsets.only(right: 1.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 4),
              Text('0', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Gamification Icons - Fire (Streak)
        Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_outlined, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text('0', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Profile/Settings Icon
        IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  void _goToDate(DateTime date, DashboardViewModel vm) {
    final today = DateTime.now();
    final diff = date.difference(DateTime(today.year, today.month, today.day)).inDays;
    final targetPage = _initialPage + diff;
    
    setState(() {
      _isAnimating = true;
    });
    
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      setState(() {
        _currentPage = targetPage;
        _isAnimating = false;
      });
      vm.changeDate(date);
    });
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return ((daysDiff + firstDayOfYear.weekday) / 7).ceil();
  }

  Widget _buildDayContent(BuildContext context, DashboardViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          children: [
            // Hero Section (Calories Ring)
            DashboardHeroWidget(
              caloriesConsumed: vm.caloriesConsumed,
              caloriesGoal: vm.calorieGoal,
              caloriesBurned: vm.exerciseBurned,
              carbsConsumed: vm.carbsConsumed,
              carbsGoal: vm.carbsGoal,
              proteinConsumed: vm.proteinConsumed,
              proteinGoal: vm.proteinGoal,
              fatConsumed: vm.fatConsumed,
              fatGoal: vm.fatGoal,
              // Fasting props
              isFasting: vm.isFasting,
              isEatingWindow: vm.isEatingWindow,
              fastingStatus: vm.fastingStatus,
              fastingElapsed: vm.fastingElapsed,
              fastingGoal: vm.fastingGoal,
              onFastingTap: () {
                Navigator.pushNamed(context, '/fasting');
              },
            ),
            SizedBox(height: 3.h),

            // Nutrition Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nutrição',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionDetailsScreen(
                            caloriesConsumed: vm.caloriesConsumed,
                            caloriesGoal: vm.calorieGoal,
                            carbsConsumed: vm.carbsConsumed,
                            carbsGoal: vm.carbsGoal,
                            proteinConsumed: vm.proteinConsumed,
                            proteinGoal: vm.proteinGoal,
                            fatConsumed: vm.fatConsumed,
                            fatGoal: vm.fatGoal,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Mais',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),

            // Meals
            ...vm.entriesByMeal.entries.map((entry) {
              final mealName = entry.key;
              final foods = entry.value;
              int mealCals = 0;
              for (var f in foods) {
                mealCals += (f['calories'] as num?)?.toInt() ?? 0;
              }

              String displayTitle = mealName;
              switch (mealName) {
                case 'breakfast': displayTitle = 'Café da Manhã'; break;
                case 'lunch': displayTitle = 'Almoço'; break;
                case 'dinner': displayTitle = 'Jantar'; break;
                case 'snack': displayTitle = 'Lanches'; break;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: MealCardWidget(
                  title: displayTitle,
                  iconAsset: '',
                  totalCalories: mealCals,
                  calorieGoal: vm.getMealCalorieGoal(mealName),
                  foods: foods,
                  onAddTap: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.foodLogging, 
                      arguments: {'mealName': mealName, 'date': vm.selectedDate}
                    ).then((_) => vm.loadData());
                  },
                ),
              );
            }).toList(),

            SizedBox(height: 1.h),

            // Water Tracker
            WaterTrackerWithButtonsWidget(
              currentMl: vm.waterConsumed,
              goalMl: vm.waterGoal,
              onAdd: (amount) => vm.addWater(amount),
            ),
            SizedBox(height: 3.h),

            // Notes
            DailyNoteWidget(
              note: vm.dailyNote,
              onAddNote: () {
                Navigator.pushNamed(context, AppRoutes.notes).then((_) => vm.loadData());
              },
            ),
            SizedBox(height: 3.h),

            // Measurements
            MeasurementsWidget(
              currentWeight: vm.currentWeight,
              goalWeight: vm.weightGoal,
              onWeightChanged: (newWeight) {
                vm.updateWeight(newWeight);
              },
              onMoreTap: () {
                Navigator.pushNamed(context, AppRoutes.bodyMetrics).then((_) => vm.loadData());
              },
            ),
            SizedBox(height: 3.h),

            // Activities
            ActivitiesWidget(
              onConnectTap: () {
                // TODO: Connect Google Fit / Health Connect
              },
            ),
            
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
