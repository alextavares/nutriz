import 'package:flutter/material.dart';

/// 📊 ONBOARDING DATA MODEL
///
/// Armazena todos os dados coletados durante o onboarding.
/// Serializa/deserializa para SharedPreferences.
class OnboardingData {
  // ==========================================
  // 🎯 OBJETIVO (Telas 03-05)
  // ==========================================

  /// Objetivo principal: "lose_weight", "gain_muscle", "maintain"
  String? goalType;

  /// Meta de peso (kg)
  double? weightGoalKg;

  /// Velocidade: "slow", "moderate", "fast"
  String? goalSpeed;

  /// Kg por semana
  double? kgPerWeek;

  /// Semanas estimadas para atingir meta
  int? estimatedWeeks;

  // ==========================================
  // 👤 PERFIL PESSOAL (Tela 06)
  // ==========================================

  /// Idade (anos)
  int? age;

  /// Sexo biológico: "male", "female", "other"
  String? gender;

  /// Altura (cm)
  double? heightCm;

  /// Peso atual (kg)
  double? currentWeightKg;

  /// Sistema de unidades: "metric" ou "imperial"
  String unitSystem;

  // ==========================================
  // 🏃 ATIVIDADE E DIETA (Telas 07-09)
  // ==========================================

  /// Nível de atividade física
  String? activityLevel;

  /// Multiplicador de atividade (para TDEE)
  double? activityMultiplier;

  /// Preferência alimentar
  String? dietPreference;

  /// Dieta customizada (se escolheu "outra")
  String? customDiet;

  /// Frequência de refeições
  String? mealFrequency;

  /// Janela de jejum (se faz jejum intermitente)
  String? fastingWindow;

  /// Horário de início da alimentação
  TimeOfDay? eatingHoursStart;

  /// Horário de fim da alimentação
  TimeOfDay? eatingHoursEnd;

  // ==========================================
  // 🔢 CÁLCULOS (Tela 10)
  // ==========================================

  /// Taxa Metabólica Basal
  double? bmr;

  /// Total Daily Energy Expenditure
  double? tdee;

  /// Calorias diárias alvo
  int? dailyCalories;

  /// Macronutrientes (g/dia)
  Map<String, double>? macros;

  // ==========================================
  // 📱 DESCOBERTA E OUTROS
  // ==========================================

  /// Como descobriu o app (Tela 04)
  String? discoverySource;

  // ==========================================
  // ⚙️ META DADOS
  // ==========================================

  /// Data de início do onboarding
  DateTime? startDate;

  /// Data de conclusão do onboarding
  DateTime? completionDate;

  /// Notificações habilitadas
  bool notificationsEnabled;

  /// Onboarding completado?
  bool onboardingCompleted;

  /// Passo atual (1-15) para retomar
  int currentStep;

  // ==========================================
  // 🏗️ CONSTRUTOR
  // ==========================================

  OnboardingData({
    this.goalType,
    this.weightGoalKg,
    this.goalSpeed,
    this.kgPerWeek,
    this.estimatedWeeks,
    this.age,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.unitSystem = 'metric',
    this.activityLevel,
    this.activityMultiplier,
    this.dietPreference,
    this.customDiet,
    this.mealFrequency,
    this.fastingWindow,
    this.eatingHoursStart,
    this.eatingHoursEnd,
    this.bmr,
    this.tdee,
    this.dailyCalories,
    this.macros,
    this.discoverySource,
    this.startDate,
    this.completionDate,
    this.notificationsEnabled = false,
    this.onboardingCompleted = false,
    this.currentStep = 1,
  });

  // ==========================================
  // 📤 SERIALIZAÇÃO (para SharedPreferences)
  // ==========================================

  Map<String, dynamic> toJson() {
    return {
      'goalType': goalType,
      'weightGoalKg': weightGoalKg,
      'goalSpeed': goalSpeed,
      'kgPerWeek': kgPerWeek,
      'estimatedWeeks': estimatedWeeks,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'unitSystem': unitSystem,
      'activityLevel': activityLevel,
      'activityMultiplier': activityMultiplier,
      'dietPreference': dietPreference,
      'customDiet': customDiet,
      'mealFrequency': mealFrequency,
      'fastingWindow': fastingWindow,
      'eatingHoursStart': eatingHoursStart != null
          ? '${eatingHoursStart!.hour}:${eatingHoursStart!.minute}'
          : null,
      'eatingHoursEnd': eatingHoursEnd != null
          ? '${eatingHoursEnd!.hour}:${eatingHoursEnd!.minute}'
          : null,
      'bmr': bmr,
      'tdee': tdee,
      'dailyCalories': dailyCalories,
      'macros': macros,
      'discoverySource': discoverySource,
      'startDate': startDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'onboardingCompleted': onboardingCompleted,
      'currentStep': currentStep,
    };
  }

  // ==========================================
  // 📥 DESERIALIZAÇÃO (de SharedPreferences)
  // ==========================================

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTimeOfDay(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return OnboardingData(
      goalType: json['goalType'],
      weightGoalKg: json['weightGoalKg']?.toDouble(),
      goalSpeed: json['goalSpeed'],
      kgPerWeek: json['kgPerWeek']?.toDouble(),
      estimatedWeeks: json['estimatedWeeks'],
      age: json['age'],
      gender: json['gender'],
      heightCm: json['heightCm']?.toDouble(),
      currentWeightKg: json['currentWeightKg']?.toDouble(),
      unitSystem: json['unitSystem'] ?? 'metric',
      activityLevel: json['activityLevel'],
      activityMultiplier: json['activityMultiplier']?.toDouble(),
      dietPreference: json['dietPreference'],
      customDiet: json['customDiet'],
      mealFrequency: json['mealFrequency'],
      fastingWindow: json['fastingWindow'],
      eatingHoursStart: parseTimeOfDay(json['eatingHoursStart']),
      eatingHoursEnd: parseTimeOfDay(json['eatingHoursEnd']),
      bmr: json['bmr']?.toDouble(),
      tdee: json['tdee']?.toDouble(),
      dailyCalories: json['dailyCalories'],
      macros: json['macros'] != null
          ? Map<String, double>.from(json['macros'])
          : null,
      discoverySource: json['discoverySource'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      currentStep: json['currentStep'] ?? 1,
    );
  }

  // ==========================================
  // 📋 COPY WITH (para atualizações imutáveis)
  // ==========================================

  OnboardingData copyWith({
    String? goalType,
    double? weightGoalKg,
    String? goalSpeed,
    double? kgPerWeek,
    int? estimatedWeeks,
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    String? unitSystem,
    String? activityLevel,
    double? activityMultiplier,
    String? dietPreference,
    String? customDiet,
    String? mealFrequency,
    String? fastingWindow,
    TimeOfDay? eatingHoursStart,
    TimeOfDay? eatingHoursEnd,
    double? bmr,
    double? tdee,
    int? dailyCalories,
    Map<String, double>? macros,
    String? discoverySource,
    DateTime? startDate,
    DateTime? completionDate,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    int? currentStep,
  }) {
    return OnboardingData(
      goalType: goalType ?? this.goalType,
      weightGoalKg: weightGoalKg ?? this.weightGoalKg,
      goalSpeed: goalSpeed ?? this.goalSpeed,
      kgPerWeek: kgPerWeek ?? this.kgPerWeek,
      estimatedWeeks: estimatedWeeks ?? this.estimatedWeeks,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      unitSystem: unitSystem ?? this.unitSystem,
      activityLevel: activityLevel ?? this.activityLevel,
      activityMultiplier: activityMultiplier ?? this.activityMultiplier,
      dietPreference: dietPreference ?? this.dietPreference,
      customDiet: customDiet ?? this.customDiet,
      mealFrequency: mealFrequency ?? this.mealFrequency,
      fastingWindow: fastingWindow ?? this.fastingWindow,
      eatingHoursStart: eatingHoursStart ?? this.eatingHoursStart,
      eatingHoursEnd: eatingHoursEnd ?? this.eatingHoursEnd,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      macros: macros ?? this.macros,
      discoverySource: discoverySource ?? this.discoverySource,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  // ==========================================
  // ✅ VALIDAÇÕES
  // ==========================================

  /// Verifica se dados pessoais estão completos
  bool get isPersonalDataComplete {
    return age != null &&
        gender != null &&
        heightCm != null &&
        currentWeightKg != null;
  }

  /// Verifica se objetivo está definido
  bool get isGoalSet {
    return goalType != null;
  }

  /// Verifica se cálculos foram feitos
  bool get areCalculationsComplete {
    return bmr != null && tdee != null && dailyCalories != null;
  }

  // ==========================================
  // 📊 HELPERS
  // ==========================================

  /// Retorna a cor do objetivo
  Color get goalColor {
    switch (goalType) {
      case 'lose_weight':
        return const Color(0xFF3B82F6); // Azul
      case 'gain_muscle':
        return const Color(0xFF8B5CF6); // Roxo
      case 'maintain':
        return const Color(0xFFF59E0B); // Amarelo
      default:
        return const Color(0xFF6B7280); // Cinza
    }
  }

  /// Retorna o nome legível do objetivo
  String get goalName {
    switch (goalType) {
      case 'lose_weight':
        return 'Perder Peso';
      case 'gain_muscle':
        return 'Ganhar Massa';
      case 'maintain':
        return 'Manter Peso';
      default:
        return '';
    }
  }

  /// Retorna o multiplicador de atividade baseado no nível
  static double getActivityMultiplier(String level) {
    switch (level) {
      case 'sedentary':
        return 1.2;
      case 'lightly_active':
        return 1.375;
      case 'moderately_active':
        return 1.55;
      case 'very_active':
        return 1.725;
      case 'athlete':
        return 1.9;
      default:
        return 1.2;
    }
  }
}
