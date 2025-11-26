import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class NutritionDetailsScreen extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesGoal;
  final int carbsConsumed;
  final int carbsGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int fatConsumed;
  final int fatGoal;

  const NutritionDetailsScreen({
    Key? key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.fatConsumed,
    required this.fatGoal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.white, // Yazio style is clean white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hoje',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Goal Section (Bar Charts)
                  _buildGoalSection(),
                  
                  SizedBox(height: 4.h),
                  
                  // Nutrient List
                  _buildNutrientRow('Calorias', '$caloriesConsumed kcal', false),
                  _buildNutrientRow('Proteína', '${proteinConsumed} g', false),
                  _buildNutrientRow('Carboidratos', '${carbsConsumed} g', false),
                  _buildNutrientRow('Gordura', '${fatConsumed} g', false),
                  
                  // "PRO" items (mimicking the screenshot)
                  _buildNutrientRow('Fibras', 'PRO', true),
                  _buildNutrientRow('Açúcares', 'PRO', true),
                  _buildNutrientRow('Gordura Saturada', 'PRO', true),
                  _buildNutrientRow('Gordura Monoinsaturada', 'PRO', true),
                  _buildNutrientRow('Gordura Poli-insaturada', 'PRO', true),
                  _buildNutrientRow('Sódio', 'PRO', true),
                  _buildNutrientRow('Potássio', 'PRO', true),
                  _buildNutrientRow('Magnésio', 'PRO', true),
                ],
              ),
            ),
          ),
          
          // Bottom Button
          Padding(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to food logging or just pop
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0085FF), // Yazio Blue-ish
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Registrar alimento',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Very light grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildGoalBar('Carboidratos', carbsConsumed, carbsGoal, const Color(0xFFFFA726)), // Orange
              SizedBox(width: 4.w),
              _buildGoalBar('Proteína', proteinConsumed, proteinGoal, const Color(0xFF66BB6A)), // Green
              SizedBox(width: 4.w),
              _buildGoalBar('Gordura', fatConsumed, fatGoal, const Color(0xFFEF5350)), // Red
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBar(String label, int current, int goal, Color color) {
    final progress = (goal > 0 ? current / goal : 0.0).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        children: [
          // Vertical Bar
          Container(
            height: 15.h,
            width: 2.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, bool isPro) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF2D3142),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isPro)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726), // Orange PRO badge
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF2D3142),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
