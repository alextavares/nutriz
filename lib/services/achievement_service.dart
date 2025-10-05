import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AchievementService {
  static const _kAchievements = 'achievements_v1';
  static const _kLastAddedTs = 'achievements_last_added_ts_v1';
  static const _kLastSeenTs = 'achievements_last_seen_ts_v1';
  static const _kFavorites = 'achievements_favorites_v1';

  static Future<List<Map<String, dynamic>>> listAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAchievements);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(Map<String, dynamic> achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await listAll();
    list.add(achievement);
    await prefs.setString(_kAchievements, jsonEncode(list));
    await prefs.setInt(_kLastAddedTs, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAchievements);
    await prefs.remove(_kLastAddedTs);
    await prefs.remove(_kLastSeenTs);
  }

  static Future<int> getLastAddedTs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLastAddedTs) ?? 0;
  }

  static Future<int> getLastSeenTs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLastSeenTs) ?? 0;
  }

  static Future<void> setLastSeenTs(int ts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastSeenTs, ts);
  }

  // Favorites handling -------------------------------------------------------
  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFavorites);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final List<dynamic> list = (jsonDecode(raw) as List<dynamic>);
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> setFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFavorites, jsonEncode(ids.toList()));
  }

  static Future<bool> isFavorite(String id) async {
    final favs = await getFavorites();
    return favs.contains(id);
  }

  static Future<bool> toggleFavorite(String id) async {
    final favs = await getFavorites();
    if (favs.contains(id)) {
      favs.remove(id);
      await setFavorites(favs);
      return false;
    } else {
      favs.add(id);
      await setFavorites(favs);
      return true;
    }
  }
}
