import 'package:flutter/foundation.dart';
import 'env_service.dart';

/// Lightweight OpenAI service to manage API key loading idempotently.
class OpenAIService {
  static String? _apiKey;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await _loadApiKey();
    _isInitialized = true;
  }

  static Future<void> _loadApiKey() async {
    if (_apiKey != null && _apiKey!.isNotEmpty) return;

    // Try dart-define first
    String key = const String.fromEnvironment('OPENAI_API_KEY');

    // Fallback to env.json via EnvService
    if (key.isEmpty) {
      try {
        final v = await EnvService.get('OPENAI_API_KEY');
        if (v != null && v.trim().isNotEmpty) key = v.trim();
      } catch (e) {
        debugPrint('[OpenAIService] Failed to load OPENAI_API_KEY: ${e.toString()}');
      }
    }
    _apiKey = key;
  }

  static String get apiKey => _apiKey ?? '';
}
