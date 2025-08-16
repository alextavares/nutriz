import 'dart:math';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'food_data_central_service.dart';
import 'open_food_facts_service.dart';

class FoodNormalizerService {
  final FoodDataCentralService fdc;
  final OpenFoodFactsService off;
  final Map<String, FoodDbItem> _cache = {};
  static const String kPrefsKey = 'food_normalizer_cache_v1';
  static const String _prefsKey = kPrefsKey;
  static const Duration _ttl = Duration(days: 30);

  Map<String, dynamic>? _diskCache; // { items: {query: itemJson}, ts: epochMs }

  FoodNormalizerService({required this.fdc, required this.off});

  // Given a raw name, find best matching canonical item
  Future<void> _ensureDiskLoaded() async {
    if (_diskCache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      _diskCache = {
        'items': <String, dynamic>{},
        'ts': DateTime.now().millisecondsSinceEpoch
      };
      return;
    }
    try {
      _diskCache = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _diskCache = {
        'items': <String, dynamic>{},
        'ts': DateTime.now().millisecondsSinceEpoch
      };
    }
  }

  Future<void> _saveDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_diskCache));
  }

  bool _isExpired() {
    final ts = (_diskCache?['ts'] as int?) ?? 0;
    final then = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: false);
    return DateTime.now().difference(then) > _ttl;
  }

  FoodDbItem? _getFromDisk(String q) {
    final items = (_diskCache?['items'] as Map?)?.cast<String, dynamic>();
    if (items == null) return null;
    final raw = items[q];
    if (raw == null) return null;
    try {
      return FoodDbItem.fromJson((raw as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> _putToDisk(String q, FoodDbItem item) async {
    final items = (_diskCache?['items'] as Map?)?.cast<String, dynamic>();
    if (items == null) return;
    items[q] = item.toJson();
    _diskCache!['ts'] = DateTime.now().millisecondsSinceEpoch;
    await _saveDisk();
  }

  Future<FoodDbItem?> findBestMatch(String rawName) async {
    final q = rawName.trim().toLowerCase();
    final cached = _cache[q];
    if (cached != null) return cached;
    await _ensureDiskLoaded();
    if (!_isExpired()) {
      final diskItem = _getFromDisk(q);
      if (diskItem != null) {
        _cache[q] = diskItem;
        return diskItem;
      }
    }
    List<FoodDbItem> candidates = [];

    // FDC first if enabled
    candidates.addAll(await fdc.searchFoods(q));
    // OFF fallback
    if (candidates.isEmpty) {
      candidates.addAll(await off.search(q));
    }
    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => _score(q, b).compareTo(_score(q, a)));
    final best = candidates.first;
    _cache[q] = best;
    await _putToDisk(q, best);
    return best;
  }

  int _score(String q, FoodDbItem item) {
    final base = item.description.toLowerCase();
    int s = 0;
    if (base == q) s += 1000;
    if (base.contains(q)) s += 200;
    s += _lcs(base, q);
    return s;
  }

  int _lcs(String a, String b) {
    // simple LCS length for fuzzy scoring
    final dp =
        List.generate(a.length + 1, (_) => List<int>.filled(b.length + 1, 0));
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }
    return dp[a.length][b.length];
  }
}
