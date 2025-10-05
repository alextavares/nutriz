import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/food_logging_screen/food_logging_screen.dart';
import '../presentation/food_logging_screen/add_food_entry_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart';
import '../presentation/enhanced_dashboard_screen/enhanced_dashboard_screen.dart';
import '../presentation/body_metrics_screen/body_metrics_screen.dart';
import '../presentation/notes_screen/notes_screen.dart';
import '../presentation/recipe_browser/recipe_browser.dart';
import '../presentation/intermittent_fasting_tracker/intermittent_fasting_tracker.dart';
import '../presentation/detailed_meal_tracking_screen/detailed_meal_tracking_screen.dart';
import '../presentation/ai_food_detection_screen/ai_food_detection_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/weekly_progress_screen/weekly_progress_screen.dart';
import '../presentation/design_preview/design_preview_screen.dart';
import '../presentation/progress_overview/progress_overview.dart';
import '../presentation/goals_wizard/goals_wizard.dart';
import '../presentation/exercise_logging_screen/exercise_logging_screen.dart';
import '../presentation/achievements/all_achievements_screen.dart';
import '../presentation/onboarding/onboarding_flow.dart';
import '../presentation/streaks/streak_overview_screen.dart';
import '../presentation/ai_coach_chat/ai_coach_chat_screen.dart';
import '../presentation/pro_subscription/pro_subscription_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String foodLogging = '/food-logging-screen';
  static const String login = '/login-screen';
  static const String dailyTrackingDashboard = '/daily-tracking-dashboard';
  static const String enhancedDashboard = '/enhanced-dashboard';
  static const String recipeBrowser = '/recipe-browser';
  static const String intermittentFastingTracker =
      '/intermittent-fasting-tracker';
  static const String detailedMealTrackingScreen =
      '/detailed-meal-tracking-screen';
  static const String aiFoodDetection = '/ai-food-detection-screen';
  static const String aiCoachChat = '/ai-coach-chat';
  static const String profile = '/profile-screen';
  static const String weeklyProgress = '/weekly-progress-screen';
  static const String designPreview = '/design-preview';
  static const String progressOverview = '/progress-overview';
  static const String goalsWizard = '/goals-wizard';
  static const String exerciseLogging = '/exercise-logging';
  static const String bodyMetrics = '/body-metrics';
  static const String notes = '/notes';
  static const String addFoodEntry = '/add-food-entry';
  static const String achievements = '/achievements';
  static const String onboarding = '/onboarding';
  static const String streakOverview = '/streak-overview';
  static const String proSubscription = '/pro-subscription';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    foodLogging: (context) => const FoodLoggingScreen(),
    login: (context) => const LoginScreen(),
    dailyTrackingDashboard: (context) => const DailyTrackingDashboard(),
    enhancedDashboard: (context) => const EnhancedDashboardScreen(),
    recipeBrowser: (context) => const RecipeBrowser(),
    intermittentFastingTracker: (context) => const IntermittentFastingTracker(),
    detailedMealTrackingScreen: (context) => const DetailedMealTrackingScreen(),
    aiFoodDetection: (context) => const AiFoodDetectionScreen(),
    aiCoachChat: (context) => const AiCoachChatScreen(),
    profile: (context) => const ProfileScreen(),
    weeklyProgress: (context) => const WeeklyProgressScreen(),
    designPreview: (context) => const DesignPreviewScreen(),
    progressOverview: (context) => const ProgressOverviewScreen(),
    goalsWizard: (context) => const GoalsWizardScreen(),
    exerciseLogging: (context) => const ExerciseLoggingScreen(),
    bodyMetrics: (context) => const BodyMetricsScreen(),
    notes: (context) => const NotesScreen(),
    addFoodEntry: (context) => const AddFoodEntryScreen(),
    achievements: (context) => const AllAchievementsScreen(),
    onboarding: (context) => const OnboardingFlow(),
    streakOverview: (context) => const StreakOverviewScreen(),
    proSubscription: (context) => const ProSubscriptionScreen(),
    // TODO: Add your other routes here
  };
}
