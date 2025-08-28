import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BodyMetricsStorage {
  static const String _prefix = 'body_metrics_v1_';

  static String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Returns a map of metrics for the day or {} if none.
  static Future<Map<String, dynamic>> getForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${_dateKey(date)}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final obj = jsonDecode(raw);
      if (obj is Map<String, dynamic>) return obj;
    } catch (_) {}
    return {};
  }

  /// Saves metrics for given date. Overwrites existing for that date.
  /// Expected fields (all optional):
  /// weightKg, heightCm, bodyFatPct, waistCm, hipCm, chestCm, notes
  static Future<void> setForDate(DateTime date, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${_dateKey(date)}';
    await prefs.setString(key, jsonEncode(data));
  }

  /// Returns last [days] entries as list of (dateKey, map), ordered ascending by date.
  static Future<List<(DateTime, Map<String, dynamic>)>> getRecent({int days = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    keys.sort();
    final out = <(DateTime, Map<String, dynamic>)>[];
    for (final k in keys.reversed) {
      final raw = prefs.getString(k);
      if (raw == null) continue;
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final dateStr = k.substring(_prefix.length);
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final d = DateTime(
            int.tryParse(parts[0]) ?? 1970,
            int.tryParse(parts[1]) ?? 1,
            int.tryParse(parts[2]) ?? 1,
          );
          out.add((d, m));
        }
      } catch (_) {}
      if (out.length >= days) break;
    }
    out.sort((a, b) => a.$1.compareTo(b.$1));
    return out;
  }
}

