import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _kFavorites = 'favorite_foods_v1';
  static const String _kMyFoods = 'my_foods_v1';

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFavorites);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setFavorites(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(items));
  }

  static Future<void> toggleFavorite(Map<String, dynamic> food) async {
    final list = await getFavorites();
    final name = (food['name'] as String?) ?? '';
    final idx = list.indexWhere((e) => (e['name'] as String?) == name);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.add(food);
    }
    await setFavorites(list);
  }

  static Future<bool> isFavorite(String name) async {
    final list = await getFavorites();
    return list.any((e) => (e['name'] as String?) == name);
  }

  static Future<List<Map<String, dynamic>>> getMyFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMyFoods);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setMyFoods(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMyFoods, jsonEncode(items));
  }

  static Future<void> addMyFood(Map<String, dynamic> food) async {
    final list = await getMyFoods();
    // Avoid duplicates by name
    final name = (food['name'] as String?) ?? '';
    final idx = list.indexWhere((e) => (e['name'] as String?) == name);
    if (idx >= 0) {
      list[idx] = food;
    } else {
      list.add(food);
    }
    await setMyFoods(list);
  }

  static Future<void> removeMyFoodByName(String name) async {
    final list = await getMyFoods();
    list.removeWhere((e) => (e['name'] as String?) == name);
    await setMyFoods(list);
  }
}


