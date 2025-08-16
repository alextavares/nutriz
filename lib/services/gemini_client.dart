import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class GeminiClient {
  final Dio dio;
  final String apiKey;

  GeminiClient(this.dio, this.apiKey);

  Future<Completion> createMultimodal({
    required String prompt,
    required File image,
    String model = 'gemini-1.5-flash-002',
    List<String>? modelCandidates,
    int maxTokens = 1024,
    int maxRetriesPerModel = 3,
  }) async {
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final candidates = modelCandidates ?? <String>[
      model,
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash-8b',
      'gemini-1.0-pro-vision',
      'gemini-pro-vision',
    ];

    DioException? lastDioError;
    GeminiException? lastGeminiError;

    for (final m in candidates) {
      for (int attempt = 1; attempt <= maxRetriesPerModel; attempt++) {
        try {
          final response = await dio.post(
            '/models/$m:generateContent',
            queryParameters: {'key': apiKey},
            data: {
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                    {
                      'inlineData': {
                        'mimeType': 'image/jpeg',
                        'data': base64Image,
                      }
                    }
                  ]
                }
              ],
              'generationConfig': {
                'maxOutputTokens': maxTokens,
              },
            },
          );

          if (response.data['candidates'] != null &&
              response.data['candidates'].isNotEmpty &&
              response.data['candidates'][0]['content'] != null) {
            final parts = response.data['candidates'][0]['content']['parts'];
            final text = parts.isNotEmpty ? parts[0]['text'] : '';
            return Completion(text: text);
          } else {
            lastGeminiError = GeminiException(
              statusCode: response.statusCode ?? 500,
              message: 'Failed to parse response or empty response',
            );
            break;
          }
        } on DioException catch (e) {
          lastDioError = e;
          final code = e.response?.statusCode ?? 0;
          final msg = e.response?.data?['error']?['message'] ?? e.message ?? '';
          final gcode = e.response?.data?['error']?['status'] ?? '';

          final transient =
              code == 429 || code == 503 || gcode == 'RESOURCE_EXHAUSTED' || gcode == 'UNAVAILABLE';

          if (attempt < maxRetriesPerModel && transient) {
            final backoffMs = (pow(2, attempt) as num).toInt() * 500 + Random().nextInt(400);
            await Future.delayed(Duration(milliseconds: backoffMs));
            continue;
          }
          // break to try next model
          break;
        }
      }
      // try next candidate model
    }

    if (lastGeminiError != null) {
      throw lastGeminiError;
    }
    if (lastDioError != null) {
      throw GeminiException(
        statusCode: lastDioError.response?.statusCode ?? 500,
        message: lastDioError.response?.data?['error']?['message'] ?? lastDioError.message ?? 'Request failed',
      );
    }
    throw GeminiException(statusCode: 503, message: 'All model attempts failed');
  }

  Future<FoodNutritionData> analyzeFoodImage(File imageFile) async {
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

Please provide realistic nutritional values per typical serving size. If multiple food items are detected, include all of them. If the image doesn't clearly show food, return an empty foods array.
''';

    try {
      final completion = await createMultimodal(
        prompt: prompt,
        image: imageFile,
        maxTokens: 1024,
        modelCandidates: const [
          'gemini-1.5-flash-002',
          'gemini-1.5-flash-latest',
          'gemini-1.5-flash-8b',
          'gemini-1.0-pro-vision',
          'gemini-pro-vision',
        ],
      );

      // Extract JSON from the response text
      final responseText = completion.text;
      final jsonStartIndex = responseText.indexOf('{');
      final jsonEndIndex = responseText.lastIndexOf('}') + 1;

      if (jsonStartIndex == -1 || jsonEndIndex == 0) {
        throw GeminiException(
          statusCode: 422,
          message: 'Could not parse nutritional data from response',
        );
      }

      final jsonString = responseText.substring(jsonStartIndex, jsonEndIndex);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return FoodNutritionData.fromJson(jsonData);
    } catch (e) {
      if (e is GeminiException) {
        rethrow;
      }
      throw GeminiException(
        statusCode: 500,
        message: 'Failed to analyze food image: ${e.toString()}',
      );
    }
  }
}

class Completion {
  final String text;

  Completion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
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

  Map<String, dynamic> toFoodMap() {
    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'brand': 'AI Detected',
      'portion_size': portionSize,
      'confidence': confidence,
    };
  }
}
