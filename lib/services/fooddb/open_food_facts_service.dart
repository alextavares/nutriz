import 'package:dio/dio.dart';

import 'food_data_central_service.dart';

class OpenFoodFactsService {
  final Dio _dio;

  OpenFoodFactsService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://world.openfoodfacts.org',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<List<FoodDbItem>> search(String query) async {
    try {
      final response = await _dio.get('/cgi/search.pl', queryParameters: {
        'search_terms': query,
        'search_simple': 1,
        'json': 1,
        'page_size': 5,
      });
      final data = response.data as Map<String, dynamic>;
      final products = (data['products'] as List?) ?? [];
      return products
          .map((p) => _parseProduct(p))
          .whereType<FoodDbItem>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Lookup by barcode
  Future<FoodDbItem?> getByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/api/v0/product/$barcode.json');
      final data = response.data as Map<String, dynamic>;
      if ((data['status'] as num?)?.toInt() != 1) return null;
      final product = data['product'];
      return _parseProduct(product);
    } catch (_) {
      return null;
    }
  }

  FoodDbItem? _parseProduct(dynamic p) {
    if (p is! Map) return null;
    final desc = (p['product_name'] as String?)?.trim();
    if (desc == null || desc.isEmpty) return null;
    final brand = (p['brands'] as String?)?.split(',').first.trim();

    double kcal = 0, carbs = 0, prot = 0, fat = 0;
    final nutriments = p['nutriments'] as Map<String, dynamic>?;
    if (nutriments != null) {
      kcal = (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? kcal;
      carbs = (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? carbs;
      prot = (nutriments['proteins_100g'] as num?)?.toDouble() ?? prot;
      fat = (nutriments['fat_100g'] as num?)?.toDouble() ?? fat;
    }

    // Try to fetch a decent product image
    final imageUrl = (p['image_url'] as String?) ??
        (p['image_front_url'] as String?) ??
        (p['image_small_url'] as String?);

    return FoodDbItem(
      description: desc,
      brand: brand,
      caloriesPer100g: kcal,
      carbsPer100g: carbs,
      proteinPer100g: prot,
      fatPer100g: fat,
      source: 'OFF',
      imageUrl: imageUrl,
    );
  }
}
