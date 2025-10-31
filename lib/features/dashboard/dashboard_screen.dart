import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import 'widgets/header_widget.dart';
import 'widgets/calories_circle_widget.dart';
import 'widgets/macros_bar_widget.dart';
import 'widgets/nutrition_section_widget.dart';
import 'widgets/water_tracker_widget.dart';
import 'widgets/measurements_widget.dart';
import 'widgets/activities_widget.dart';
import 'widgets/notes_widget.dart';

/// Skeleton screen for the refactored dashboard structure.
/// Not wired to routes yet — used as a staging area for step-by-step migration.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: AppDimensions.sectionGap),
              HeaderWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              CaloriesCircleWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              MacrosBarWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              NutritionSectionWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              WaterTrackerWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              MeasurementsWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              ActivitiesWidget(),
              SizedBox(height: AppDimensions.sectionGap),
              NotesWidget(),
              SizedBox(height: AppDimensions.sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}

