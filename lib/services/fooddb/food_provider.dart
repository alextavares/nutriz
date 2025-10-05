import 'package:flutter/foundation.dart';


import '../env_service.dart';
import 'food_data_central_service.dart';
import 'open_food_facts_service.dart';
import 'nlq_ninjas_service.dart';

/// Unified provider that queries Open Food Facts and USDA FDC,
/// then normalizes results to the UI map used by FoodLoggingScreen.
class FoodProvider {
  final FoodDataCentralService fdc;
  final OpenFoodFactsService off;
  final NinjasNlqService nlq;

  // In-memory cache with TTL and size cap
  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const int _cacheMaxEntries = 200;
  QueryMetrics? _lastMetrics;

  FoodProvider({required this.fdc, required this.off, required this.nlq});

  /// Creates a provider reading FDC key from --dart-define or env.json
  static Future<FoodProvider> createFromEnv() async {
    String fdcKey = const String.fromEnvironment('FDC_API_KEY');
    if (fdcKey.isEmpty) {
      final fromEnv = await EnvService.get('FDC_API_KEY');
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        fdcKey = fromEnv.trim();
      }
    }
    String ninjasKey = const String.fromEnvironment('NINJAS_API_KEY');
    if (ninjasKey.isEmpty) {
      final fromEnv = await EnvService.get('NINJAS_API_KEY');
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        ninjasKey = fromEnv.trim();
      }
    }
    final fdc = FoodDataCentralService(apiKey: fdcKey.isEmpty ? null : fdcKey);
    final off = OpenFoodFactsService();
    final nlq = NinjasNlqService(apiKey: ninjasKey.isEmpty ? null : ninjasKey);
    return FoodProvider(fdc: fdc, off: off, nlq: nlq);
  }

  /// Search foods by free text. Combines OFF and FDC, removes duplicates,
  /// and returns up to [limit] normalized items.
  Future<List<Map<String, dynamic>>> search(String query, {int limit = 20, bool useNlq = true}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final now = DateTime.now();
    final cached = _cache[q];
    if (cached != null && now.difference(cached.savedAt) < _cacheTtl) {
      if (kDebugMode) {
        final age = now.difference(cached.savedAt).inSeconds;
        // ignore: avoid_print
        print('[FoodProvider] cache hit "$q" (age ${age}s, size ${cached.results.length})');
      }
      _lastMetrics = QueryMetrics(
        query: q,
        totalItems: cached.results.length,
        dedupItems: cached.results.length,
        limit: limit,
        runs: const [],
        cacheHit: true,
        cacheAgeSec: now.difference(cached.savedAt).inSeconds,
      );
      return cached.results;
    }

    List<Map<String, dynamic>> results = [];

    // Run providers in parallel and swallow individual errors
    final tasks = <Future<_ProviderRun>>[];
    if (useNlq && nlq.isEnabled && _looksLikeNlq(q)) {
      tasks.add(_runProvider('NLQ', nlq.parse(q)));
    }
    tasks.add(_runProvider('OFF', off.search(q)));
    if (fdc.isEnabled) tasks.add(_runProvider('FDC', fdc.searchFoods(q)));

    final runs = await Future.wait<_ProviderRun>(tasks);
    for (final run in runs) {
      results.addAll(run.items.map(_toUiMap));
    }

    // Dedup by name + brand (case-insensitive)
    final seen = <String>{};
    final dedup = <Map<String, dynamic>>[];
    for (final m in results) {
      final key = '${(m['name'] ?? '').toString().toLowerCase()}|${(m['brand'] ?? '').toString().toLowerCase()}';
      if (key.trim().isEmpty) continue;
      if (seen.add(key)) dedup.add(m);
      if (dedup.length >= limit) break;
    }

    _saveCache(q, dedup);
    _lastMetrics = QueryMetrics(
      query: q,
      totalItems: results.length,
      dedupItems: dedup.length,
      limit: limit,
      runs: runs,
      cacheHit: false,
      cacheAgeSec: null,
    );

    if (kDebugMode) {
      // Summary logging
      final totalItems = results.length;
      final dedupItems = dedup.length;
      // ignore: avoid_print
      print('[FoodProvider] query="$q" total=$totalItems dedup=$dedup limit=$limit');
      for (final r in runs) {
        // ignore: avoid_print
        print('[FoodProvider]  - ${r.label}: ${r.items.length} itens em ${r.ms} ms');
      }
    }
    return dedup;
  }

  /// Expose NLQ parsing directly when needed by the UI or coach.
  Future<List<Map<String, dynamic>>> parseNlq(String text) async {
    if (!nlq.isEnabled) return [];
    try {
      final items = await nlq.parse(text);
      return items.map(_toUiMap).toList();
    } catch (_) {
      return [];
    }
  }

  /// Lookup by barcode via OFF.
  Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    try {
      final item = await off.getByBarcode(barcode);
      if (item == null) return null;
      final m = _toUiMap(item);
      m['barcode'] = barcode;
      return m;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _toUiMap(FoodDbItem item) {
    return {
      'id': '${item.source}:${item.description}'.hashCode,
      'name': item.description,
      'brand': item.brand ?? 'Genérico',
      'calories': item.caloriesPer100g.round(),
      'carbs': item.carbsPer100g.toDouble(),
      'protein': item.proteinPer100g.toDouble(),
      'fat': item.fatPer100g.toDouble(),
      'serving': '100 g',
      'source': item.source,
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) 'imageUrl': item.imageUrl,
    };
  }

  bool _looksLikeNlq(String q) {
    // Heuristics: contains a digit or common portion/unit keywords
    final hasDigit = RegExp(r'[0-9]').hasMatch(q);
    final hasUnit = RegExp(
            r'\b(grama|gramas|g|kg|ml|l|x|fatia|fatias|colher|colheres|copo|copos|por[cç][aã]o|scoop|sach[eê]|unid|unidade)\b',
            caseSensitive: false)
        .hasMatch(q);
    return hasDigit || hasUnit;
  }

  Future<List<FoodDbItem>> _safe(Future<List<FoodDbItem>> f) async {
    try {
      return await f;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FoodProvider] provider error: $e');
      }
      return <FoodDbItem>[];
    }
  }

  Future<_ProviderRun> _runProvider(String label, Future<List<FoodDbItem>> future) async {
    final sw = Stopwatch()..start();
    final items = await _safe(future);
    sw.stop();
    return _ProviderRun(label, items, sw.elapsedMilliseconds);
  }

  void _saveCache(String key, List<Map<String, dynamic>> value) {
    _cache[key] = _CacheEntry(value, DateTime.now());
    if (_cache.length > _cacheMaxEntries) {
      // Evict oldest
      String? oldestKey;
      DateTime oldest = DateTime.now();
      _cache.forEach((k, v) {
        if (v.savedAt.isBefore(oldest)) {
          oldest = v.savedAt;
          oldestKey = k;
        }
      });
      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
  }
}

class _CacheEntry {
  final List<Map<String, dynamic>> results;
  final DateTime savedAt;
  _CacheEntry(this.results, this.savedAt);
}

class _ProviderRun {
  final String label;
  final List<FoodDbItem> items;
  final int ms;
  _ProviderRun(this.label, this.items, this.ms);
}

class QueryMetrics {
  final String query;
  final int totalItems;
  final int dedupItems;
  final int limit;
  final List<_ProviderRun> runs;
  final bool cacheHit;
  final int? cacheAgeSec;
  const QueryMetrics({
    required this.query,
    required this.totalItems,
    required this.dedupItems,
    required this.limit,
    required this.runs,
    required this.cacheHit,
    required this.cacheAgeSec,
  });

  Map<String, dynamic> toMap() => {
        'query': query,
        'totalItems': totalItems,
        'dedupItems': dedupItems,
        'limit': limit,
        'cacheHit': cacheHit,
        'cacheAgeSec': cacheAgeSec,
        'providers': runs
            .map((r) => {
                  'label': r.label,
                  'items': r.items.length,
                  'ms': r.ms,
                })
            .toList(),
      };
}

extension FoodProviderDebug on FoodProvider {
  /// Returns last query metrics (for UI debug). Null if no search yet.
  Map<String, dynamic>? getLastMetrics() => _lastMetrics?.toMap();
}
