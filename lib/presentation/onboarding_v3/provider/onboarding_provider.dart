import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎯 Provider para gerenciar o estado do Onboarding V3 (3 telas)
///
/// Responsável por:
/// - Armazenar o objetivo escolhido pelo usuário
/// - Persistir dados no SharedPreferences
/// - Marcar onboarding como completo
class OnboardingV3Provider with ChangeNotifier {
  String? _goalType;
  bool _isLoading = false;

  String? get goalType => _goalType;
  bool get isLoading => _isLoading;

  /// Objetivo escolhido: "lose_weight", "gain_weight", "maintain"
  void setGoal(String goal) {
    _goalType = goal;
    notifyListeners();
  }

  /// Salvar dados no SharedPreferences e marcar onboarding como completo
  Future<void> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Marcar onboarding V3 como completo
      await prefs.setBool('onboarding_v3_completed', true);

      // Salvar objetivo escolhido
      if (_goalType != null) {
        await prefs.setString('user_goal', _goalType!);
      }

      // Marcar primeira vez como false
      await prefs.setBool('is_first_launch', false);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Verificar se onboarding foi completado
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_v3_completed') ?? false;
  }

  /// Resetar onboarding (útil para testes)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_v3_completed');
    await prefs.remove('user_goal');
    await prefs.setBool('is_first_launch', true);
    _goalType = null;
    notifyListeners();
  }
}
