import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  static String? _apiKey;
  static bool _isInitialized = false;

  static Future<void> loadApiKeyFromEnv() async {
    // evita reatribuição quando já carregado
    if (_apiKey != null && _apiKey!.isNotEmpty) return;
    // tenta carregar do dart-define
    String key = const String.fromEnvironment('GEMINI_API_KEY');
    if (key.isEmpty) {
      try {
        // tenta carregar do env.json
        final env = await rootBundle.loadString('env.json');
        final Map<String, dynamic> data = jsonDecode(env);
        key = data['GEMINI_API_KEY'] ?? '';
        if (key.isNotEmpty) {
          debugPrint('[GeminiService] GEMINI_API_KEY carregado de env.json (uso de desenvolvimento). Para produção, injete via --dart-define.');
        }
      } catch (_) {
        key = '';
      }
    }
    _apiKey = key;
  }

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal();

  static Future<void> init() async {
    if (_isInitialized) return;
    await loadApiKeyFromEnv();
    _instance._initializeService();
    _isInitialized = true;
  }

  void _initializeService() {
    if ((_apiKey ?? '').isEmpty) {
      throw Exception(
          'Missing GEMINI_API_KEY. Provide via --dart-define or assets/env.json');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1',
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Dio get dio => _dio;
  String get authApiKey => _apiKey ?? '';
}
