import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FastingStorage {
  static const String _kActive = 'fasting_active_v1';
  static const String _kStartIso = 'fasting_start_iso_v1';
  static const String _kMethod = 'fasting_method_v1';
  static const String _kTargetSecs = 'fasting_target_secs_v1';
  static const String _kHistory = 'fasting_history_v1'; // JSON map: date(YYYY-MM-DD) -> entry
  static const String _kCustomTargetSecs = 'fasting_custom_target_secs_v1';

  // Start a fasting session
  static Future<void> start({
    required String method,
    required DateTime start,
    required Duration target,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, true);
    await prefs.setString(_kStartIso, start.toIso8601String());
    await prefs.setString(_kMethod, method);
    await prefs.setInt(_kTargetSecs, target.inSeconds);
  }

  // Returns null if no active fast
  static Future<({String method, DateTime start, Duration target})?> getActive() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_kActive) ?? false;
    if (!active) return null;
    final startIso = prefs.getString(_kStartIso);
    final method = prefs.getString(_kMethod) ?? '16:8';
    final targetSecs = prefs.getInt(_kTargetSecs) ?? 16 * 3600;
    if (startIso == null) return null;
    try {
      final start = DateTime.parse(startIso);
      return (method: method, start: start, target: Duration(seconds: targetSecs));
    } catch (_) {
      return null;
    }
  }

  // Stop now and record history; returns actual duration
  static Future<Duration?> stopNow() async {
    final active = await getActive();
    if (active == null) return null;
    final now = DateTime.now();
    final elapsed = now.difference(active.start);
    await _recordHistory(date: now, duration: elapsed, method: active.method);
    await _clearActive();
    return elapsed;
  }

  static Future<void> _clearActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActive);
    await prefs.remove(_kStartIso);
    await prefs.remove(_kMethod);
    await prefs.remove(_kTargetSecs);
  }

  static Future<void> _recordHistory({
    required DateTime date,
    required Duration duration,
    required String method,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistory);
    Map<String, dynamic> map = {};
    if (raw != null && raw.isNotEmpty) {
      try { map = jsonDecode(raw) as Map<String, dynamic>; } catch (_) {}
    }
    String two(int v) => v.toString().padLeft(2, '0');
    final key = '${date.year}-${two(date.month)}-${two(date.day)}';
    map[key] = {
      'duration_secs': duration.inSeconds,
      'method': method,
      'saved_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_kHistory, jsonEncode(map));
  }

  static Future<Map<String, dynamic>> getHistoryMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistory);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<List<({DateTime date, Duration duration, String method})>>
      getHistoryInRange(DateTime start, DateTime end) async {
    // Normalize to inclusive day boundaries to avoid time-of-day exclusion
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final map = await getHistoryMap();
    final out = <({DateTime date, Duration duration, String method})>[];
    for (final entry in map.entries) {
      try {
        final d = DateTime.parse(entry.key);
        if (!d.isBefore(startDay) && !d.isAfter(endDay)) {
          final m = entry.value as Map<String, dynamic>;
          out.add((
            date: d,
            duration: Duration(seconds: (m['duration_secs'] as num?)?.toInt() ?? 0),
            method: (m['method'] as String?) ?? '16:8',
          ));
        }
      } catch (_) {}
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  static Future<int> getTotalFastingDays() async {
    final map = await getHistoryMap();
    return map.length;
  }

  static Future<int> getCurrentStreak({Duration threshold = const Duration(hours: 12)}) async {
    // Count back from today inclusive while days meet threshold
    final map = await getHistoryMap();
    int streak = 0;
    DateTime cursor = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    while (true) {
      final key = '${cursor.year}-${two(cursor.month)}-${two(cursor.day)}';
      final m = map[key] as Map<String, dynamic>?;
      final secs = (m?['duration_secs'] as num?)?.toInt() ?? 0;
      if (secs >= threshold.inSeconds) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Custom method target
  static Future<void> setCustomTarget(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCustomTargetSecs, duration.inSeconds);
  }

  static Future<Duration> getCustomTarget({Duration fallback = const Duration(hours: 14)}) async {
    final prefs = await SharedPreferences.getInstance();
    final secs = prefs.getInt(_kCustomTargetSecs);
    if (secs == null) return fallback;
    return Duration(seconds: secs);
  }
}
