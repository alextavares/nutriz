import 'dart:io';

import 'package:flutter/foundation.dart';

import 'gemini_client.dart' as gem;
import 'gemini_service.dart';
import 'openai_client.dart' as oi;
import 'env_service.dart';

class AiProvider {
  final String provider; // 'gemini' | 'openai'
  final String? openAiModel;
  final String? openAiKey;

  late final gem.GeminiClient _geminiClient;
  oi.OpenAIClient? _openAIClient;

  AiProvider._(this.provider, {this.openAiModel, this.openAiKey});

  static Future<AiProvider> init() async {
    final p = const String.fromEnvironment('AI_PROVIDER');
    final provider =
        (p.toLowerCase().trim().isEmpty) ? 'gemini' : p.toLowerCase().trim();

    // Prepare Gemini by default
    await GeminiService.init();
    final gsvc = GeminiService();
    final ai = AiProvider._(
      provider,
      openAiModel: const String.fromEnvironment('OPENAI_MODEL'),
      openAiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    );
    ai._geminiClient = gem.GeminiClient(gsvc.dio, gsvc.authApiKey);

    if (provider == 'openai') {
      final key = ai.openAiKey;
      if (key == null || key.isEmpty) {
        // Try to load from EnvService as fallback
        try {
          final k = await EnvService.get('OPENAI_API_KEY');
          if (k != null && k.isNotEmpty) {
            ai._openAIClient = oi.OpenAIClient(k);
          } else {
            debugPrint(
                '[AiProvider] OPENAI_API_KEY not set; falling back to Gemini');
          }
        } catch (_) {
          debugPrint(
              '[AiProvider] OPENAI_API_KEY not available; fallback to Gemini');
        }
      } else {
        ai._openAIClient = oi.OpenAIClient(key);
      }
    }
    return ai;
  }

  static Future<AiProvider> fromConfig({
    required String provider,
    String? openAiModel,
    String? openAiKey,
  }) async {
    final p = provider.toLowerCase().trim();
    await GeminiService.init();
    final gsvc = GeminiService();
    final ai = AiProvider._(p, openAiModel: openAiModel, openAiKey: openAiKey);
    ai._geminiClient = gem.GeminiClient(gsvc.dio, gsvc.authApiKey);
    if (p == 'openai') {
      String keyVal = openAiKey ?? '';
      if (keyVal.isEmpty) {
        keyVal = const String.fromEnvironment('OPENAI_API_KEY');
      }
      if (keyVal.isEmpty) {
        try {
          keyVal = await EnvService.get('OPENAI_API_KEY') ?? '';
        } catch (_) {}
      }
      if (keyVal.isNotEmpty) {
        ai._openAIClient = oi.OpenAIClient(keyVal);
      } else {
        debugPrint(
            '[AiProvider] fromConfig: OPENAI_API_KEY missing; fallback to Gemini');
      }
    }
    return ai;
  }

  Future<gem.FoodNutritionData> analyzeFoodImage(File file) async {
    if (provider == 'openai' && _openAIClient != null) {
      try {
        final data = await _openAIClient!.analyzeFoodImage(file,
            model: (openAiModel?.isNotEmpty ?? false)
                ? openAiModel
                : 'gpt-4o-mini');
        // Map to gem.FoodNutritionData via JSON roundtrip since schema matches
        final foods = data.foods
            .map((f) => gem.DetectedFood(
                  name: f.name,
                  calories: f.calories,
                  carbs: f.carbs,
                  protein: f.protein,
                  fat: f.fat,
                  fiber: f.fiber,
                  sugar: f.sugar,
                  portionSize: f.portionSize,
                  confidence: f.confidence,
                ))
            .toList();
        return gem.FoodNutritionData(foods: foods);
      } catch (e) {
        debugPrint(
            '[AiProvider] OpenAI failed (${e.toString()}); falling back to Gemini');
      }
    }
    return await _geminiClient.analyzeFoodImage(file);
  }
}
