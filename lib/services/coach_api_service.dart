import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'env_service.dart';
import 'turnstile_service.dart';
import 'image_utils.dart';
import 'gemini_client.dart' show FoodNutritionData;

class CoachMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  CoachMessage(this.role, this.content);

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class CoachApiService {
  CoachApiService._();
  static final CoachApiService instance = CoachApiService._();

  Dio? _dio;
  Dio? _visionDio; // optional separate base for vision endpoints (Cloudflare Worker)

  Future<void> _ensureInit() async {
    if (_dio != null) return;
    final fromEnv = await EnvService.get('COACH_API_BASE_URL');
    String base = fromEnv ?? _defaultBaseUrl();
    final token = await EnvService.get('COACH_APP_TOKEN');
    // Android emulator cannot reach localhost; rewrite if needed
    try {
      if (!kIsWeb && Platform.isAndroid) {
        if (base.contains('localhost')) base = base.replaceAll('localhost', '10.0.2.2');
        if (base.contains('127.0.0.1')) base = base.replaceAll('127.0.0.1', '10.0.2.2');
      }
    } catch (_) {}
    _dio = Dio(BaseOptions(
      baseUrl: base,
      headers: {
        'content-type': 'application/json',
        if (token != null && token.isNotEmpty) 'X-App-Token': token,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }

  Future<void> _ensureVisionInit() async {
    if (_visionDio != null) return;
    // If a dedicated vision base URL is provided, use it; otherwise fall back to main _dio
    final baseOverride = await EnvService.get('COACH_VISION_BASE_URL')
        ?? await EnvService.get('VISION_API_BASE_URL');
    if (baseOverride == null || baseOverride.trim().isEmpty) {
      _visionDio = _dio; // reuse same client
      return;
    }
    String base = baseOverride.trim();
    // Android emulator cannot reach localhost; rewrite if needed
    try {
      if (!kIsWeb && Platform.isAndroid) {
        if (base.contains('localhost')) base = base.replaceAll('localhost', '10.0.2.2');
        if (base.contains('127.0.0.1')) base = base.replaceAll('127.0.0.1', '10.0.2.2');
      }
    } catch (_) {}
    // Allow separate token just in case (falls back to COACH_APP_TOKEN)
    final token = (await EnvService.get('COACH_VISION_APP_TOKEN'))
        ?? (await EnvService.get('COACH_APP_TOKEN'));
    _visionDio = Dio(BaseOptions(
      baseUrl: base,
      headers: {
        'content-type': 'application/json',
        if (token != null && token.isNotEmpty) 'X-App-Token': token,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }

  String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8002';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8002';
    } catch (_) {}
    return 'http://localhost:8002';
  }

  Future<CoachReply> sendMessage({
    required String message,
    List<CoachMessage> history = const [],
    Map<String, dynamic>? context,
  }) async {
    await _ensureInit();
    try {
      final payload = {
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
        if (context != null) 'context': context,
      };
      final resp = await _dio!.post('/coach_chat', data: payload);
      final data = resp.data as Map<String, dynamic>;
      final reply = (data['reply'] as String?) ?? '';
      final events = (data['tool_events'] as List?)?.cast<dynamic>().map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList() ?? const [];
      return CoachReply(reply: reply, toolEvents: events);
    } on DioException catch (e) {
      final ex = _classifyCoachError(e, context: 'coach_chat');
      if (ex.code == 'unreachable' && context != null) {
        final fb = _offlineReply(context);
        return CoachReply(reply: fb, toolEvents: const []);
      }
      throw ex;
    }
  }

  Future<List<Map<String, dynamic>>> analyzePhoto({String? imageBase64, String? imageUrl}) async {
    await _ensureInit();
    await _ensureVisionInit();
    try {
      final client = _visionDio ?? _dio!; // prefer vision client when available
      final headers = <String, dynamic>{};
      try {
        final tk = await TurnstileService.getToken();
        if (tk != null && tk.isNotEmpty) headers['X-Turnstile-Token'] = tk;
      } catch (_) {}
      final resp = await client.post('/analisar_foto', data: {
        if (imageBase64 != null) 'image_base64': imageBase64,
        if (imageUrl != null) 'image_url': imageUrl,
      }, options: Options(headers: headers.isEmpty ? null : headers));
      final data = (resp.data as Map<String, dynamic>);
      final list = (data['candidatos'] as List?)?.cast<dynamic>().map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList() ?? const [];
      return list;
    } on DioException catch (e) {
      _throwCoachError(e, context: 'analisar_foto');
    }
  }

  Future<FoodNutritionData> analyzeFoodImageDetailed(File imageFile) async {
    await _ensureInit();
    await _ensureVisionInit();
    try {
      final orig = await imageFile.readAsBytes();
      final bytes = await compressToJpeg(orig, maxDim: 768, quality: 85);
      final comp = await compressToJpeg(bytes, maxDim: 768, quality: 85);
      final payload = {
        'image_base64': base64Encode(comp),
      };
      // On Web, attach Turnstile token if available
      final headers = <String, dynamic>{};
      try {
        final tk = await TurnstileService.getToken();
        if (tk != null && tk.isNotEmpty) headers['X-Turnstile-Token'] = tk;
      } catch (_) {}

      final client = _visionDio ?? _dio!; // prefer vision client when available
      Response resp;
      try {
        resp = await client.post('/vision/analyze_food', data: payload, options: Options(headers: headers.isEmpty ? null : headers));
      } on DioException catch (e) {
        // If rate limited, honor Retry-After once
        if (e.response?.statusCode == 429) {
          final ra = int.tryParse(e.response?.headers.value('retry-after') ?? '') ?? 1;
          await Future<void>.delayed(Duration(seconds: ra.clamp(1, 60)));
          resp = await client.post('/vision/analyze_food', data: payload, options: Options(headers: headers.isEmpty ? null : headers));
        } else if (e.response?.statusCode == 403) {
          // Surface Turnstile-specific errors clearly
          final data = e.response?.data;
          if (data is Map && data['error'] is String) {
            final err = data['error'] as String;
            if (err.startsWith('turnstile_')) {
              throw CoachApiException(err, 'Falha na validação Turnstile: ' + err, status: 403);
            }
          }
          rethrow;
        } else {
          rethrow;
        }
      }
      final data = (resp.data as Map).map((key, value) => MapEntry(key.toString(), value));
      try {
        final rawFoods = (data['foods'] as List?)?.cast<dynamic>() ?? const [];
        final normalizedFoods = rawFoods.map<Map<String, dynamic>>((e) {
          final m = (e as Map).map((k, v) => MapEntry(k.toString(), v));
          // If it already matches expected keys, keep as-is.
          if (m.containsKey('name') || m.containsKey('calories')) {
            return m;
          }
          final name = (m['nome'] ?? m['name'] ?? 'Unknown Food').toString();
          final porcaoG = m['porcao_g'];
          final portion = porcaoG == null ? null : '${porcaoG.toString()} g';
          num _n(v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
          return <String, dynamic>{
            'name': name,
            'portion_size': portion ?? (m['portion_size']?.toString() ?? '1 porção'),
            'calories': _n(m['calorias_kcal'] ?? m['calories']),
            'carbs': (_n(m['carbo_g'] ?? m['carbs'])).toDouble(),
            'protein': (_n(m['proteina_g'] ?? m['protein'])).toDouble(),
            'fat': (_n(m['gordura_g'] ?? m['fat'])).toDouble(),
            'fiber': (_n(m['fibra_g'] ?? m['fiber'])).toDouble(),
            'sugar': (_n(m['acucar_g'] ?? m['sugar'])).toDouble(),
            'confidence': (_n(m['confianca'] ?? m['confidence'])).toDouble(),
          };
        }).toList();
        final normalized = <String, dynamic>{'foods': normalizedFoods};
        return FoodNutritionData.fromJson(normalized);
      } catch (_) {
        return FoodNutritionData.fromJson(Map<String, dynamic>.from(data));
      }
    } on DioException catch (e) {
      _throwCoachError(e, context: 'vision_analyze_food');
    }
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query, {int topK = 5}) async {
    await _ensureInit();
    try {
      final resp = await _dio!.post('/buscar_alimento', data: {
        'query': query,
        'top_k': topK,
      });
      final data = (resp.data as Map<String, dynamic>);
      final list = (data['itens'] as List?)?.cast<dynamic>().map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList() ?? const [];
      return list;
    } on DioException catch (e) {
      _throwCoachError(e, context: 'buscar_alimento');
    }
  }

  /// Web-friendly variant (accepts raw bytes instead of File).
  Future<FoodNutritionData> analyzeFoodImageBytes(Uint8List bytes) async {
    await _ensureInit();
    await _ensureVisionInit();
    try {
      final comp = await compressToJpeg(bytes, maxDim: 768, quality: 85);
      final payload = {
        'image_base64': base64Encode(comp),
      };

      final headers = <String, dynamic>{};
      try {
        final tk = await TurnstileService.getToken();
        if (tk != null && tk.isNotEmpty) headers['X-Turnstile-Token'] = tk;
      } catch (_) {}

      final client = _visionDio ?? _dio!; // prefer vision client when available
      Response resp;
      try {
        resp = await client.post('/vision/analyze_food', data: payload, options: Options(headers: headers.isEmpty ? null : headers));
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) {
          final ra = int.tryParse(e.response?.headers.value('retry-after') ?? '') ?? 1;
          await Future<void>.delayed(Duration(seconds: ra.clamp(1, 60)));
          resp = await client.post('/vision/analyze_food', data: payload, options: Options(headers: headers.isEmpty ? null : headers));
        } else if (e.response?.statusCode == 403) {
          final data = e.response?.data;
          if (data is Map && data['error'] is String) {
            final err = data['error'] as String;
            if (err.startsWith('turnstile_')) {
              throw CoachApiException(err, 'Falha na validação Turnstile: ' + err, status: 403);
            }
          }
          rethrow;
        } else {
          rethrow;
        }
      }
      final data = (resp.data as Map).map((key, value) => MapEntry(key.toString(), value));
      try {
        final rawFoods = (data['foods'] as List?)?.cast<dynamic>() ?? const [];
        final normalizedFoods = rawFoods.map<Map<String, dynamic>>((e) {
          final m = (e as Map).map((k, v) => MapEntry(k.toString(), v));
          // If it already matches expected keys, keep as-is.
          if (m.containsKey('name') || m.containsKey('calories')) {
            return m;
          }
          final name = (m['nome'] ?? m['name'] ?? 'Unknown Food').toString();
          final porcaoG = m['porcao_g'];
          final portion = porcaoG == null ? null : '${porcaoG.toString()} g';
          num _n(v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
          return <String, dynamic>{
            'name': name,
            'portion_size': portion ?? (m['portion_size']?.toString() ?? '1 porção'),
            'calories': _n(m['calorias_kcal'] ?? m['calories']),
            'carbs': (_n(m['carbo_g'] ?? m['carbs'])).toDouble(),
            'protein': (_n(m['proteina_g'] ?? m['protein'])).toDouble(),
            'fat': (_n(m['gordura_g'] ?? m['fat'])).toDouble(),
            'fiber': (_n(m['fibra_g'] ?? m['fiber'])).toDouble(),
            'sugar': (_n(m['acucar_g'] ?? m['sugar'])).toDouble(),
            'confidence': (_n(m['confianca'] ?? m['confidence'])).toDouble(),
          };
        }).toList();
        final normalized = <String, dynamic>{'foods': normalizedFoods};
        return FoodNutritionData.fromJson(normalized);
      } catch (_) {
        return FoodNutritionData.fromJson(Map<String, dynamic>.from(data));
      }
    } on DioException catch (e) {
      _throwCoachError(e, context: 'vision_analyze_food');
    }
  }

}

class CoachReply {
  final String reply;
  final List<Map<String, dynamic>> toolEvents;
  CoachReply({required this.reply, required this.toolEvents});
}

class CoachApiException implements Exception {
  final String code; // e.g., 'unreachable', 'missing_openai_api_key', 'http_error'
  final int status;
  final String message;
  CoachApiException(this.code, this.message, {this.status = 0});
  @override
  String toString() => message;
}

CoachApiException _classifyCoachError(DioException e, {String? context}) {
  final status = e.response?.statusCode ?? 0;
  // Attempt to parse structured error from server
  dynamic data = e.response?.data;
  String? serverError;
  String? serverDetail;
  if (data is Map) {
    serverError = data['error']?.toString();
    serverDetail = data['detail']?.toString();
  } else if (data != null) {
    serverDetail = data.toString();
  }

  // Network-level classification
  if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
    final msg = 'Não consegui contatar o Coach em ${e.requestOptions.baseUrl}.\n'
        'Verifique se o servidor está rodando (porta 8002) e o emulador usa 10.0.2.2.';
    return CoachApiException('unreachable', msg, status: status);
  }

  if (serverError == 'missing_openai_api_key') {
    final msg = 'Servidor do Coach sem OPENAI_API_KEY configurada.\n'
        'Edite server/express/.env e defina OPENAI_API_KEY, depois reinicie.';
    return CoachApiException('missing_openai_api_key', msg, status: status);
  }

  if (serverError == 'missing_openrouter_api_key') {
    final msg = 'Servidor do Coach sem OPENROUTER_API_KEY configurada.\n'
        'Edite server/express/.env e defina OPENROUTER_API_KEY (e OPENROUTER_MODEL opcional), depois reinicie.';
    return CoachApiException('missing_openrouter_api_key', msg, status: status);
  }

  // Token de app inválido/desatualizado (Cloudflare Worker com APP_TOKEN)
  if (serverError == 'unauthorized' || status == 401) {
    final msg = 'Acesso não autorizado ao serviço de visão.\n'
        'Verifique se o COACH_APP_TOKEN do app é idêntico ao APP_TOKEN do Worker (Cloudflare).\n'
        'Dica: atualize env.json (COACH_APP_TOKEN) e faça Deploy/Salvar o APP_TOKEN no painel do Worker.';
    return CoachApiException('unauthorized', msg, status: status);
  }

  // Generic HTTP error
  final label = context ?? 'Coach API';
  final detail = serverDetail ?? (e.message ?? 'erro desconhecido');
  return CoachApiException('http_error', '$label falhou ($status): $detail', status: status);
}

Never _throwCoachError(DioException e, {String? context}) {
  throw _classifyCoachError(e, context: context);
}

String _offlineReply(Map<String, dynamic> ctx) {
  try {
    final g = (ctx['goals'] as Map?) ?? const {};
    final c = (ctx['consumed'] as Map?) ?? const {};
    final r = (ctx['remaining'] as Map?) ?? const {};
    final kcalRem = (r['calories'] ?? 0).toString();
    return 'Estou temporariamente offline. Mesmo assim, aqui vai um apoio rápido baseado no seu dia:\n'
        '- Restante: ${kcalRem} kcal • C ${r['carbs_g'] ?? 0}g • P ${r['protein_g'] ?? 0}g • G ${r['fat_g'] ?? 0}g\n'
        '- Meta diária: ${g['calories'] ?? 0} kcal • Água ${g['water_ml'] ?? 0} ml\n'
        '- Consumido: ${c['calories'] ?? 0} kcal • Água ${c['water_ml'] ?? 0} ml\n\n'
        'Sugestão: faça uma refeição de ~${(r['calories'] ?? 0)} kcal com foco em proteína (ex.: frango + legumes). Quando o coach voltar, posso detalhar mais ou registrar por você.';
  } catch (_) {
    return 'Estou temporariamente offline. Verifique o servidor do coach e tente novamente.';
  }
}
