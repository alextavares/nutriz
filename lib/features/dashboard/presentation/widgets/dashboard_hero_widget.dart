import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/presentation/nutrition_details_screen/nutrition_details_screen.dart';

class DashboardHeroWidget extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesGoal;
  final int caloriesBurned;
  final int carbsConsumed;
  final int carbsGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int fatConsumed;
  final int fatGoal;
  // Fasting props
  final bool isFasting;
  final bool isEatingWindow;
  final String? fastingStatus;
  final Duration? fastingElapsed;
  final Duration? fastingGoal;
  final VoidCallback? onFastingTap;
  final VoidCallback? onCardTap;

  const DashboardHeroWidget({
    Key? key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    this.caloriesBurned = 0,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.fatConsumed,
    required this.fatGoal,
    this.isFasting = false,
    this.isEatingWindow = false,
    this.fastingStatus,
    this.fastingElapsed,
    this.fastingGoal,
    this.onFastingTap,
    this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = caloriesGoal - caloriesConsumed + caloriesBurned;
    final progress = caloriesGoal > 0 
        ? (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0) 
        : 0.0;

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final accentGreen = const Color(0xFF00BFA5);
    final progressBg = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEEEEEE);
    final progressColor = remaining < 0 
        ? const Color(0xFFFF5252) 
        : const Color(0xFF8B80F9);

    final showFastingBanner = isFasting || isEatingWindow;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: Column(
          children: [
            // Main Content - Clicável
            InkWell(
              onTap: () => _openNutritionDetails(context),
              borderRadius: showFastingBanner 
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resumo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Detalhes',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: accentGreen,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 2.h),
                    
                    // Main Circle Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSideStat(
                          value: '$caloriesConsumed',
                          label: 'Comido',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        
                        // Central Circle
                        SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 28.w,
                                height: 28.w,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(progressBg),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              SizedBox(
                                width: 28.w,
                                height: 28.w,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$remaining',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: 0.2.h),
                                  Text(
                                    'Restantes',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      color: textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        _buildSideStat(
                          value: '$caloriesBurned',
                          label: 'Queimado',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 2.h),
                    
                    // Macros Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMacroItemWithDot(
                          label: 'Carboidratos',
                          current: carbsConsumed,
                          goal: carbsGoal,
                          color: const Color(0xFFFFA726),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildMacroItemWithDot(
                          label: 'Proteína',
                          current: proteinConsumed,
                          goal: proteinGoal,
                          color: const Color(0xFF66BB6A),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildMacroItemWithDot(
                          label: 'Gordura',
                          current: fatConsumed,
                          goal: fatGoal,
                          color: const Color(0xFFEF5350),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Fasting Banner
            if (showFastingBanner) _buildFastingBanner(context),
          ],
        ),
      ),
    );
  }

  void _openNutritionDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionDetailsScreen(
          caloriesConsumed: caloriesConsumed,
          caloriesGoal: caloriesGoal,
          carbsConsumed: carbsConsumed,
          carbsGoal: carbsGoal,
          proteinConsumed: proteinConsumed,
          proteinGoal: proteinGoal,
          fatConsumed: fatConsumed,
          fatGoal: fatGoal,
        ),
      ),
    );
  }

  Widget _buildFastingBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color bannerBg;
    final String emoji;
    final String statusText;
    
    if (isEatingWindow) {
      bannerBg = isDark ? const Color(0xFF880E4F) : const Color(0xFFE91E63);
      emoji = '🍎';
      statusText = fastingStatus ?? 'Janela Alimentar';
    } else {
      bannerBg = isDark ? const Color(0xFF1A237E) : const Color(0xFF5C6BC0);
      emoji = '🕐';
      statusText = fastingStatus ?? 'Jejum';
    }
    
    String timeText = '';
    if (fastingElapsed != null) {
      final hours = fastingElapsed!.inHours;
      final minutes = fastingElapsed!.inMinutes % 60;
      if (hours > 0) {
        timeText = '${hours}h ${minutes}m';
      } else {
        timeText = '${minutes}m';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFastingTap,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              SizedBox(width: 2.w),
              Text(
                'Agora: $statusText',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (timeText.isNotEmpty) ...[
                SizedBox(width: 1.5.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideStat({
    required String value,
    required String label,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItemWithDot({
    required String label,
    required int current,
    required int goal,
    required Color color,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          '$current / ${goal}g',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
