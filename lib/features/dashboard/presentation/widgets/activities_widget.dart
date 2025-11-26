import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ActivitiesWidget extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final int caloriesBurned;
  final VoidCallback onConnectTap;
  final VoidCallback? onManualTrackTap;
  final VoidCallback? onMoreTap;

  const ActivitiesWidget({
    Key? key,
    this.steps = 0,
    this.stepGoal = 10000,
    this.caloriesBurned = 0,
    required this.onConnectTap,
    this.onManualTrackTap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final accentGreen = const Color(0xFF00BFA5); // Teal/Green accent
    final buttonBg = isDark ? const Color(0xFF00897B) : const Color(0xFF263238);
    final iconBg = isDark ? const Color(0xFF1A3A3A) : const Color(0xFFE0F2F1);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  'Atividades',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onMoreTap,
                  child: Text(
                    'Mais',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: accentGreen,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Steps Card
            Row(
              children: [
                // Running shoe icon - Estilo Yazio
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/running_shoe.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback para emoji se imagem não existir
                        return const Text(
                          '👟',
                          style: TextStyle(fontSize: 24),
                        );
                      },
                    ),
                  ),
                ),
                
                SizedBox(width: 3.w),
                
                // Steps info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passos',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rastreamento Automático',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Connect Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onConnectTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: buttonBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Conectar',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Manual tracking link
            Center(
              child: GestureDetector(
                onTap: onManualTrackTap,
                child: Text(
                  'Rastrear passos manualmente',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: accentGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir atividades quando conectado
class ActivitiesConnectedWidget extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final int caloriesBurned;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const ActivitiesConnectedWidget({
    Key? key,
    required this.steps,
    this.stepGoal = 10000,
    this.caloriesBurned = 0,
    this.onTap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (steps / stepGoal).clamp(0.0, 1.0);
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final accentGreen = const Color(0xFF00BFA5);
    final iconBg = isDark ? const Color(0xFF1A3A3A) : const Color(0xFFE0F2F1);
    final progressBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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
                      'Atividades',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: onMoreTap,
                      child: Text(
                        'Mais',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Steps with progress
                Row(
                  children: [
                    // Running shoe icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('👟', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    
                    SizedBox(width: 3.w),
                    
                    // Steps count and progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$steps',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                ' / $stepGoal passos',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: progressBg,
                              valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 3.w),
                    
                    // Calories burned
                    Column(
                      children: [
                        Text(
                          '🔥',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '$caloriesBurned',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
