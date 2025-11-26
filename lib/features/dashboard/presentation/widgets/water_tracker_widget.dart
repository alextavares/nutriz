import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WaterTrackerWidget extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final Function(int) onAdd;
  final VoidCallback? onTap;

  const WaterTrackerWidget({
    Key? key,
    required this.currentMl,
    required this.goalMl,
    required this.onAdd,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final waterBlue = const Color(0xFF29B6F6);
    final waterBlueBg = isDark ? const Color(0xFF1A3A4A) : const Color(0xFFE3F2FD);
    final buttonBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    final buttonBorder = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8);

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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
            child: Row(
              children: [
                // Water drop icon with background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: waterBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '💧',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                
                // Title and progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Água',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Progress text
                Text(
                  '$currentMl / $goalMl ml',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: waterBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget alternativo com botões de adicionar água
class WaterTrackerWithButtonsWidget extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final Function(int) onAdd;
  final VoidCallback? onTap;

  const WaterTrackerWithButtonsWidget({
    Key? key,
    required this.currentMl,
    required this.goalMl,
    required this.onAdd,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final waterBlue = const Color(0xFF29B6F6);
    final waterBlueBg = isDark ? const Color(0xFF1A3A4A) : const Color(0xFFE3F2FD);
    final buttonBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    final buttonBorder = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8);

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
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: waterBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('💧', style: TextStyle(fontSize: 18)),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Água',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$currentMl / $goalMl ml',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: waterBlue,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Quick Add Buttons
            Row(
              children: [
                Expanded(
                  child: _buildWaterButton(
                    context, 250, buttonBg, buttonBorder, waterBlue, textPrimary,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildWaterButton(
                    context, 500, buttonBg, buttonBorder, waterBlue, textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(
    BuildContext context,
    int amount,
    Color bgColor,
    Color borderColor,
    Color iconColor,
    Color textColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAdd(amount),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.3.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_drink_outlined,
                color: iconColor,
                size: 18,
              ),
              SizedBox(width: 1.5.w),
              Text(
                '+$amount ml',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
