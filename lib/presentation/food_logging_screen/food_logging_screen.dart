// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';
import '../../services/favorites_storage.dart';
import '../../services/fooddb/open_food_facts_service.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/food_search_results_widget.dart';
import './widgets/manual_entry_widget.dart';
import './widgets/search_bar_widget.dart';
import '../../services/user_preferences.dart';
import '../../services/fooddb/food_provider.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

// Portion picker widget (top-level)
class _PortionPicker extends StatefulWidget {
  final Key? key;
  final Map<String, dynamic> food;
  final void Function(Map<String, dynamic> updated) onApply;
  final void Function(Map<String, dynamic> updated)? onApplyAndSave;

  const _PortionPicker({
    this.key,
    required this.food,
    required this.onApply,
    this.onApplyAndSave,
  }) : super(key: key);

  @override
  State<_PortionPicker> createState() => _PortionPickerState();
}

class _PortionPickerState extends State<_PortionPicker> {
  String unit = 'g';
  double quantity = 200; // default closer to porção comum
  double gramsPerPortion = 100;
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  final TextEditingController _gramsCtrl = TextEditingController(text: '100');
  Map<String, double> unitPresets = {
    'unidade': 100,
    'colher': 15,
    'xícara': 240,
  };
  bool saveAsDefault = false;

  @override
  void initState() {
    super.initState();
    final servingStr = (widget.food['serving'] as String?);
    final match =
        servingStr != null ? RegExp(r"(\d+)\s*g").firstMatch(servingStr) : null;
    if (match != null) {
      unit = 'g';
      gramsPerPortion = 1;
      quantity = double.tryParse(match.group(1)!) ?? quantity;
    } else {
      unit = 'unidade';
      gramsPerPortion = 100;
    }
    _qtyCtrl.text = quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1);
    _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
    _loadPresetsIfAny();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _gramsCtrl.dispose();
    super.dispose();
  }

  String formatNum(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  double _baseGrams() {
    final servingStr = (widget.food['serving'] as String?);
    final match =
        servingStr != null ? RegExp(r"(\d+)\s*g").firstMatch(servingStr) : null;
    return match != null
        ? (double.tryParse(match.group(1)!) ?? 100)
        : gramsPerPortion;
  }

  double _totalGrams() {
    if (unit == 'g') return quantity;
    return quantity * gramsPerPortion;
  }

  Map<String, num> _preview() {
    final gramsBase = _baseGrams();
    final perGramCal = (widget.food['calories'] as num).toDouble() /
        (gramsBase > 0 ? gramsBase : 100);
    final perGramCarb = (widget.food['carbs'] as num).toDouble() /
        (gramsBase > 0 ? gramsBase : 100);
    final perGramProt = (widget.food['protein'] as num).toDouble() /
        (gramsBase > 0 ? gramsBase : 100);
    final perGramFat = (widget.food['fat'] as num).toDouble() /
        (gramsBase > 0 ? gramsBase : 100);
    final g = _totalGrams();
    return {
      'cal': perGramCal * g,
      'carb': perGramCarb * g,
      'prot': perGramProt * g,
      'fat': perGramFat * g,
      'grams': g,
    };
  }

  // Expose preview to parent (for quick add CTA)
  Map<String, num> currentPreview() => _preview();

  Map<String, dynamic> buildUpdatedFoodFromPreview() =>
      _buildUpdatedFood(_preview());

  Future<void> _loadPresetsIfAny() async {
    try {
      final myFoods = await FavoritesStorage.getMyFoods();
      final name = (widget.food['name'] as String?) ?? '';
      final existing = myFoods.firstWhere(
        (e) => (e['name'] as String?) == name,
        orElse: () => {},
      );
      if (existing.isNotEmpty) {
        final mp = existing['unitPresets'];
        if (mp is Map) {
          final parsed = <String, double>{};
          mp.forEach((k, v) {
            final key = k.toString();
            final val =
                (v is num) ? v.toDouble() : double.tryParse(v.toString());
            if (val != null) parsed[key] = val;
          });
          if (parsed.isNotEmpty) {
            setState(() {
              unitPresets.addAll(parsed);
              if (unit == 'unidade') {
                gramsPerPortion = unitPresets['unidade'] ?? gramsPerPortion;
              }
              if (unit == 'colher') {
                gramsPerPortion = unitPresets['colher'] ?? gramsPerPortion;
              }
              if (unit == 'xícara') {
                gramsPerPortion = unitPresets['xícara'] ?? gramsPerPortion;
              }
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroCell(
                  '${formatNum(preview['cal']!.toDouble())} kcal', 'Calorias'),
              _macroCell('${formatNum(preview['carb']!.toDouble())} g',
                  'Carboidratos'),
              _macroCell(
                  '${formatNum(preview['prot']!.toDouble())} g', 'Proteína'),
              _macroCell(
                  '${formatNum(preview['fat']!.toDouble())} g', 'Gordura'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Tamanho da porção (g)', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            _roundIconButton(
              icon: Icons.remove,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  quantity = (quantity - 10).clamp(1.0, 20000.0);
                  _qtyCtrl.text = quantity.toStringAsFixed(0);
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(hintText: 'gramas'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() {
                  final q = double.tryParse(v.trim());
                  if (q != null && q > 0) quantity = q;
                }),
              ),
            ),
            const SizedBox(width: 8),
            _roundIconButton(
              icon: Icons.add,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  quantity = (quantity + 10).clamp(1.0, 20000.0);
                  _qtyCtrl.text = quantity.toStringAsFixed(0);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _suggestChip('0,5x', () {
              final baseG = _baseGrams();
              setState(() {
                quantity = (baseG * 0.5).clamp(1.0, 20000.0);
                _qtyCtrl.text = quantity.toStringAsFixed(0);
              });
            }),
            _suggestChip('1x', () {
              final baseG = _baseGrams();
              setState(() {
                quantity = baseG;
                _qtyCtrl.text = quantity.toStringAsFixed(0);
              });
            }),
            _suggestChip('2x', () {
              final baseG = _baseGrams();
              setState(() {
                quantity = (baseG * 2).clamp(1.0, 20000.0);
                _qtyCtrl.text = quantity.toStringAsFixed(0);
              });
            }),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.onApplyAndSave != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final updated = _buildUpdatedFood(preview);
                await _maybeSavePreset(updated);
                widget.onApplyAndSave!(updated);
              },
              icon: const Icon(Icons.add),
              label: Text('Adicionar — ${preview['cal']!.round()} kcal'),
            ),
          ),
      ],
    );
  }

  Widget _roundIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, color: cs.primary),
      ),
    );
  }

  Widget _macroCell(String big, String label) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            big,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _suggestChip(String text, VoidCallback onTap) {
    return ActionChip(
      label: Text(text),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const StadiumBorder(),
    );
  }

  Map<String, dynamic> _buildUpdatedFood(Map<String, num> preview) {
    final updated = Map<String, dynamic>.from(widget.food);
    updated['calories'] = preview['cal']!.round();
    updated['carbs'] = double.parse(formatNum(preview['carb']!.toDouble()));
    updated['protein'] = double.parse(formatNum(preview['prot']!.toDouble()));
    updated['fat'] = double.parse(formatNum(preview['fat']!.toDouble()));
    updated['serving'] = '${formatNum(preview['grams']!.toDouble())} g';
    // Ensure consistency for downstream consumers
    updated['brand'] = updated['brand'] ?? 'Genérico';
    return updated;
  }

  Future<void> _maybeSavePreset(Map<String, dynamic> updated) async {
    if (!saveAsDefault || unit == 'g') return;
    if (unit == 'unidade') unitPresets['unidade'] = gramsPerPortion;
    if (unit == 'colher') unitPresets['colher'] = gramsPerPortion;
    if (unit == 'xícara') unitPresets['xícara'] = gramsPerPortion;
    final myFoods = await FavoritesStorage.getMyFoods();
    final name = (widget.food['name'] as String?) ?? '';
    Map<String, dynamic>? existing = myFoods.firstWhere(
      (e) => (e['name'] as String?) == name,
      orElse: () => {},
    );
    final toSave = {
      'name': name,
      'brand': widget.food['brand'],
      'calories': updated['calories'],
      'carbs': updated['carbs'],
      'protein': updated['protein'],
      'fat': updated['fat'],
      'unitPresets': unitPresets,
    };
    if (existing.isNotEmpty) {
      existing.addAll(toSave);
      await FavoritesStorage.addMyFood(existing);
    } else {
      await FavoritesStorage.addMyFood(toSave);
    }
  }
}

// Internal helper for usage aggregation
class _UsageAgg {
  final String name;
  final String brand;
  int count = 0;
  DateTime? lastUsed;
  Map<String, dynamic> sample = const {};
  _UsageAgg({required this.name, required this.brand});
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchDebounce;
  int _searchVersion = 0;
  dynamic _editId; // when set, updates existing entry instead of adding
  String? _editCreatedAtIso;

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  String _selectedMealTime = 'breakfast';
  bool _reviewOnly = false; // when true, show only review UI (no search/tabs)
  double _quantity = 1.0;
  String _servingSize = 'porção';
  bool _isLoading = false;
  bool _showBarcodeScanner = false;
  DateTime? _targetDate;
  String _activeTab = 'frequent'; // frequent | recent | favorites | mine
  bool _showPer100g = true; // results macros mode
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _myFoods = [];
  List<Map<String, dynamic>> _frequentFoods = [];
  List<Map<String, dynamic>> _recentComputed = [];
  // Default kcal range aligned to slider max (1500)
  RangeValues _kcalRange = const RangeValues(0, 1500);
  bool _filterProtein = false;
  bool _filterCarb = false;
  bool _filterFat = false;
  String _sortKey =
      'relevance'; // relevance | kcal | protein | carbs | favorites
  List<String> _searchHistory = [];
  // Exibir chips de filtros abaixo da busca? (mantido oculto para design limpo)
  bool _showFilterChips = false;
  // NLQ: interpretar quantidades no texto (API Ninjas)
  bool _useNlq = true;
  // Mostrar badges de fonte (OFF/FDC/NLQ)
  bool _showSourceBadges = true;

  // Mock data for recent foods
  final List<Map<String, dynamic>> _recentFoods = [
    {
      'id': 1,
      'name': 'Arroz Branco',
      'calories': 130,
      'carbs': 28,
      'protein': 3,
      'fat': 0,
      'brand': 'Genérico',
    },
    {
      'id': 2,
      'name': 'Frango Grelhado',
      'calories': 165,
      'carbs': 0,
      'protein': 31,
      'fat': 4,
      'brand': 'Genérico',
    },
    {
      'id': 3,
      'name': 'Feijão Preto',
      'calories': 132,
      'carbs': 24,
      'protein': 9,
      'fat': 1,
      'brand': 'Genérico',
    },
    {
      'id': 4,
      'name': 'Banana',
      'calories': 89,
      'carbs': 23,
      'protein': 1,
      'fat': 0,
      'brand': 'Natural',
    },
  ];

  // Mock food database
  final List<Map<String, dynamic>> _foodDatabase = [
    {
      'id': 1,
      'name': 'Arroz Branco Cozido',
      'calories': 130,
      'carbs': 28,
      'protein': 3,
      'fat': 0,
      'brand': 'Genérico',
    },
    {
      'id': 2,
      'name': 'Frango Grelhado',
      'calories': 165,
      'carbs': 0,
      'protein': 31,
      'fat': 4,
      'brand': 'Genérico',
    },
    {
      'id': 3,
      'name': 'Feijão Preto Cozido',
      'calories': 132,
      'carbs': 24,
      'protein': 9,
      'fat': 1,
      'brand': 'Genérico',
    },
    {
      'id': 4,
      'name': 'Banana Nanica',
      'calories': 89,
      'carbs': 23,
      'protein': 1,
      'fat': 0,
      'brand': 'Natural',
    },
    {
      'id': 5,
      'name': 'Pão Francês',
      'calories': 150,
      'carbs': 30,
      'protein': 5,
      'fat': 2,
      'brand': 'Padaria',
    },
    {
      'id': 6,
      'name': 'Leite Integral',
      'calories': 61,
      'carbs': 5,
      'protein': 3,
      'fat': 3,
      'brand': 'Nestlé',
    },
    {
      'id': 7,
      'name': 'Ovo Cozido',
      'calories': 78,
      'carbs': 1,
      'protein': 6,
      'fat': 5,
      'brand': 'Genérico',
    },
    {
      'id': 8,
      'name': 'Maçã Vermelha',
      'calories': 52,
      'carbs': 14,
      'protein': 0,
      'fat': 0,
      'brand': 'Natural',
    },
    {
      'id': 9,
      'name': 'Batata Doce Cozida',
      'calories': 86,
      'carbs': 20,
      'protein': 2,
      'fat': 0,
      'brand': 'Genérico',
    },
    {
      'id': 10,
      'name': 'Iogurte Natural',
      'calories': 59,
      'carbs': 4,
      'protein': 10,
      'fat': 0,
      'brand': 'Danone',
    },
  ];

  // Production data provider (OFF + FDC)
  FoodProvider? _foodProvider;

  Future<void> _initFoodProvider() async {
    try {
      final provider = await FoodProvider.createFromEnv();
      if (!mounted) return;
      setState(() {
        _foodProvider = provider;
      });
    } catch (_) {
      // keep null -> fallback remains mock list
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMealTime = _smartMealForTime(DateTime.now());
// Smart default meal by time of day
    _searchController.addListener(_onSearchChanged);
    // Prepare provider in background (won't block UI)
    _initFoodProvider();
    _loadFavsMy();
    _loadUsageLists();
    _restoreSearchFilters();
    _loadSearchHistory();
    // Read initial meal time from route args, if provided
    UserPreferences.getResultsShowPer100g().then((v) {
      if (mounted) setState(() => _showPer100g = v);
    });
    UserPreferences.getUseNlq().then((v) {
      if (mounted) setState(() => _useNlq = v);
    });
    UserPreferences.getShowSourceBadges().then((v) {
      if (mounted) setState(() => _showSourceBadges = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is String) {
          _mapMealNameToKey(args);
        } else if (args is Map) {
          final dynamic meal = args['mealName'] ?? args['mealKey'];
          if (meal is String) {
            _mapMealNameToKey(meal);
          }
          final dynamic reviewOnly = args['reviewOnly'];
          if (reviewOnly == true) {
            _reviewOnly = true;
          }
          final dynamic activeTab = args['activeTab'];
          if (activeTab is String &&
              (activeTab == 'recent' ||
                  activeTab == 'favorites' ||
                  activeTab == 'mine')) {
            setState(() => _activeTab = activeTab);
          }
          final dynamic prefillFood = args['prefillFood'];
          if (prefillFood is Map) {
            _selectedFood = prefillFood.cast<String, dynamic>();
            _searchResults = [prefillFood.cast<String, dynamic>()];
            if (args['reviewOnly'] == true) _reviewOnly = true;
          }
          final dynamic editId = args['editId'] ?? args['entryId'];
          if (editId != null) {
            _editId = editId;
            final ca = (_selectedFood?['createdAt'] as String?) ??
                (args['createdAt'] as String?);
            if (ca != null) _editCreatedAtIso = ca;
          }
          final dynamic prefillFoods = args['prefillFoods'];
          if (prefillFoods is List) {
            try {
              final list = prefillFoods.cast<Map<String, dynamic>>();
              if (list.isNotEmpty) {
                _selectedFood = list.first;
                _searchResults = list;
                if (args['reviewOnly'] == true) _reviewOnly = true;
              }
            } catch (_) {}
          }
          final dynamic openScanner = args['openScanner'];
          if (openScanner == true) {
            _showBarcodeScanner = true;
          }
          final dynamic dateArg = args['date'] ?? args['targetDate'];
          if (dateArg is DateTime) {
            _targetDate = DateTime(dateArg.year, dateArg.month, dateArg.day);
          } else if (dateArg is String) {
            // try parse ISO
            try {
              final parsed = DateTime.parse(dateArg);
              _targetDate = DateTime(parsed.year, parsed.month, parsed.day);
            } catch (_) {}
          }
        }
      }
      // Acessibilidade: focar a barra de busca quando não há alimento selecionado
      if (!_reviewOnly &&
          _selectedFood == null &&
          _searchController.text.isEmpty) {
        _searchFocus.requestFocus();
      }
    });
  }

  Future<void> _saveOrUpdateEntry(
      DateTime date, Map<String, dynamic> entry) async {
    if (_editId != null) {
      // Preserve createdAt if available
      final updated = Map<String, dynamic>.from(entry);
      if (_editCreatedAtIso != null) {
        updated['createdAt'] = _editCreatedAtIso;
      }
      await NutritionStorage.updateEntryById(date, _editId, updated);
    } else {
      await NutritionStorage.addEntry(date, entry);
    }
  }

  Future<void> _setShowPer100g(bool v) async {
    setState(() => _showPer100g = v);
    await UserPreferences.setResultsShowPer100g(v);
  }

  Future<void> _restoreSearchFilters() async {
    final f = await UserPreferences.getSearchFilters();
    if (!mounted) return;
    setState(() {
      _kcalRange = RangeValues(f.kcalMin, f.kcalMax);
      _filterProtein = f.p;
      _filterCarb = f.c;
      _filterFat = f.f;
      _sortKey = f.sort;
    });
  }

  Future<void> _loadFavsMy() async {
    final favs = await FavoritesStorage.getFavorites();
    final mine = await FavoritesStorage.getMyFoods();
    if (!mounted) return;
    setState(() {
      _favorites = favs;
      _myFoods = mine;
    });
  }

  Future<void> _loadUsageLists({int days = 30}) async {
    // Scan last [days] of diary entries and build frequent + recent lists
    final Map<String, _UsageAgg> map = {};
    final DateTime today = DateTime.now();
    for (int i = 0; i < days; i++) {
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final entries = await NutritionStorage.getEntriesForDate(d);
      for (final e in entries) {
        final name = (e['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final brand = (e['brand'] as String?)?.trim() ?? '';
        final key = '$name|$brand';
        final agg =
            map.putIfAbsent(key, () => _UsageAgg(name: name, brand: brand));
        agg.count += 1;
        agg.lastUsed = (agg.lastUsed == null || d.isAfter(agg.lastUsed!))
            ? d
            : agg.lastUsed;
        // keep a sample macros snapshot for display
        agg.sample = {
          'id': e['id'] ?? key.hashCode,
          'name': name,
          'brand': brand,
          'calories': (e['calories'] as num?)?.toInt() ?? 0,
          'carbs': (e['carbs'] as num?)?.toInt() ?? 0,
          'protein': (e['protein'] as num?)?.toInt() ?? 0,
          'fat': (e['fat'] as num?)?.toInt() ?? 0,
          'serving': (e['serving'] as String?) ?? '1 porção',
          if (e['imageUrl'] != null) 'imageUrl': e['imageUrl'],
        };
      }
    }
    // Build lists
    final List<_UsageAgg> list = map.values.toList();
    list.sort((a, b) => b.count.compareTo(a.count));
    final frequent = list.take(30).map((a) => a.sample).toList();
    // Recents: by lastUsed descending, unique by key
    list.sort((a, b) =>
        (b.lastUsed ?? DateTime(1970)).compareTo(a.lastUsed ?? DateTime(1970)));
    final recent = list.take(30).map((a) => a.sample).toList();
    if (!mounted) return;
    setState(() {
      _frequentFoods = frequent;
      _recentComputed = recent;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      return;
    }
    setState(() => _isLoading = true);
    final currentVersion = ++_searchVersion;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query, currentVersion);
    });
  }

  Future<void> _runSearch(String query, int version) async {
    List<Map<String, dynamic>> results;
    try {
      if (_foodProvider == null) {
        await _initFoodProvider();
      }
      if (_foodProvider != null) {
        results =
            await _foodProvider!.search(query, limit: 30, useNlq: _useNlq);
      } else {
        results = _foodDatabase.where((food) {
          return (food['name'] as String).toLowerCase().contains(query) ||
              (food['brand'] as String).toLowerCase().contains(query);
        }).toList();
      }
    } catch (_) {
      results = [];
    }

    // Apply kcal range filter
    results = results
        .where((f) =>
            ((f['calories'] as num?)?.toInt() ?? 0) >=
                _kcalRange.start.round() &&
            ((f['calories'] as num?)?.toInt() ?? 0) <= _kcalRange.end.round())
        .toList();

    // Macro emphasis filters (optional includes):
    if (_filterProtein) {
      results.sort((a, b) => ((b['protein'] as num?)?.toInt() ?? 0)
          .compareTo(((a['protein'] as num?)?.toInt() ?? 0)));
    }
    if (_filterCarb) {
      results.sort((a, b) => ((b['carbs'] as num?)?.toInt() ?? 0)
          .compareTo(((a['carbs'] as num?)?.toInt() ?? 0)));
    }
    if (_filterFat) {
      results.sort((a, b) => ((b['fat'] as num?)?.toInt() ?? 0)
          .compareTo(((a['fat'] as num?)?.toInt() ?? 0)));
    }

    // Sorting
    switch (_sortKey) {
      case 'kcal':
        results.sort((a, b) => ((a['calories'] as num?)?.toInt() ?? 0)
            .compareTo(((b['calories'] as num?)?.toInt() ?? 0)));
        break;
      case 'protein':
        results.sort((a, b) => ((b['protein'] as num?)?.toInt() ?? 0)
            .compareTo(((a['protein'] as num?)?.toInt() ?? 0)));
        break;
      case 'carbs':
        results.sort((a, b) => ((b['carbs'] as num?)?.toInt() ?? 0)
            .compareTo(((a['carbs'] as num?)?.toInt() ?? 0)));
        break;
      case 'favorites':
        results.sort((a, b) {
          final af = _favorites
              .any((e) => (e['name'] as String?) == (a['name'] as String?));
          final bf = _favorites
              .any((e) => (e['name'] as String?) == (b['name'] as String?));
          return (bf ? 1 : 0).compareTo(af ? 1 : 0);
        });
        break;
      case 'relevance':
      default:
        break;
    }

    // Drop outdated responses
    if (version != _searchVersion || !mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _openSearchDebug() async {
    final metrics = _foodProvider?.getLastMetrics();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        if (metrics == null) {
          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Sem métricas ainda — faça uma busca',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          );
        }
        final providers = (metrics['providers'] as List?) ?? const [];
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 2.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 2.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Métricas da última busca',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Consulta: ${metrics['query']}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                    'Total combinado: ${metrics['totalItems']} • Após dedupe: ${metrics['dedupItems']} • Limite: ${metrics['limit']}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  metrics['cacheHit'] == true
                      ? 'Cache: HIT (${metrics['cacheAgeSec']}s)'
                      : 'Cache: miss',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text('Provedores',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...providers.map((p) {
                  final label = (p['label'] ?? '').toString();
                  final items = (p['items'] ?? 0).toString();
                  final ms = (p['ms'] ?? 0).toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(label,
                                style: Theme.of(context).textTheme.bodyMedium)),
                        Text('$items itens',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        Text('${ms} ms',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadSearchHistory() async {
    final list = await UserPreferences.getSearchHistory();
    if (!mounted) return;
    setState(() => _searchHistory = list);
  }

  Future<void> _addToSearchHistory(String term) async {
    await UserPreferences.addSearchHistory(term);
    await _loadSearchHistory();
  }

  Future<void> _openFilters() async {
    RangeValues tmpRange = RangeValues(_kcalRange.start, _kcalRange.end);
    String tmpSort = _sortKey;
    bool tmpNlq = _useNlq;
    // Exclusividade via segmented: none | protein | carbs | fat
    String tmpMacro = _filterProtein
        ? 'protein'
        : (_filterCarb ? 'carbs' : (_filterFat ? 'fat' : 'none'));

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 2.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 2.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Filtros',
                          style: AppTheme.darkTheme.textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          tmpRange = const RangeValues(0, 1500);
                          tmpMacro = 'none';
                          tmpSort = 'relevance';
                        });
                      },
                      child: const Text('Limpar'),
                    )
                  ],
                ),
                SizedBox(height: 1.h),
                Text('Kcal', style: AppTheme.darkTheme.textTheme.bodySmall),
                RangeSlider(
                  values: tmpRange,
                  min: 0,
                  max: 1500,
                  divisions: 30,
                  labels: RangeLabels(
                    tmpRange.start.round().toString(),
                    tmpRange.end.round().toString(),
                  ),
                  onChanged: (v) => setState(() => tmpRange = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${tmpRange.start.round()} kcal'),
                    Text('${tmpRange.end.round()} kcal'),
                  ],
                ),
                SizedBox(height: 2.h),
                Text('Priorizar',
                    style: AppTheme.darkTheme.textTheme.bodySmall),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'none',
                      label: Text('Nenhum'),
                    ),
                    ButtonSegment(
                      value: 'protein',
                      label: Text('Proteína'),
                    ),
                    ButtonSegment(
                      value: 'carbs',
                      label: Text('Carbo'),
                    ),
                    ButtonSegment(
                      value: 'fat',
                      label: Text('Gorduras'),
                    ),
                  ],
                  selected: {tmpMacro},
                  onSelectionChanged: (sel) {
                    if (sel.isEmpty) return;
                    setState(() {
                      tmpMacro = sel.first;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                Text('Ordenação',
                    style: AppTheme.darkTheme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Relevância'),
                      selected: tmpSort == 'relevance',
                      onSelected: (v) => setState(() => tmpSort = 'relevance'),
                    ),
                    ChoiceChip(
                      label: const Text('Kcal (asc)'),
                      selected: tmpSort == 'kcal',
                      onSelected: (v) => setState(() => tmpSort = 'kcal'),
                    ),
                    ChoiceChip(
                      label: const Text('Proteína (desc)'),
                      selected: tmpSort == 'protein',
                      onSelected: (v) => setState(() => tmpSort = 'protein'),
                    ),
                    ChoiceChip(
                      label: const Text('Carbo (desc)'),
                      selected: tmpSort == 'carbs',
                      onSelected: (v) => setState(() => tmpSort = 'carbs'),
                    ),
                    ChoiceChip(
                      label: const Text('Favoritos primeiro'),
                      selected: tmpSort == 'favorites',
                      onSelected: (v) => setState(() => tmpSort = 'favorites'),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // NLQ toggle
                SwitchListTile(
                  title: const Text('Interpretar quantidades no texto (NLQ)'),
                  subtitle:
                      const Text('Ex.: "150g frango", "2 ovos e 1 banana"'),
                  value: tmpNlq,
                  onChanged: (v) => setState(() => tmpNlq = v),
                  contentPadding: EdgeInsets.zero,
                ),
                // Show source badges toggle
                SwitchListTile(
                  title: const Text('Mostrar fonte dos dados (OFF/FDC/NLQ)'),
                  value: _showSourceBadges,
                  onChanged: (v) => setState(() => _showSourceBadges = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _kcalRange = tmpRange;
                        // aplicar exclusividade do segmented
                        _filterProtein = tmpMacro == 'protein';
                        _filterCarb = tmpMacro == 'carbs';
                        _filterFat = tmpMacro == 'fat';
                        _sortKey = tmpSort;
                        _useNlq = tmpNlq;
                        // _showSourceBadges toggled directly above
                      });
                      // persist
                      UserPreferences.setSearchFilters(
                        kcalMin: _kcalRange.start,
                        kcalMax: _kcalRange.end,
                        prioritizeProtein: _filterProtein,
                        prioritizeCarb: _filterCarb,
                        prioritizeFat: _filterFat,
                        sortKey: _sortKey,
                      );
                      UserPreferences.setUseNlq(_useNlq);
                      UserPreferences.setShowSourceBadges(_showSourceBadges);
                      Navigator.pop(ctx);
                      _onSearchChanged();
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasActiveFilters() {
    final bool kcalChanged = _kcalRange.start > 0 || _kcalRange.end < 1500;
    final bool macros = _filterProtein || _filterCarb || _filterFat;
    final bool sorted = _sortKey != 'relevance';
    return kcalChanged || macros || sorted;
  }

  void _clearAllFilters() {
    setState(() {
      _kcalRange = const RangeValues(0, 1500);
      _filterProtein = false;
      _filterCarb = false;
      _filterFat = false;
      _sortKey = 'relevance';
    });
    UserPreferences.setSearchFilters(
      kcalMin: _kcalRange.start,
      kcalMax: _kcalRange.end,
      prioritizeProtein: _filterProtein,
      prioritizeCarb: _filterCarb,
      prioritizeFat: _filterFat,
      sortKey: _sortKey,
    );
    _onSearchChanged();
  }

  void _onBarcodePressed() {
    setState(() {
      _showBarcodeScanner = true;
    });
  }

  Future<void> _duplicateLastMeal() async {
    final DateTime date = _targetDate ?? DateTime.now();
    final entries = await NutritionStorage.getEntriesForDate(date);
    if (entries.isEmpty) return;
    entries.sort((a, b) => ((b['createdAt'] as String?) ?? '')
        .compareTo((a['createdAt'] as String?) ?? ''));
    final lastMealTime = (entries.first['mealTime'] as String?) ?? 'snack';
    final sameMeal = entries
        .where((e) => (e['mealTime'] as String?) == lastMealTime)
        .toList();
    for (final e in sameMeal) {
      final dup = Map<String, dynamic>.from(e);
      dup['id'] = null;
      dup['createdAt'] = DateTime.now().toIso8601String();
      await NutritionStorage.addEntry(date, dup);
    }
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: 'Refeição duplicada (${lastMealTime})',
      backgroundColor: AppTheme.successGreen,
      textColor: AppTheme.textPrimary,
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    setState(() => _showBarcodeScanner = false);
    try {
      if (_foodProvider == null) {
        await _initFoodProvider();
      }
      Map<String, dynamic>? food = await _foodProvider?.getByBarcode(barcode);

      if (food == null) {
        // Fallback to direct OFF call if provider not available
        final off = OpenFoodFactsService();
        final item = await off.getByBarcode(barcode);
        if (item != null) {
          food = {
            'id': DateTime.now().millisecondsSinceEpoch,
            'name': item.description,
            'calories': item.caloriesPer100g.round(),
            'carbs': item.carbsPer100g.round(),
            'protein': item.proteinPer100g.round(),
            'fat': item.fatPer100g.round(),
            'brand': item.brand ?? 'Genérico',
            'serving': '100 g',
            'barcode': barcode,
            'source': 'OFF',
            'verified': true,
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              'imageUrl': item.imageUrl,
          };
        }
      }

      if (food == null) {
        Fluttertoast.showToast(
          msg: 'Produto não encontrado',
          backgroundColor: AppTheme.errorRed,
          textColor: AppTheme.textPrimary,
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _selectedFood = food!;
        _searchResults = [food];
      });
      Fluttertoast.showToast(
        msg: 'Produto encontrado!',
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.textPrimary,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao buscar produto',
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
    }
  }

  void _onFoodTap(Map<String, dynamic> food) {
    // Abrir sheet de porção (estilo YAZIO) em vez de mostrar editor manual na página
    _openPortionAndSave(food);
  }

  void _onFoodSwipeRight(Map<String, dynamic> food) {
    // Ação: abrir sheet rápida para confirmar porção/gramas
    _openPortionAndSave(food);
  }

  void _onFoodSwipeLeft(Map<String, dynamic> food) {
    _showFoodDetails(food);
  }

  void _showFoodDetails(Map<String, dynamic> food) {
    final pickerKey = GlobalKey<_PortionPickerState>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Informações Nutricionais',
                      style: theme.textTheme.titleLarge,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: cs.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['name'] as String,
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        food['brand'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Builder(builder: (_) {
                        // Show base serving if available
                        final String? serving = food['serving'] as String?;
                        final m = serving != null
                            ? RegExp(r"(\\d+)\\s*g").firstMatch(serving)
                            : null;
                        if (m == null) return const SizedBox.shrink();
                        return Text(
                          'Base de porção: ${m.group(1)} g',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        );
                      }),
                      SizedBox(height: 1.2.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _macroChip('${food['calories']} kcal',
                              AppTheme.warningAmber),
                          _macroChip(
                              'C ${food['carbs']}g', AppTheme.successGreen),
                          _macroChip(
                              'P ${food['protein']}g', AppTheme.activeBlue),
                          _macroChip('G ${food['fat']}g', AppTheme.errorRed),
                        ],
                      ),
                      SizedBox(height: 1.2.h),
                      Divider(color: cs.outlineVariant.withValues(alpha: 0.6)),
                      SizedBox(height: 1.2.h),
                      _buildNutrientRow(
                        'Calorias',
                        '${food['calories']} kcal',
                        AppTheme.warningAmber,
                      ),
                      _buildNutrientRow(
                        'Carboidratos',
                        '${food['carbs']}g',
                        AppTheme.successGreen,
                      ),
                      _buildNutrientRow(
                        'Proteínas',
                        '${food['protein']}g',
                        AppTheme.activeBlue,
                      ),
                      _buildNutrientRow(
                        'Gorduras',
                        '${food['fat']}g',
                        AppTheme.errorRed,
                      ),
                      SizedBox(height: 2.h),
                      _PortionPicker(
                        key: pickerKey,
                        food: food,
                        onApply: (updated) {
                          setState(() {
                            _selectedFood = updated;
                            _quantity = 1.0;
                            _servingSize = updated['serving'];
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: 'Porção aplicada',
                            backgroundColor: AppTheme.successGreen,
                            textColor: Theme.of(context).colorScheme.onSurface,
                          );
                        },
                        onApplyAndSave: (updated) async {
                          setState(() {
                            _selectedFood = updated;
                            _quantity = 1.0;
                            _servingSize = updated['serving'];
                          });
                          final DateTime saveDate =
                              _targetDate ?? DateTime.now();
                          final entry = {
                            'name': updated['name'],
                            'calories': updated['calories'],
                            'carbs': updated['carbs'],
                            'protein': updated['protein'],
                            'fat': updated['fat'],
                            'brand': updated['brand'] ?? 'Genérico',
                            'quantity': 1.0,
                            'serving': updated['serving'],
                            'mealTime': _selectedMealTime,
                            'createdAt': _editCreatedAtIso ??
                                DateTime.now().toIso8601String(),
                          };
                          await _saveOrUpdateEntry(saveDate, entry);
                          if (!mounted) return;
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: _editId != null
                                ? 'Alterações salvas'
                                : 'Salvo com porção aplicada',
                            backgroundColor: AppTheme.successGreen,
                            textColor: Theme.of(context).colorScheme.onSurface,
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      // Fixed primary CTA: add current portion directly
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final state = pickerKey.currentState;
                              if (state == null) return;
                              final updated =
                                  state.buildUpdatedFoodFromPreview();
                              final DateTime saveDate =
                                  _targetDate ?? DateTime.now();
                              final isEdit = _editId != null;
                              final newId = isEdit
                                  ? _editId
                                  : DateTime.now().millisecondsSinceEpoch;
                              final entry = {
                                'id': newId,
                                'name': updated['name'],
                                'calories': updated['calories'],
                                'carbs': updated['carbs'],
                                'protein': updated['protein'],
                                'fat': updated['fat'],
                                'brand':
                                    (updated['brand'] as String?) ?? 'Genérico',
                                'quantity': 1.0,
                                'serving': updated['serving'],
                                'mealTime': _selectedMealTime,
                                'createdAt': _editCreatedAtIso ??
                                    DateTime.now().toIso8601String(),
                              };
                              await _saveOrUpdateEntry(saveDate, entry);
                              if (!mounted) return;
                              Navigator.pop(context);
                              if (!isEdit) {
                                _showUndoSnackBar(saveDate, newId,
                                    message: 'Adicionado ao diário (' +
                                        _currentMealLabel() +
                                        ')');
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Alterações salvas',
                                  backgroundColor: AppTheme.successGreen,
                                  textColor:
                                      Theme.of(context).colorScheme.onSurface,
                                );
                              }
                            } catch (_) {}
                          },
                          icon: const Icon(Icons.playlist_add),
                          label: Text(_editId != null
                              ? 'Salvar alterações — ' + _currentMealLabel()
                              : 'Adicionar ao diário — ' + _currentMealLabel()),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      FutureBuilder<bool>(
                        future:
                            FavoritesStorage.isFavorite(food['name'] as String),
                        builder: (context, snapFav) {
                          final isFav = snapFav.data ?? false;
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await FavoritesStorage.toggleFavorite(food);
                                    if (!mounted) return;
                                    await _loadFavsMy();
                                    setState(() {});
                                  },
                                  icon: CustomIconWidget(
                                    iconName: isFav ? 'star' : 'star_border',
                                    color: isFav
                                        ? AppTheme.premiumGold
                                        : AppTheme.textSecondary,
                                    size: 5.w,
                                  ),
                                  label: Text(
                                      isFav ? 'Desfavoritar' : 'Favoritar'),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await FavoritesStorage.addMyFood(food);
                                    if (!mounted) return;
                                    await _loadFavsMy();
                                    Fluttertoast.showToast(
                                      msg: 'Adicionado em Meus Alimentos',
                                      backgroundColor: AppTheme.successGreen,
                                      textColor: AppTheme.textPrimary,
                                    );
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'add',
                                    color: AppTheme.textPrimary,
                                    size: 5.w,
                                  ),
                                  label: const Text(
                                      'Adicionar aos meus alimentos'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPortionAndSave(Map<String, dynamic> food) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: _PortionPicker(
              food: food,
              onApply: (_) {},
              onApplyAndSave: (updated) async {
                final DateTime saveDate = _targetDate ?? DateTime.now();
                final newId = DateTime.now().millisecondsSinceEpoch;
                final entry = {
                  'id': newId,
                  'name': updated['name'],
                  'calories': updated['calories'],
                  'carbs': updated['carbs'],
                  'protein': updated['protein'],
                  'fat': updated['fat'],
                  'brand': (updated['brand'] as String?) ?? 'Genérico',
                  'quantity': 1.0,
                  'serving': updated['serving'],
                  'mealTime': _selectedMealTime,
                  'createdAt': DateTime.now().toIso8601String(),
                };
                await NutritionStorage.addEntry(saveDate, entry);
                if (!mounted) return;
                Navigator.pop(ctx); // fecha o bottom sheet
                // Permanecer na tela de adição para permitir adicionar mais itens
                if (mounted) {
                  _showUndoSnackBar(saveDate, newId,
                      message: 'Adicionado ao diário (${_currentMealLabel()})');
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _quickAddWithGrams(
      Map<String, dynamic> food, double grams) async {
    // calcula macros por grama a partir do serving atual (assume 100g se não houver)
    final String? servingStr = food['serving'] as String?;
    double base = 100;
    if (servingStr != null) {
      final m = RegExp(r"(\d+)\s*g").firstMatch(servingStr);
      if (m != null) {
        base = double.tryParse(m.group(1)!) ?? 100;
      }
    }
    base = base <= 0 ? 100 : base;

    double perG(num v) => (v.toDouble()) / base;
    final updated = <String, dynamic>{
      'name': food['name'],
      'brand': food['brand'] ?? 'Genérico',
      'calories': (perG(food['calories'] ?? 0) * grams).round(),
      'carbs':
          double.parse(((perG(food['carbs'] ?? 0) * grams)).toStringAsFixed(1)),
      'protein': double.parse(
          ((perG(food['protein'] ?? 0) * grams)).toStringAsFixed(1)),
      'fat':
          double.parse(((perG(food['fat'] ?? 0) * grams)).toStringAsFixed(1)),
      'serving': '${grams.toStringAsFixed(0)} g',
    };

    final DateTime saveDate = _targetDate ?? DateTime.now();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final entry = {
      'id': newId,
      'name': updated['name'],
      'calories': updated['calories'],
      'carbs': updated['carbs'],
      'protein': updated['protein'],
      'fat': updated['fat'],
      'brand': updated['brand'],
      'quantity': 1.0,
      'serving': updated['serving'],
      'mealTime': _selectedMealTime,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await NutritionStorage.addEntry(saveDate, entry);
    if (!mounted) return;
    if (mounted) {
      _showUndoSnackBar(saveDate, newId,
          message: 'Adicionado ${grams.toInt()}g em ${_currentMealLabel()}');
    }
  }

  void _showUndoSnackBar(DateTime date, dynamic id, {String? message}) {
    final snackBar = SnackBar(
      content: Text(message ?? 'Adicionado'),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () async {
          await NutritionStorage.removeEntryById(date, id);
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildNutrientRow(String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.darkTheme.textTheme.bodyLarge),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.6)),
      ),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _onQuantityChanged(double quantity) {
    setState(() {
      _quantity = quantity;
    });
  }

  void _onServingSizeChanged(String servingSize) {
    setState(() {
      _servingSize = servingSize;
    });
  }

  final List<String> _popularCategories = const [
    'frutas',
    'verduras',
    'legumes',
    'laticínios',
    'carnes',
    'cereais',
    'bebidas',
    'snacks'
  ];

  Future<void> _clearSearchHistoryPermanently() async {
    await UserPreferences.clearSearchHistory();
    final list = await UserPreferences.getSearchHistory();
    if (!mounted) return;
    setState(() => _searchHistory = list);
  }

  void _onMealTimeChanged(String mealTime) {
    setState(() {
      _selectedMealTime = mealTime;
    });
  }

  String _smartMealForTime(DateTime dt) {
    final h = dt.hour;
    if (h < 11) return "breakfast";
    if (h < 16) return "lunch";
    return "dinner";
  }

  void _mapMealNameToKey(String mealName) {
    final normalized = mealName.toLowerCase();
    if (normalized.contains('café') ||
        normalized.contains('manha') ||
        normalized.contains('manhã') ||
        normalized.contains('breakfast')) {
      _onMealTimeChanged('breakfast');
      return;
    }
    if (normalized.contains('almoço') ||
        normalized.contains('almoco') ||
        normalized.contains('lunch')) {
      _onMealTimeChanged('lunch');
      return;
    }
    if (normalized.contains('jantar') || normalized.contains('dinner')) {
      _onMealTimeChanged('dinner');
      return;
    }
    if (normalized.contains('lanche') || normalized.contains('snack')) {
      _onMealTimeChanged('snack');
      return;
    }
  }

  String _currentMealLabel() {
    final key = _selectedMealTime;
    if (key == 'breakfast') return 'café';
    if (key == 'lunch') return 'almoço';
    if (key == 'dinner') return 'jantar';
    if (key == 'snack') return 'lanche';
    return key;
  }

  String _searchHint() {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    if (lang == 'pt') {
      switch (_selectedMealTime) {
        case 'breakfast':
          return 'O que você comeu no café da manhã?';
        case 'lunch':
          return 'O que você comeu no almoço?';
        case 'dinner':
          return 'O que você comeu no jantar?';
        case 'snack':
          return 'O que você comeu no lanche?';
      }
      return 'Buscar alimento...';
    } else {
      switch (_selectedMealTime) {
        case 'breakfast':
          return 'What did you eat for breakfast?';
        case 'lunch':
          return 'What did you eat for lunch?';
        case 'dinner':
          return 'What did you eat for dinner?';
        case 'snack':
          return 'What did you eat for a snack?';
      }
      return 'Search foods...';
    }
  }

  void _saveFood() {
    if (_selectedFood == null) {
      Fluttertoast.showToast(
        msg: 'Selecione um alimento primeiro',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.textPrimary,
      );
      return;
    }

    final totalCalories =
        ((_selectedFood!['calories'] as int) * _quantity).round();

    final entry = {
      'name': _selectedFood!['name'],
      'calories': totalCalories,
      'carbs': _selectedFood!['carbs'],
      'protein': _selectedFood!['protein'],
      'fat': _selectedFood!['fat'],
      'brand': _selectedFood!['brand'],
      'quantity': _quantity,
      'serving': _servingSize,
      'mealTime': _selectedMealTime,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final DateTime saveDate = _targetDate ?? DateTime.now();
    NutritionStorage.addEntry(saveDate, entry).then((_) {
      // refresh frequents/recents after saving
      _loadUsageLists();
      Fluttertoast.showToast(
        msg: '${_selectedFood!['name']} • +$totalCalories kcal no ' +
            _currentMealLabel(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.textPrimary,
      );
      Navigator.of(context).popUntil((route) {
        final name = route.settings.name;
        return name == AppRoutes.dailyTrackingDashboard ||
            name == AppRoutes.enhancedDashboard ||
            name == AppRoutes.initial ||
            route.isFirst;
      });
    });
  }

  bool get _canSave => _selectedFood != null && _quantity > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Bottom segmented tabs removed; tabs moved to top below search
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: cs.onSurface,
                            size: 5.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentMealLabel(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Menu de três pontos para recursos extras
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'prefs') {
                            Navigator.pushNamed(context, AppRoutes.profile,
                                arguments: {'scrollTo': 'ui_prefs'});
                          }
                          if (value == 'duplicate') {
                            await _duplicateLastMeal();
                          }
                          if (value == 'ai') {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.aiFoodDetection,
                            );
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              setState(() {
                                _selectedFood = result;
                                _searchResults = [result];
                              });
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            } else if (result != null && result is List) {
                              final List<Map<String, dynamic>> foods =
                                  result.cast<Map<String, dynamic>>();
                              final DateTime saveDate =
                                  _targetDate ?? DateTime.now();
                              for (final f in foods) {
                                final entry = {
                                  'name': f['name'],
                                  'calories': f['calories'],
                                  'carbs': f['carbs'],
                                  'protein': f['protein'],
                                  'fat': f['fat'],
                                  'brand': f['brand'],
                                  'quantity': 1.0,
                                  'serving': f['serving'] ?? 'porção',
                                  'mealTime': (f['mealTime'] as String?) ??
                                      _selectedMealTime,
                                  'createdAt': DateTime.now().toIso8601String(),
                                };
                                // ignore: unawaited_futures
                                NutritionStorage.addEntry(saveDate, entry);
                              }
                              Fluttertoast.showToast(
                                msg: '${foods.length} alimento(s) adicionados',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: AppTheme.successGreen,
                                textColor: AppTheme.textPrimary,
                              );
                              setState(() {
                                _selectedFood = foods.first;
                                _searchResults = foods;
                              });
                            }
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                              value: 'ai',
                              child: Text('IA (detectar alimentos)')),
                          const PopupMenuItem(
                              value: 'duplicate',
                              child: Text('Duplicar última refeição')),
                          const PopupMenuItem(
                              value: 'prefs', child: Text('Preferências')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // UI limpa: ocultamos o seletor grande de refeição aqui
              if (!_reviewOnly) const SizedBox.shrink(),

              // Fixed Search (moved from scrollable content)
              if (!_reviewOnly)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                  child: SearchBarWidget(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: _searchHint(),
                    onChanged: (value) {}, // handled by listener
                    onSubmitted: (v) async {
                      final t = v.trim();
                      if (t.isNotEmpty) await _addToSearchHistory(t);
                    },
                    onOpenFilters: _openFilters,
                    // recursos extras movidos para o menu de três pontos
                  ),
                ),

              // Quick chip near search: toggle NLQ
              if (!_reviewOnly)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          avatar: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('NLQ: texto → nutrição'),
                          tooltip:
                              'Interpretar quantidades no texto (ex.: 150g frango, 2 ovos)',
                          selected: _useNlq,
                          onSelected: (v) async {
                            setState(() => _useNlq = v);
                            await UserPreferences.setUseNlq(v);
                            // reexecuta busca se houver termo
                            if (_searchController.text.trim().isNotEmpty) {
                              _onSearchChanged();
                            }
                          },
                        ),
                        FilterChip(
                          avatar: const Icon(Icons.bug_report, size: 18),
                          label: const Text('Debug'),
                          tooltip: 'Ver métricas da última busca',
                          selected: false,
                          onSelected: (_) => _openSearchDebug(),
                        ),
                      ],
                    ),
                  ),
                ),

              // Quick actions (Yazio-like)
              if (!_reviewOnly)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickTile(
                        icon: Icons.restaurant_outlined,
                        label: 'Alimentos',
                        onTap: () {
                          setState(() => _activeTab = 'recent');
                          _searchFocus.requestFocus();
                        },
                      ),
                      _quickTile(
                        icon: Icons.restaurant_menu,
                        label: 'Refeições',
                        onTap: () => setState(() => _activeTab = 'frequent'),
                      ),
                      _quickTile(
                        icon: Icons.menu_book_outlined,
                        label: 'Receitas',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.recipeBrowser);
                        },
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 1.h),

              // Top tabs (FREQUENTES | RECENTES | FAVORITOS)
              if (!_reviewOnly)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      _topTabButton('FREQUENTES', 'frequent'),
                      SizedBox(width: 4.w),
                      _topTabButton('RECENTES', 'recent'),
                      SizedBox(width: 4.w),
                      _topTabButton('FAVORITOS', 'favorites'),
                    ],
                  ),
                ),
              if (!_reviewOnly) SizedBox(height: 0.8.h),

              // Indicadores de filtro (ocultos para UI limpa)
              if (_showFilterChips && _hasActiveFilters())
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Kcal range chip (only when narrowed)
                        if (_kcalRange.start > 0 || _kcalRange.end < 1500)
                          Chip(
                            label: Text(
                                'Calorias: ${_kcalRange.start.round()}–${_kcalRange.end.round()}'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.secondaryBackgroundDark
                                .withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.activeBlue
                                      .withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.activeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterProtein)
                          Chip(
                            label: const Text('Priorizar: Proteína'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.secondaryBackgroundDark
                                .withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.activeBlue
                                      .withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.activeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterCarb)
                          Chip(
                            label: const Text('Priorizar: Carboidratos'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.secondaryBackgroundDark
                                .withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.successGreen
                                      .withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterFat)
                          Chip(
                            label: const Text('Priorizar: Gorduras'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.secondaryBackgroundDark
                                .withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color:
                                      AppTheme.errorRed.withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_sortKey != 'relevance')
                          Chip(
                            label: Text(
                                'Ordenação: ${_sortKey == 'kcal' ? 'Calorias' : _sortKey == 'protein' ? 'Proteína' : _sortKey == 'carbs' ? 'Carboidratos' : _sortKey == 'favorites' ? 'Favoritos' : _sortKey}'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppTheme.secondaryBackgroundDark
                                .withValues(alpha: 0.18),
                            shape: const StadiumBorder(),
                          ),
                        // Actions: Edit and Clear
                        ActionChip(
                          label: const Text('Editar filtros'),
                          onPressed: _openFilters,
                          visualDensity: VisualDensity.compact,
                        ),
                        ActionChip(
                          label: const Text('Limpar'),
                          onPressed: _clearAllFilters,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),

              // Popular categories (ocultado para manter UI como YAZIO)
              if (false)
                Padding(
                  padding:
                      EdgeInsets.only(left: 4.w, right: 4.w, bottom: 0.8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorias populares',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _popularCategories.map((c) {
                          return ChoiceChip(
                            label: Text(c),
                            selected: false,
                            onSelected: (_) {
                              _searchController.text = c;
                              _searchController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: c.length),
                              );
                              _onSearchChanged();
                            },
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall,
                            backgroundColor: AppTheme.secondaryBackgroundDark,
                            selectedColor:
                                AppTheme.activeBlue.withValues(alpha: 0.12),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.dividerGray
                                      .withValues(alpha: 0.6)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              // Toggle 100g/porção oculto para reduzir ruído visual
              if (false) const SizedBox.shrink(),

              // Search history (when empty query)
              if (false)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pesquisas recentes',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSearchHistoryPermanently,
                            child: const Text('Limpar histórico'),
                          )
                        ],
                      ),
                      SizedBox(height: 0.4.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _searchHistory.take(8).map((term) {
                            return ChoiceChip(
                              label: Text(term),
                              selected: false,
                              onSelected: (_) {
                                _searchController.text = term;
                                _searchController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(offset: term.length),
                                );
                                _searchFocus.requestFocus();
                                _onSearchChanged();
                              },
                              labelStyle:
                                  AppTheme.darkTheme.textTheme.bodySmall,
                              backgroundColor: AppTheme.secondaryBackgroundDark,
                              selectedColor:
                                  AppTheme.activeBlue.withValues(alpha: 0.12),
                              shape: StadiumBorder(
                                side: BorderSide(
                                    color: AppTheme.dividerGray
                                        .withValues(alpha: 0.6)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // (SearchBar moved to fixed area above)

                      if (!_reviewOnly) ...[
                        // Tab content when not searching
                        if (_searchController.text.isEmpty &&
                            (_activeTab == 'recent' ||
                                _activeTab == 'frequent'))
                          FoodSearchResultsWidget(
                            searchResults: _activeTab == 'frequent'
                                ? _frequentFoods
                                : _recentComputed,
                            onFoodTap: _onFoodTap,
                            onFoodSwipeRight: _onFoodSwipeRight,
                            onFoodSwipeLeft: _onFoodSwipeLeft,
                            title: _activeTab == 'frequent'
                                ? 'Frequentes'
                                : 'Recentes',
                            enableOnlyFavsToggle: false,
                            onFavoritesChanged: () async {
                              await _loadFavsMy();
                            },
                            onQuickSaveRequested: (food) async {
                              await _openPortionAndSave(food);
                            },
                            quickSaveMealLabel: _currentMealLabel(),
                            onQuickAddWithGrams: (food, grams) async {
                              await _quickAddWithGrams(food, grams);
                            },
                            headerRightText: 'Filtros',
                            onHeaderRightTap: _openFilters,
                            showPer100g: false,
                            showSourceBadges: _showSourceBadges,
                          ),
                        if (_searchController.text.isEmpty &&
                            _activeTab == 'favorites')
                          FoodSearchResultsWidget(
                            searchResults: _favorites,
                            onFoodTap: _onFoodTap,
                            onFoodSwipeRight: _onFoodSwipeRight,
                            onFoodSwipeLeft: _onFoodSwipeLeft,
                            title: 'Favoritos',
                            enableOnlyFavsToggle: true,
                            showEmptyPlaceholder: true,
                            emptyTitle: 'Você ainda não tem favoritos',
                            emptySubtitle:
                                'Marque alimentos com a estrela para acessá-los rapidamente aqui.',
                            onFavoritesChanged: () async {
                              await _loadFavsMy();
                            },
                            onQuickSaveRequested: (food) async {
                              await _openPortionAndSave(food);
                            },
                            quickSaveMealLabel: _currentMealLabel(),
                            onQuickAddWithGrams: (food, grams) async {
                              await _quickAddWithGrams(food, grams);
                            },
                            headerRightText: 'Filtros',
                            onHeaderRightTap: _openFilters,
                            showPer100g: _showPer100g,
                            showSourceBadges: _showSourceBadges,
                          ),
                        // "Meus Alimentos" deixou de ser uma aba fixa;
                        // conteúdo acessível via favoritos/edição. Mantemos bloco somente
                        // se ainda houver estado antigo configurado.
                        if (_searchController.text.isEmpty &&
                            _activeTab == 'mine')
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _myFoods.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 4.h),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 18.w,
                                          height: 18.w,
                                          decoration: BoxDecoration(
                                            color: AppTheme.activeBlue
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: CustomIconWidget(
                                            iconName: 'restaurant',
                                            color: AppTheme.activeBlue,
                                            size: 9.w,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Você ainda não tem Meus Alimentos',
                                          style: AppTheme
                                              .darkTheme.textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 0.8.h),
                                        Text(
                                          'Abra os detalhes de um alimento e toque em "Adicionar aos meus alimentos" para criar seus presets.',
                                          style: AppTheme
                                              .darkTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.darkTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 2.h),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            final Map<String, dynamic>
                                                blankFood = {
                                              'name': '',
                                              'brand': '',
                                              'calories': 0,
                                              'carbs': 0,
                                              'protein': 0,
                                              'fat': 0,
                                              'unitPresets': {
                                                'unidade': 100.0,
                                                'colher': 15.0,
                                                'xícara': 240.0,
                                              },
                                            };
                                            _openEditMyFood(blankFood);
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text(
                                              'Adicionar manualmente'),
                                        ),
                                        SizedBox(height: 1.h),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.profile,
                                                  arguments: {
                                                    'scrollTo': 'foods_import'
                                                  },
                                                );
                                              },
                                              icon:
                                                  const Icon(Icons.file_upload),
                                              label: const Text(
                                                  'Importar alimentos'),
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                    AppRoutes.recipeBrowser);
                                              },
                                              icon: const Icon(
                                                  Icons.menu_book_outlined),
                                              label: const Text(
                                                  'Explorar receitas'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _myFoods.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final food = _myFoods[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 2.h),
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .darkTheme.colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppTheme
                                                .darkTheme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _onFoodTap(food),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      food['name'] as String,
                                                      style: AppTheme.darkTheme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 0.5.h),
                                                    Text(
                                                      (food['brand']
                                                              as String?) ??
                                                          '—',
                                                      style: AppTheme.darkTheme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: AppTheme
                                                            .darkTheme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        _buildNutrientChip(
                                                            '${food['calories']} kcal',
                                                            AppTheme
                                                                .warningAmber),
                                                        SizedBox(width: 2.w),
                                                        _buildNutrientChip(
                                                            'C: ${food['carbs']}g',
                                                            AppTheme
                                                                .successGreen),
                                                        SizedBox(width: 2.w),
                                                        _buildNutrientChip(
                                                            'P: ${food['protein']}g',
                                                            AppTheme
                                                                .activeBlue),
                                                        SizedBox(width: 2.w),
                                                        _buildNutrientChip(
                                                            'G: ${food['fat']}g',
                                                            AppTheme.errorRed),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    // abrir porção e salvar
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      builder: (ctx) {
                                                        return Container(
                                                          height: 56.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppTheme
                                                                .darkTheme
                                                                .scaffoldBackgroundColor,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.w),
                                                            child:
                                                                _PortionPicker(
                                                              food: food,
                                                              onApply: (_) {},
                                                              onApplyAndSave:
                                                                  (updated) async {
                                                                final DateTime
                                                                    saveDate =
                                                                    _targetDate ??
                                                                        DateTime
                                                                            .now();
                                                                final entry = {
                                                                  'name': updated[
                                                                      'name'],
                                                                  'calories':
                                                                      updated[
                                                                          'calories'],
                                                                  'carbs': updated[
                                                                      'carbs'],
                                                                  'protein':
                                                                      updated[
                                                                          'protein'],
                                                                  'fat': updated[
                                                                      'fat'],
                                                                  'brand': (updated[
                                                                              'brand']
                                                                          as String?) ??
                                                                      'Genérico',
                                                                  'quantity':
                                                                      1.0,
                                                                  'serving':
                                                                      updated[
                                                                          'serving'],
                                                                  'mealTime':
                                                                      _selectedMealTime,
                                                                  'createdAt': DateTime
                                                                          .now()
                                                                      .toIso8601String(),
                                                                };
                                                                await NutritionStorage
                                                                    .addEntry(
                                                                        saveDate,
                                                                        entry);
                                                                if (!mounted)
                                                                  return;
                                                                Navigator.pop(
                                                                    ctx);
                                                                Fluttertoast
                                                                    .showToast(
                                                                  msg: 'Adicionado ao diário (' +
                                                                      _selectedMealTime +
                                                                      ')',
                                                                  backgroundColor:
                                                                      AppTheme
                                                                          .successGreen,
                                                                  textColor:
                                                                      AppTheme
                                                                          .textPrimary,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                          Icons.playlist_add),
                                                      SizedBox(width: 1.w),
                                                      Text(
                                                        _currentMealLabel(),
                                                        style: AppTheme
                                                            .darkTheme
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                  tooltip:
                                                      'Salvar no diário — ' +
                                                          _currentMealLabel(),
                                                  color: AppTheme.successGreen,
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _openEditMyFood(food),
                                                  icon: const Icon(Icons.edit),
                                                  tooltip: 'Editar',
                                                  color: AppTheme.activeBlue,
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _confirmDeleteMyFood(
                                                          food['name']
                                                              as String),
                                                  icon: const Icon(
                                                      Icons.delete_outline),
                                                  tooltip: 'Remover',
                                                  color: AppTheme.errorRed,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),

                        // Loading Indicator
                        if (_isLoading)
                          Container(
                            padding: EdgeInsets.all(4.w),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.activeBlue,
                              ),
                            ),
                          ),

                        // Search Results
                        if (!_isLoading && _searchResults.isNotEmpty)
                          FoodSearchResultsWidget(
                            searchResults: _searchResults,
                            onFoodTap: _onFoodTap,
                            onFoodSwipeRight: _onFoodSwipeRight,
                            onFoodSwipeLeft: _onFoodSwipeLeft,
                            onFavoritesChanged: () async {
                              await _loadFavsMy();
                            },
                            enableOnlyFavsToggle: true,
                            onQuickSaveRequested: (food) async {
                              await _openPortionAndSave(food);
                            },
                            quickSaveMealLabel: _currentMealLabel(),
                            onQuickAddWithGrams: (food, grams) async {
                              await _quickAddWithGrams(food, grams);
                            },
                            headerRightText: 'Filtros',
                            onHeaderRightTap: _openFilters,
                            showPer100g: _showPer100g,
                            showSourceBadges: _showSourceBadges,
                          ),

                        // No Results
                        if (!_isLoading &&
                            _searchController.text.isNotEmpty &&
                            _searchResults.isEmpty)
                          Container(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: 'search_off',
                                  color: AppTheme
                                      .darkTheme.colorScheme.onSurfaceVariant,
                                  size: 12.w,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Nenhum alimento encontrado',
                                  style: AppTheme.darkTheme.textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Tente buscar com outros termos, ajustar filtros ou usar a IA',
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .darkTheme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _openFilters,
                                      icon: const Icon(Icons.tune),
                                      label: const Text('Ajustar filtros'),
                                    ),
                                    SizedBox(width: 2.w),
                                    OutlinedButton.icon(
                                      onPressed: _clearAllFilters,
                                      icon: const Icon(Icons.filter_list_off),
                                      label: const Text('Limpar filtros'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                      // Attribution (data sources)
                      if (!_reviewOnly)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.2.h, horizontal: 4.w),
                          child: Text(
                            'Fontes: Open Food Facts (ODbL), USDA FoodData Central, API Ninjas (NLQ)',
                            textAlign: TextAlign.center,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .darkTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      // Manual Entry
                      ManualEntryWidget(
                        selectedFood: _selectedFood,
                        onQuantityChanged: _onQuantityChanged,
                        onServingSizeChanged: _onServingSizeChanged,
                      ),

                      // Meal Timing Selector moved to top

                      // Bottom padding for save button
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Save Button
          if (_selectedFood != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectedFood != null
                              ? () {
                                  final Map<String, dynamic> editable =
                                      Map<String, dynamic>.from(_selectedFood!);
                                  _openEditMyFood(editable);
                                }
                              : null,
                          icon: const Icon(Icons.edit),
                          label: const Text('Adicionar ou editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.activeBlue,
                            side: BorderSide(
                                color: _canSave
                                    ? AppTheme.activeBlue
                                    : AppTheme.darkTheme.colorScheme.outline),
                            padding: EdgeInsets.symmetric(vertical: 2.6.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canSave ? _saveFood : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSave
                                ? AppTheme.activeBlue
                                : AppTheme.darkTheme.colorScheme.outline,
                            foregroundColor: AppTheme.textPrimary,
                            padding: EdgeInsets.symmetric(vertical: 2.6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'add',
                                color: AppTheme.textPrimary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              const Text('Confirmar e registrar'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Barcode Scanner Modal
          if (_showBarcodeScanner)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: BarcodeScannerWidget(
                    onBarcodeScanned: _onBarcodeScanned,
                    onClose: () {
                      setState(() {
                        _showBarcodeScanner = false;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // New top tabs (text + bottom indicator)
  Widget _topTabButton(String label, String key) {
    final bool active = _activeTab == key;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = key),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppTheme.activeBlue : cs.outlineVariant,
              width: active ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: active ? AppTheme.activeBlue : AppTheme.textPrimary,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // Yazio-like small square quick tiles
  Widget _quickTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppTheme.activeBlue, size: 8.w),
            ),
            SizedBox(height: 0.6.h),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, String key) {
    final bool active = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.activeBlue.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? AppTheme.activeBlue
                  : AppTheme.darkTheme.colorScheme.outline
                      .withValues(alpha: 0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.activeBlue : AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabs() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface,
          border: Border(top: BorderSide(color: AppTheme.dividerGray)),
        ),
        child: Row(
          children: [
            _tabButton('Recentes', 'recent'),
            SizedBox(width: 2.w),
            _tabButton('Favoritos', 'favorites'),
            SizedBox(width: 2.w),
            _tabButton('Meus Alimentos', 'mine'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _chip(String label, int remaining, Color color,
      {bool exceeded = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            '$label ${remaining}',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (exceeded)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 1.6.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.errorRed.withValues(alpha: 0.8)),
              ),
              child: Text(
                'Excedeu',
                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDeleteMyFood(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Remover alimento?',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            name,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                await FavoritesStorage.removeMyFoodByName(name);
                if (!mounted) return;
                await _loadFavsMy();
                Navigator.pop(context);
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  void _openEditMyFood(Map<String, dynamic> food) {
    final nameCtrl =
        TextEditingController(text: food['name']?.toString() ?? '');
    final brandCtrl =
        TextEditingController(text: food['brand']?.toString() ?? '');
    final calCtrl =
        TextEditingController(text: (food['calories']?.toString() ?? '0'));
    final carbCtrl =
        TextEditingController(text: (food['carbs']?.toString() ?? '0'));
    final protCtrl =
        TextEditingController(text: (food['protein']?.toString() ?? '0'));
    final fatCtrl =
        TextEditingController(text: (food['fat']?.toString() ?? '0'));
    // presets
    double unidadeG = 100, colherG = 15, xicaraG = 240;
    try {
      final mp = food['unitPresets'];
      if (mp is Map) {
        unidadeG = (mp['unidade'] is num)
            ? (mp['unidade'] as num).toDouble()
            : double.tryParse(mp['unidade']?.toString() ?? '') ?? unidadeG;
        colherG = (mp['colher'] is num)
            ? (mp['colher'] as num).toDouble()
            : double.tryParse(mp['colher']?.toString() ?? '') ?? colherG;
        xicaraG = (mp['xícara'] is num)
            ? (mp['xícara'] as num).toDouble()
            : double.tryParse(mp['xícara']?.toString() ?? '') ?? xicaraG;
      }
    } catch (_) {}
    final unidadeCtrl = TextEditingController(text: unidadeG.toString());
    final colherCtrl = TextEditingController(text: colherG.toString());
    final xicaraCtrl = TextEditingController(text: xicaraG.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Editar alimento',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField('Nome', nameCtrl),
                _editField('Marca', brandCtrl),
                _editField('Calorias (kcal)', calCtrl, number: true),
                _editField('Carboidratos (g)', carbCtrl, number: true),
                _editField('Proteínas (g)', protCtrl, number: true),
                _editField('Gorduras (g)', fatCtrl, number: true),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Presets de porção (g)',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 0.6.h),
                _editField('Unidade (g)', unidadeCtrl, number: true),
                _editField('Colher (g)', colherCtrl, number: true),
                _editField('Xícara (g)', xicaraCtrl, number: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameCtrl.text.trim();
                final int calories = int.tryParse(calCtrl.text.trim()) ?? 0;
                if (name.isEmpty || calories <= 0) {
                  Fluttertoast.showToast(
                    msg: 'Informe nome e calorias (> 0)',
                    backgroundColor: AppTheme.errorRed,
                    textColor: AppTheme.textPrimary,
                  );
                  return;
                }
                final updated = {
                  'name': name,
                  'brand': brandCtrl.text.trim(),
                  'calories': calories,
                  'carbs': int.tryParse(carbCtrl.text.trim()) ?? 0,
                  'protein': int.tryParse(protCtrl.text.trim()) ?? 0,
                  'fat': int.tryParse(fatCtrl.text.trim()) ?? 0,
                  'unitPresets': {
                    'unidade':
                        double.tryParse(unidadeCtrl.text.trim()) ?? unidadeG,
                    'colher':
                        double.tryParse(colherCtrl.text.trim()) ?? colherG,
                    'xícara':
                        double.tryParse(xicaraCtrl.text.trim()) ?? xicaraG,
                  },
                };
                await FavoritesStorage.addMyFood(updated);
                if (!mounted) return;
                await _loadFavsMy();
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Meus Alimentos atualizado',
                  backgroundColor: AppTheme.successGreen,
                  textColor: AppTheme.textPrimary,
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController c,
      {bool number = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          SizedBox(
            width: 40.w,
            child: TextField(
              controller: c,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              decoration: const InputDecoration(hintText: ''),
            ),
          ),
        ],
      ),
    );
  }
}

