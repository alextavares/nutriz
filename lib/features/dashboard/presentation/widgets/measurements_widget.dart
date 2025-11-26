import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MeasurementsWidget extends StatelessWidget {
  final double currentWeight;
  final double goalWeight;
  final Function(double) onWeightChanged;
  final VoidCallback onMoreTap;
  final String? unit; // 'kg' or 'lb'

  const MeasurementsWidget({
    Key? key,
    required this.currentWeight,
    required this.goalWeight,
    required this.onWeightChanged,
    required this.onMoreTap,
    this.unit = 'kg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final accentGreen = const Color(0xFF00BFA5);
    final buttonBorder = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0);
    final buttonBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;

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
                  'Medidas',
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
            
            SizedBox(height: 2.5.h),
            
            // Weight Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Peso',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Meta: ${goalWeight.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Weight Control Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Button
                      _buildCircleButton(
                        icon: Icons.remove,
                        onTap: () => onWeightChanged(currentWeight - 0.1),
                        borderColor: buttonBorder,
                        iconColor: textPrimary,
                        bgColor: buttonBg,
                      ),
                      
                      SizedBox(width: 5.w),
                      
                      // Weight Value
                      Text(
                        '${currentWeight.toStringAsFixed(1)} $unit',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      
                      SizedBox(width: 5.w),
                      
                      // Plus Button
                      _buildCircleButton(
                        icon: Icons.add,
                        onTap: () => onWeightChanged(currentWeight + 0.1),
                        borderColor: buttonBorder,
                        iconColor: textPrimary,
                        bgColor: buttonBg,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color borderColor,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Widget expandido com múltiplas medidas
class MeasurementsExpandedWidget extends StatelessWidget {
  final double currentWeight;
  final double goalWeight;
  final double? bodyFat;
  final double? muscleMass;
  final Function(double) onWeightChanged;
  final VoidCallback onMoreTap;
  final String? unit;

  const MeasurementsExpandedWidget({
    Key? key,
    required this.currentWeight,
    required this.goalWeight,
    this.bodyFat,
    this.muscleMass,
    required this.onWeightChanged,
    required this.onMoreTap,
    this.unit = 'kg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final accentGreen = const Color(0xFF00BFA5);
    final buttonBorder = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0);
    final dividerColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0);

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
                  'Medidas',
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
            
            // Weight Row
            _buildMeasurementRow(
              context: context,
              label: 'Peso',
              value: '${currentWeight.toStringAsFixed(1)} $unit',
              goal: 'Meta: ${goalWeight.toStringAsFixed(1)} $unit',
              onMinus: () => onWeightChanged(currentWeight - 0.1),
              onPlus: () => onWeightChanged(currentWeight + 0.1),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              buttonBorder: buttonBorder,
            ),
            
            if (bodyFat != null) ...[
              Divider(color: dividerColor, height: 3.h),
              _buildMeasurementRow(
                context: context,
                label: 'Gordura Corporal',
                value: '${bodyFat!.toStringAsFixed(1)}%',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                buttonBorder: buttonBorder,
              ),
            ],
            
            if (muscleMass != null) ...[
              Divider(color: dividerColor, height: 3.h),
              _buildMeasurementRow(
                context: context,
                label: 'Massa Muscular',
                value: '${muscleMass!.toStringAsFixed(1)} $unit',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                buttonBorder: buttonBorder,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow({
    required BuildContext context,
    required String label,
    required String value,
    String? goal,
    VoidCallback? onMinus,
    VoidCallback? onPlus,
    required Color textPrimary,
    required Color textSecondary,
    required Color buttonBorder,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    
    return Row(
      children: [
        // Label Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              if (goal != null)
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: textSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        // Value with buttons
        if (onMinus != null)
          _buildSmallCircleButton(
            icon: Icons.remove,
            onTap: onMinus,
            borderColor: buttonBorder,
            iconColor: textPrimary,
            bgColor: buttonBg,
          ),
        
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        
        if (onPlus != null)
          _buildSmallCircleButton(
            icon: Icons.add,
            onTap: onPlus,
            borderColor: buttonBorder,
            iconColor: textPrimary,
            bgColor: buttonBg,
          ),
      ],
    );
  }

  Widget _buildSmallCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color borderColor,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
      ),
    );
  }
}
