import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class OpenAIClient {
  final Dio dio;
  final String apiKey;

  OpenAIClient(this.apiKey)
      : dio = Dio(BaseOptions(
          baseUrl: 'https://api.openai.com/v1',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ));

  Future<OpenAICompletion> createMultimodal({
    required String prompt,
    required File image,
    String model = 'gpt-4o-mini',
    int maxTokens = 1024,
  }) async {
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final body = {
      'model': model,
      'max_tokens': maxTokens,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
            }
          ]
        }
      ]
    };

    final resp = await dio.post('/chat/completions', data: body);
    final data = resp.data;
    if (data == null || data['choices'] == null || data['choices'].isEmpty) {
      throw OpenAIException(
          statusCode: resp.statusCode ?? 500, message: 'Empty response');
    }
    // Chat API usually returns string content
    final content = data['choices'][0]['message']['content'];
    final text = content is String
        ? content
        : (content is List
            ? content.map((e) => (e['text'] ?? '')).join('\n')
            : content.toString());
    return OpenAICompletion(text: text);
  }

  Future<FoodNutritionData> analyzeFoodImage(File imageFile,
      {String? model}) async {
    const prompt = '''
Analyze this food image and identify the food items. For each food item detected, provide nutritional information in the following JSON format:
{
  "foods": [
    {
      "name": "Food Name",
      "calories": 150,
      "carbs": 30.5,
      "protein": 8.2,
      "fat": 2.1,
      "fiber": 4.0,
      "sugar": 12.3,
      "portion_size": "1 cup",
      "confidence": 0.85
    }
  ]
}
Return only text that contains or wraps a single JSON object as described.''';

    final completion = await createMultimodal(
      prompt: prompt,
      image: imageFile,
      model: model ?? 'gpt-4o-mini',
      maxTokens: 1024,
    );

    final responseText = completion.text;
    final Map<String, dynamic>? parsed = _extractFoodsJson(responseText);
    if (parsed == null) {
      throw OpenAIException(
          statusCode: 422, message: 'Could not parse nutritional JSON');
    }
    return FoodNutritionData.fromJson(parsed);
  }
}

class OpenAICompletion {
  final String text;
  OpenAICompletion({required this.text});
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;
  OpenAIException({required this.statusCode, required this.message});
  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}

class FoodNutritionData {
  final List<DetectedFood> foods;
  FoodNutritionData({required this.foods});
  factory FoodNutritionData.fromJson(Map<String, dynamic> json) {
    final foodsData = json['foods'] as List<dynamic>? ?? [];
    final foods = foodsData
        .map((food) => DetectedFood.fromJson(food as Map<String, dynamic>))
        .toList();
    return FoodNutritionData(foods: foods);
  }
}

class DetectedFood {
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final String portionSize;
  final double confidence;

  DetectedFood({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.portionSize,
    required this.confidence,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'] as String? ?? 'Unknown Food',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      portionSize: json['portion_size'] as String? ?? '1 porção',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Heuristic JSON extractor that tolerates code fences and extra prose.
Map<String, dynamic>? _extractFoodsJson(String text) {
  String cleaned = text.trim();
  // Strip Markdown code fences if present
  if (cleaned.contains('```')) {
    final parts = cleaned.split('```');
    for (final p in parts) {
      final s = p.trim();
      if (s.startsWith('{') && s.contains('foods')) {
        try {
          return jsonDecode(s) as Map<String, dynamic>;
        } catch (_) {}
      }
    }
    cleaned = parts.where((p) => p.contains('{')).join('\n');
  }

  final idxFoods = cleaned.indexOf('foods');
  int start = cleaned.indexOf('{');
  int end = cleaned.lastIndexOf('}');

  if (idxFoods >= 0) {
    for (int i = idxFoods; i >= 0; i--) {
      if (cleaned[i] == '{') {
        start = i;
        break;
      }
    }
    end = _findMatchingBrace(cleaned, start);
  }

  if (start < 0 || end <= start) {
    start = cleaned.indexOf('{');
    end = cleaned.lastIndexOf('}');
  }

  if (start < 0 || end <= start) return null;
  final candidate = cleaned.substring(start, end + 1);
  try {
    final obj = jsonDecode(candidate) as Map<String, dynamic>;
    if (!obj.containsKey('foods')) return null;
    return obj;
  } catch (_) {
    return null;
  }
}

int _findMatchingBrace(String s, int openIndex) {
  int depth = 0;
  bool inString = false;
  for (int i = openIndex; i < s.length; i++) {
    final ch = s[i];
    if (ch == '"') {
      inString = !inString;
      continue;
    }
    if (inString) continue;
    if (ch == '{') depth++;
    if (ch == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}
