import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InitializationService {
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyOnboardingCompleted = 'onboarding_completed_v1';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyPremiumStatus = 'premium_status';
  static const String _keyUserPreferences = 'user_preferences';
  static const String _keyNutritionData = 'nutrition_data_cache';

  static Future<InitializationResult> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasNetwork = connectivityResult != ConnectivityResult.none;

      // Check if first launch
      final bool isFirstLaunch = prefs.getBool(_keyIsFirstLaunch) ?? true;

      // Check authentication status
      final bool isAuthenticated = prefs.getBool(_keyIsAuthenticated) ?? false;

      // Check premium subscription status
      final bool isPremium = prefs.getBool(_keyPremiumStatus) ?? false;

      // Load user preferences
      final String? userPreferences = prefs.getString(_keyUserPreferences);

      // Sync cached nutrition data if network available
      if (hasNetwork && isAuthenticated) {
        await _syncNutritionData(prefs);
      }

      // Prepare food database (simulate initialization)
      await _prepareFoodDatabase();

      // Determine navigation destination
      String nextRoute;
      final bool onboardingCompleted =
          prefs.getBool(_keyOnboardingCompleted) ?? false;
      if (isFirstLaunch || !onboardingCompleted) {
        // First run or onboarding not completed yet
        nextRoute = '/onboarding';
      } else if (!isAuthenticated) {
        nextRoute = '/login-screen';
      } else {
        nextRoute = '/daily-tracking-dashboard';
      }

      return InitializationResult(
        success: true,
        nextRoute: nextRoute,
        isAuthenticated: isAuthenticated,
        isPremium: isPremium,
        hasNetwork: hasNetwork,
        userPreferences: userPreferences,
      );
    } catch (e) {
      return InitializationResult(
        success: false,
        nextRoute: '/login-screen',
        error: 'Erro na inicialização: ${e.toString()}',
      );
    }
  }

  static Future<void> _syncNutritionData(SharedPreferences prefs) async {
    // Simulate syncing cached nutrition data
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock sync process
    // cachedData kept for future use; suppress unused warning
    // ignore: unused_local_variable
    final String cachedData = prefs.getString(_keyNutritionData) ?? '{}';

    // In real implementation, this would sync with backend
    // For now, just update timestamp
    await prefs.setString(
      '${_keyNutritionData}_last_sync',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> _prepareFoodDatabase() async {
    // Simulate food database preparation
    await Future.delayed(const Duration(milliseconds: 500));

    // In real implementation, this would:
    // - Check database version
    // - Update food items if needed
    // - Prepare search indices
    // - Load frequently used items
  }

  static Future<bool> checkForceUpdate() async {
    // Simulate checking for required app updates
    await Future.delayed(const Duration(milliseconds: 300));

    // In real implementation, this would check version against backend
    return false; // No force update required
  }
}

class InitializationResult {
  final bool success;
  final String nextRoute;
  final bool isAuthenticated;
  final bool isPremium;
  final bool hasNetwork;
  final String? userPreferences;
  final String? error;

  InitializationResult({
    required this.success,
    required this.nextRoute,
    this.isAuthenticated = false,
    this.isPremium = false,
    this.hasNetwork = true,
    this.userPreferences,
    this.error,
  });
}
