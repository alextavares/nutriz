import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/activities_section_widget.dart';
import './widgets/meal_category_widget.dart';
import './widgets/premium_subscription_banner_widget.dart';

class DetailedMealTrackingScreen extends StatefulWidget {
  const DetailedMealTrackingScreen({super.key});

  @override
  State<DetailedMealTrackingScreen> createState() =>
      _DetailedMealTrackingScreenState();
}

class _DetailedMealTrackingScreenState
    extends State<DetailedMealTrackingScreen> {
  final List<Map<String, dynamic>> _meals = [
    {
      'name': 'Café da manhã',
      'currentCalories': 0,
      'targetCalories': 0,
      'icon': 'hourglass',
      'hasFood': false,
      'foods': <String>[],
    },
    {
      'name': 'Almoço',
      'currentCalories': 0,
      'targetCalories': 934,
      'icon': 'bowl',
      'hasFood': false,
      'foods': <String>[],
    },
    {
      'name': 'Jantar',
      'currentCalories': 126,
      'targetCalories': 934,
      'icon': 'bowl',
      'hasFood': true,
      'foods': ['Pão de forma'],
    },
    {
      'name': 'Lanches',
      'currentCalories': 0,
      'targetCalories': 0,
      'icon': 'hourglass',
      'hasFood': false,
      'foods': <String>[],
    },
  ];

  void _onMealTap(String mealName) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.foodLogging,
      arguments: mealName,
    );
  }

  void _onAddButtonTap(String mealName) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.foodLogging,
      arguments: mealName,
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    // Simulate sync with server
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh meal data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Premium subscription banner
                  const PremiumSubscriptionBannerWidget(),

                  const SizedBox(height: 24),

                  // Alimentação section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alimentação',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Handle "Mais" action
                        },
                        child: Text(
                          'Mais',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Meal categories
                  ...List.generate(_meals.length, (index) {
                    final meal = _meals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MealCategoryWidget(
                        mealName: meal['name'] as String,
                        currentCalories: meal['currentCalories'] as int,
                        targetCalories: meal['targetCalories'] as int,
                        iconType: meal['icon'] as String,
                        hasFood: meal['hasFood'] as bool,
                        foods: meal['foods'] as List<String>,
                        onTap: () => _onMealTap(meal['name'] as String),
                        onAddTap: () => _onAddButtonTap(meal['name'] as String),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Activities section
                  const ActivitiesSectionWidget(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
