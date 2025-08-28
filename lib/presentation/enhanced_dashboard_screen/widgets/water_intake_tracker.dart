import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaterIntakeTracker extends StatelessWidget {
  final int consumed;
  final int total;

  const WaterIntakeTracker({
    super.key,
    required this.consumed,
    required this.total,
  });

  double get progress => total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0;
  int get remaining => total - consumed;
  double get consumedLiters => consumed / 1000;
  double get totalLiters => total / 1000;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.activeBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: AppTheme.activeBlue,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Água',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${consumedLiters.toStringAsFixed(1)}L de ${totalLiters.toStringAsFixed(1)}L',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: progress >= 0.8
                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                      : AppTheme.warningAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  progress >= 0.8 ? 'Quase lá!' : 'Beba mais',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: progress >= 0.8
                        ? AppTheme.successGreen
                        : AppTheme.warningAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 1.5.h,
              backgroundColor: AppTheme.dividerGray.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? AppTheme.successGreen : AppTheme.activeBlue,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% concluído',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${remaining}ml restantes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: remaining > 0 ? AppTheme.warningAmber : AppTheme.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Quick Add Buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton(
                  context,
                  amount: 200,
                  label: '200ml',
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildQuickAddButton(
                  context,
                  amount: 300,
                  label: '300ml',
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildQuickAddButton(
                  context,
                  amount: 500,
                  label: '500ml',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required int amount,
    required String label,
  }) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: () {
        // TODO: Implement water intake addition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$amount ml de água adicionados!'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.activeBlue.withValues(alpha: 0.1),
        foregroundColor: AppTheme.activeBlue,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.activeBlue.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}