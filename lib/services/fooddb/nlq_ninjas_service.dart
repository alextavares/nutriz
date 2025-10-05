import 'package:dio/dio.dart';

import 'food_data_central_service.dart';

/// Natural Language Query nutrition provider using API Ninjas
/// Docs: https://api-ninjas.com/api/nutrition
class NinjasNlqService {
  final String? apiKey;
  final Dio _dio;

  NinjasNlqService({this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.api-ninjas.com/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    if (apiKey != null && apiKey!.isNotEmpty) {
      _dio.options.headers['X-Api-Key'] = apiKey;
    }
  }

  bool get isEnabled => (apiKey != null && apiKey!.isNotEmpty);

  /// Parses a free-text query like "2 ovos e 1 banana 100g"
  /// Returns items normalized as FoodDbItem with nutrition per 100g when possible.
  Future<List<FoodDbItem>> parse(String text) async {
    if (!isEnabled) return [];
    final q = text.trim();
    if (q.isEmpty) return [];
    try {
      final response = await _dio.get('/nutrition', queryParameters: {
        'query': q,
      });
      final data = response.data;
      if (data is! List) return [];

      final List<FoodDbItem> items = [];
      for (final e in data) {
        if (e is! Map) continue;
        final name = (e['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;

        // API Ninjas fields are per reported serving
        final servingG = (e['serving_size_g'] as num?)?.toDouble() ?? 0;
        final kcal = (e['calories'] as num?)?.toDouble();
        final carbs = (e['carbohydrates_total_g'] as num?)?.toDouble();
        final protein = (e['protein_g'] as num?)?.toDouble();
        final fat = (e['fat_total_g'] as num?)?.toDouble();

        double per100(double? v) {
          if (v == null) return 0;
          if (servingG <= 0) return v; // best-effort if serving info missing
          return v / servingG * 100.0;
        }

        items.add(FoodDbItem(
          description: _capitalize(name),
          brand: null,
          caloriesPer100g: per100(kcal),
          carbsPer100g: per100(carbs),
          proteinPer100g: per100(protein),
          fatPer100g: per100(fat),
          source: 'NLQ',
        ));
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

