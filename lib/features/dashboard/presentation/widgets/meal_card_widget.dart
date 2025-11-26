import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/app_export.dart';

/// Yazio-style meal card with emoji icon, arrow indicator, and calorie progress
class MealCardWidget extends StatelessWidget {
  final String title;
  final String iconAsset;
  final int totalCalories;
  final int? calorieGoal; // Optional goal for this meal
  final List<Map<String, dynamic>> foods;
  final VoidCallback onAddTap;
  final VoidCallback? onCardTap; // Tap to expand/view details

  const MealCardWidget({
    Key? key,
    required this.title,
    required this.iconAsset,
    required this.totalCalories,
    this.calorieGoal,
    required this.foods,
    required this.onAddTap,
    this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Colors matching Yazio style
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final addButtonBg = AppTheme.activeBlue;
    final addButtonIcon = Colors.white;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCardTap ?? onAddTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
            child: Column(
              children: [
                // Main Row
                Row(
                  children: [
                    // Emoji/Icon Container
                    _buildMealIcon(),
                    SizedBox(width: 3.w),
                    
                    // Title + Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with Arrow
                          Row(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: textSecondary,
                              ),
                            ],
                          ),
                          SizedBox(height: 0.3.h),
                          // Calorie Progress
                          Text(
                            _buildCalorieText(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add Button (Yazio style - circular, subtle)
                    GestureDetector(
                      onTap: onAddTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: addButtonBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: addButtonIcon,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Food List (if any)
                if (foods.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : const Color(0xFFF3F4F6)),
                  SizedBox(height: 1.h),
                  ...foods.map((food) => _buildFoodItem(food, textPrimary, textSecondary!)).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildCalorieText() {
    if (calorieGoal != null && calorieGoal! > 0) {
      return '$totalCalories / $calorieGoal Cal';
    }
    return '$totalCalories Cal';
  }

  Widget _buildMealIcon() {
    // Emoji-style icons like Yazio uses
    final mealData = _getMealIconData(title);
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: mealData.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          mealData.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food, Color textPrimary, Color textSecondary) {
    final name = food['name'] ?? 'Alimento';
    final calories = food['calories'] ?? 0;
    final quantity = food['quantity'] ?? '';
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          // Food name and quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (quantity.toString().isNotEmpty)
                  Text(
                    quantity.toString(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Calories
          Text(
            '$calories Cal',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  _MealIconData _getMealIconData(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('café') || lowerTitle.contains('breakfast') || lowerTitle.contains('manhã')) {
      return _MealIconData(
        emoji: '🥤',
        backgroundColor: const Color(0xFFE3F2FD), // Light blue
      );
    }
    if (lowerTitle.contains('almoço') || lowerTitle.contains('lunch')) {
      return _MealIconData(
        emoji: '🍝',
        backgroundColor: const Color(0xFFFFF3E0), // Light orange
      );
    }
    if (lowerTitle.contains('jantar') || lowerTitle.contains('dinner')) {
      return _MealIconData(
        emoji: '🥗',
        backgroundColor: const Color(0xFFE8F5E9), // Light green
      );
    }
    if (lowerTitle.contains('lanche') || lowerTitle.contains('snack')) {
      return _MealIconData(
        emoji: '🍎',
        backgroundColor: const Color(0xFFFCE4EC), // Light pink
      );
    }
    
    // Default
    return _MealIconData(
      emoji: '🍽️',
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class _MealIconData {
  final String emoji;
  final Color backgroundColor;
  
  _MealIconData({
    required this.emoji,
    required this.backgroundColor,
  });
}
