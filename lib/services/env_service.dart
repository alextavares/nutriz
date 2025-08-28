import 'dart:convert';
import 'package:flutter/services.dart';

/// Simple environment service that reads keys from assets/env.json.
/// Use for non-secret development keys when avoiding --dart-define.
class EnvService {
  static Map<String, dynamic>? _cache;

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    try {
      final raw = await rootBundle.loadString('env.json');
      _cache = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _cache = <String, dynamic>{};
    }
  }

  /// Returns a value from env.json, or null if missing.
  static Future<String?> get(String key) async {
    await _ensureLoaded();
    final v = _cache?[key];
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }
}
