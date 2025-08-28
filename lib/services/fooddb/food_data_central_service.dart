import 'package:dio/dio.dart';

class FoodDbItem {
  final String description;
  final String? brand;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  // Source database identifier: 'FDC' or 'OFF'
  final String source;
  // Optional image URL when available (e.g., OFF products)
  final String? imageUrl;

  const FoodDbItem({
    required this.description,
    this.brand,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.source,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'brand': brand,
        'caloriesPer100g': caloriesPer100g,
        'carbsPer100g': carbsPer100g,
        'proteinPer100g': proteinPer100g,
        'fatPer100g': fatPer100g,
        'source': source,
        'imageUrl': imageUrl,
      };

  factory FoodDbItem.fromJson(Map<String, dynamic> json) => FoodDbItem(
        description: (json['description'] as String?) ?? '',
        brand: json['brand'] as String?,
        caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble() ?? 0,
        carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0,
        proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0,
        fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0,
        source: (json['source'] as String?) ?? 'FDC',
        imageUrl: json['imageUrl'] as String?,
      );
}

class FoodDataCentralService {
  final String? apiKey;
  final Dio _dio;

  FoodDataCentralService({this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.nal.usda.gov/fdc/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  bool get isEnabled => (apiKey != null && apiKey!.isNotEmpty);

  Future<List<FoodDbItem>> searchFoods(String query) async {
    if (!isEnabled) return [];
    try {
      final response = await _dio.get(
        '/foods/search',
        queryParameters: {
          'api_key': apiKey,
          'query': query,
          'pageSize': 5,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final foods = (data['foods'] as List?) ?? [];
      return foods.map((f) => _parseFood(f)).whereType<FoodDbItem>().toList();
    } catch (_) {
      return [];
    }
  }

  FoodDbItem? _parseFood(dynamic f) {
    if (f is! Map) return null;
    String desc = (f['description'] as String?)?.trim() ?? '';
    if (desc.isEmpty) return null;
    String? brand = (f['brandOwner'] as String?)?.trim();

    double kcal = 0, carbs = 0, prot = 0, fat = 0;

    // Try labelNutrients first (often present for packaged foods)
    final ln = f['labelNutrients'] as Map<String, dynamic>?;
    if (ln != null) {
      kcal = (ln['calories']?['value'] as num?)?.toDouble() ?? kcal;
      carbs = (ln['carbohydrates']?['value'] as num?)?.toDouble() ?? carbs;
      prot = (ln['protein']?['value'] as num?)?.toDouble() ?? prot;
      fat = (ln['fat']?['value'] as num?)?.toDouble() ?? fat;
    }

    // Fallback: iterate foodNutrients for energy/carbs/protein/fat per 100g
    final nutrients = (f['foodNutrients'] as List?) ?? [];
    for (final n in nutrients) {
      if (n is! Map) continue;
      final name = (n['nutrientName'] as String?)?.toLowerCase() ?? '';
      final unit = (n['unitName'] as String?)?.toLowerCase() ?? '';
      final val = (n['value'] as num?)?.toDouble();
      if (val == null) continue;
      if (name.contains('energy') && unit == 'kcal') kcal = val;
      if (name.contains('carbohydrate')) carbs = val;
      if (name.contains('protein')) prot = val;
      if (name.contains('fat')) fat = val;
    }

    return FoodDbItem(
      description: desc,
      brand: brand,
      caloriesPer100g: kcal,
      carbsPer100g: carbs,
      proteinPer100g: prot,
      fatPer100g: fat,
      source: 'FDC',
    );
  }
}
