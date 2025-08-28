// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';
import '../../services/favorites_storage.dart';
import '../../services/fooddb/open_food_facts_service.dart';
import '../../services/meal_summary.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/food_search_results_widget.dart';
import './widgets/manual_entry_widget.dart';
import './widgets/meal_timing_selector_widget.dart';
import './widgets/recent_foods_widget.dart';
import './widgets/search_bar_widget.dart';
import '../../services/user_preferences.dart';

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
  double quantity = 1;
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
    } else {
      unit = 'unidade';
      gramsPerPortion = 100;
    }
    _qtyCtrl.text = quantity.toString();
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
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit chips + quantity entry
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['g', 'unidade', 'colher', 'xícara'].map((u) {
                  final selected = unit == u;
                  return ChoiceChip(
                    label: Text(u),
                    selected: selected,
                    onSelected: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        unit = u;
                        if (unit == 'g') {
                          gramsPerPortion = 1;
                          _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
                        } else if (unit == 'unidade') {
                          gramsPerPortion =
                              unitPresets['unidade'] ?? _baseGrams();
                          _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
                        } else if (unit == 'colher') {
                          gramsPerPortion = unitPresets['colher'] ?? 15;
                          _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
                        } else if (unit == 'xícara') {
                          gramsPerPortion = unitPresets['xícara'] ?? 240;
                          _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
                        }
                      });
                    },
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: cs.surface,
                    selectedColor: cs.primary.withValues(alpha: 0.12),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: (selected ? cs.primary : cs.outlineVariant)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(
              width: 34.w,
              child: Row(
                children: [
                  _roundIconButton(
                    icon: Icons.remove,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        quantity = (quantity - 0.25).clamp(0.0, 100.0);
                        _qtyCtrl.text = quantity.toString();
                      });
                    },
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextField(
                      controller: _qtyCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(
                          () => quantity = double.tryParse(v.trim()) ?? 1),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  _roundIconButton(
                    icon: Icons.add,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        quantity = (quantity + 0.25).clamp(0.0, 100.0);
                        _qtyCtrl.text = quantity.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (unit != 'g') ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Text('Gramas por porção',
                    style: theme.textTheme.bodyMedium),
              ),
              SizedBox(
                width: 28.w,
                child: TextField(
                  controller: _gramsCtrl,
                  decoration: const InputDecoration(hintText: '100'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {
                    final parsed = double.tryParse(v.trim());
                    if (parsed != null && parsed > 0) {
                      gramsPerPortion = parsed;
                    }
                  }),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.6.h),
          // Preset chips for grams per portion when not 'g'
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in unitPresets.entries)
                if (['unidade', 'colher', 'xícara'].contains(entry.key))
                  ChoiceChip(
                    label: Text('${entry.key}: ${entry.value.toInt()} g'),
                    selected: gramsPerPortion.round() == entry.value.round(),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        gramsPerPortion = entry.value;
                        _gramsCtrl.text = gramsPerPortion.toStringAsFixed(0);
                      });
                    },
                    labelStyle:
                        AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AppTheme.secondaryBackgroundDark,
                    selectedColor: AppTheme.activeBlue.withValues(alpha: 0.12),
                    shape: StadiumBorder(
                      side: BorderSide(
                          color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                    ),
                  ),
            ],
          ),
          SizedBox(height: 0.6.h),
          // Save default chip row
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined,
                      size: 16, color: cs.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text('Salvar como padrão',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      )),
                  SizedBox(width: 2.w),
                  Switch(
                    value: saveAsDefault,
                    onChanged: (v) => setState(() => saveAsDefault = v),
                    activeColor: cs.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: 1.2.h),
        Text(
          'Prévia: ${formatNum(preview['cal']!.toDouble())} kcal • ${formatNum(preview['grams']!.toDouble())} g • C ${formatNum(preview['carb']!.toDouble())}g • P ${formatNum(preview['prot']!.toDouble())}g • G ${formatNum(preview['fat']!.toDouble())}g',
        ),
        SizedBox(height: 1.2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final updated = _buildUpdatedFood(preview);
                await _maybeSavePreset(updated);
                widget.onApply(updated);
              },
              child: const Text('Aplicar porção'),
            ),
            SizedBox(width: 2.w),
            if (widget.onApplyAndSave != null)
              ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final updated = _buildUpdatedFood(preview);
                  await _maybeSavePreset(updated);
                  widget.onApplyAndSave!(updated);
                },
                child: Text(
                  'Aplicar e adicionar — ${preview['cal']!.round()} kcal',
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
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

  Map<String, dynamic> _buildUpdatedFood(Map<String, num> preview) {
    final updated = Map<String, dynamic>.from(widget.food);
    updated['calories'] = preview['cal']!.round();
    updated['carbs'] = double.parse(formatNum(preview['carb']!.toDouble()));
    updated['protein'] = double.parse(formatNum(preview['prot']!.toDouble()));
    updated['fat'] = double.parse(formatNum(preview['fat']!.toDouble()));
    updated['serving'] = '${formatNum(preview['grams']!.toDouble())} g';
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

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  String _selectedMealTime = 'breakfast';
  double _quantity = 1.0;
  String _servingSize = 'porção';
  bool _isLoading = false;
  bool _showBarcodeScanner = false;
  DateTime? _targetDate;
  String _activeTab = 'recent'; // recent | favorites | mine
  bool _showPer100g = true; // results macros mode
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _myFoods = [];
  RangeValues _kcalRange = const RangeValues(0, 1000);
  bool _filterProtein = false;
  bool _filterCarb = false;
  bool _filterFat = false;
  String _sortKey =
      'relevance'; // relevance | kcal | protein | carbs | favorites
  List<String> _searchHistory = [];

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFavsMy();
    _restoreSearchFilters();
    _loadSearchHistory();
    // Read initial meal time from route args, if provided
    UserPreferences.getResultsShowPer100g().then((v) {
      if (mounted) setState(() => _showPer100g = v);
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
          }
          final dynamic prefillFoods = args['prefillFoods'];
          if (prefillFoods is List) {
            try {
              final list = prefillFoods.cast<Map<String, dynamic>>();
              if (list.isNotEmpty) {
                _selectedFood = list.first;
                _searchResults = list;
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
      if (_selectedFood == null && _searchController.text.isEmpty) {
        _searchFocus.requestFocus();
      }
    });
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        List<Map<String, dynamic>> results = _foodDatabase.where((food) {
          return (food['name'] as String).toLowerCase().contains(query) ||
              (food['brand'] as String).toLowerCase().contains(query);
        }).toList();

        // Apply kcal range filter
        results = results
            .where((f) =>
                ((f['calories'] as num?)?.toInt() ?? 0) >=
                    _kcalRange.start.round() &&
                ((f['calories'] as num?)?.toInt() ?? 0) <=
                    _kcalRange.end.round())
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

        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
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
    bool tmpProt = _filterProtein;
    bool tmpCarb = _filterCarb;
    bool tmpFat = _filterFat;
    String tmpSort = _sortKey;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtros', style: AppTheme.darkTheme.textTheme.titleMedium),
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
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: tmpProt,
                      onChanged: (v) => setState(() => tmpProt = v ?? false),
                      title: const Text('Priorizar proteína'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: tmpCarb,
                      onChanged: (v) => setState(() => tmpCarb = v ?? false),
                      title: const Text('Priorizar carbo'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: tmpFat,
                      onChanged: (v) => setState(() => tmpFat = v ?? false),
                      title: const Text('Priorizar gorduras'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text('Ordenação', style: AppTheme.darkTheme.textTheme.bodySmall),
              DropdownButton<String>(
                value: tmpSort,
                items: const [
                  DropdownMenuItem(
                      value: 'relevance', child: Text('Relevância')),
                  DropdownMenuItem(value: 'kcal', child: Text('Kcal (asc)')),
                  DropdownMenuItem(
                      value: 'protein', child: Text('Proteína (desc)')),
                  DropdownMenuItem(value: 'carbs', child: Text('Carbo (desc)')),
                  DropdownMenuItem(
                      value: 'favorites', child: Text('Favoritos primeiro')),
                ],
                onChanged: (v) => setState(() => tmpSort = v ?? 'relevance'),
              ),
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _kcalRange = tmpRange;
                      _filterProtein = tmpProt;
                      _filterCarb = tmpCarb;
                      _filterFat = tmpFat;
                      _sortKey = tmpSort;
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
                    Navigator.pop(ctx);
                    _onSearchChanged();
                  },
                  child: const Text('Aplicar'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters() {
    final bool kcalChanged = _kcalRange.start > 0 || _kcalRange.end < 1000;
    final bool macros = _filterProtein || _filterCarb || _filterFat;
    final bool sorted = _sortKey != 'relevance';
    return kcalChanged || macros || sorted;
  }

  void _clearAllFilters() {
    setState(() {
      _kcalRange = const RangeValues(0, 1000);
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

  Future<void> _onBarcodeScanned(String barcode) async {
    setState(() => _showBarcodeScanner = false);
    try {
      final off = OpenFoodFactsService();
      final item = await off.getByBarcode(barcode);
      if (item == null) {
        Fluttertoast.showToast(
          msg: 'Produto não encontrado',
          backgroundColor: AppTheme.errorRed,
          textColor: AppTheme.textPrimary,
        );
        return;
      }
      final food = {
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
      if (!mounted) return;
      setState(() {
        _selectedFood = food;
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
    setState(() {
      _selectedFood = food;
    });

    // Scroll to manual entry section
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onFoodSwipeRight(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
    });

    Fluttertoast.showToast(
      msg: '${food['name']} adicionado à refeição',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successGreen,
      textColor: AppTheme.textPrimary,
    );
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
                        _macroChip(
                            '${food['calories']} kcal', AppTheme.warningAmber),
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
                        final DateTime saveDate = _targetDate ?? DateTime.now();
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
                          'createdAt': DateTime.now().toIso8601String(),
                        };
                        await NutritionStorage.addEntry(saveDate, entry);
                        if (!mounted) return;
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: 'Salvo com porção aplicada',
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
                            final updated = state.buildUpdatedFoodFromPreview();
                            final DateTime saveDate =
                                _targetDate ?? DateTime.now();
                            final newId = DateTime.now().millisecondsSinceEpoch;
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
                              'createdAt': DateTime.now().toIso8601String(),
                            };
                            await NutritionStorage.addEntry(saveDate, entry);
                            if (!mounted) return;
                            Navigator.pop(context);
                            _showUndoSnackBar(saveDate, newId,
                                message: 'Adicionado ao diário (' +
                                    _currentMealLabel() +
                                    ')');
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.playlist_add),
                        label: Text(
                            'Adicionar ao diário — ' + _currentMealLabel()),
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
                                label:
                                    Text(isFav ? 'Desfavoritar' : 'Favoritar'),
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
                                label:
                                    const Text('Adicionar aos meus alimentos'),
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
                Navigator.pop(ctx);
                _showUndoSnackBar(saveDate, newId,
                    message: 'Adicionado ao diário (${_currentMealLabel()})');
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
    _showUndoSnackBar(saveDate, newId,
        message: 'Adicionado ${grams.toInt()}g em ${_currentMealLabel()}');
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

  void _onMealTimeChanged(String mealTime) {
    setState(() {
      _selectedMealTime = mealTime;
    });
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
      Fluttertoast.showToast(
        msg: '${_selectedFood!['name']} salvo! +$totalCalories kcal',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.textPrimary,
      );
      Navigator.pop(context, true);
    });
  }

  bool get _canSave => _selectedFood != null && _quantity > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
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
                              'Registrar Alimento',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              'Adicione alimentos à sua refeição',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Shortcut to edit quick chips
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.profile,
                              arguments: {'scrollTo': 'ui_prefs'});
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Chips'),
                        style: TextButton.styleFrom(foregroundColor: cs.primary),
                      ),
                      // Chips prefs shortcut next to meal selector would be implemented in the MealTimingSelectorWidget; for now, header has a shortcut.
                      // AI Detection button
                      GestureDetector(
                        onTap: () async {
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

                            // Scroll to manual entry section
                            Future.delayed(Duration(milliseconds: 100), () {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 300),
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
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.primary),
                          ),
        child: Column(
          children: [
                              CustomIconWidget(
                                iconName: 'psychology',
                                color: cs.primary,
                                size: 6.w,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'IA',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.activeBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Search (moved from scrollable content)
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                child: SearchBarWidget(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (value) {}, // handled by listener
                  onSubmitted: (v) async {
                    final t = v.trim();
                    if (t.isNotEmpty) await _addToSearchHistory(t);
                  },
                  onBarcodePressed: _onBarcodePressed,
                  onOpenFilters: _openFilters,
                  onDuplicateLastMeal: () async {
                    final DateTime date = _targetDate ?? DateTime.now();
                    final entries =
                        await NutritionStorage.getEntriesForDate(date);
                    if (entries.isEmpty) return;
                    entries.sort((a, b) => ((b['createdAt'] as String?) ?? '')
                        .compareTo((a['createdAt'] as String?) ?? ''));
                    final lastMealTime =
                        (entries.first['mealTime'] as String?) ?? 'snack';
                    final sameMeal = entries
                        .where(
                            (e) => (e['mealTime'] as String?) == lastMealTime)
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
                  },
                ),
              ),

              // Quick actions (Yazio-like)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onBarcodePressed,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Escanear'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final Map<String, dynamic> blankFood = {
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
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Novo alimento'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.recipeBrowser);
                        },
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Receitas'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),

              // Active Filters chips
              if (_hasActiveFilters())
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Kcal range chip (only when narrowed)
                        if (_kcalRange.start > 0 || _kcalRange.end < 1000)
                          Chip(
                            label: Text(
                                'Kcal: ${_kcalRange.start.round()}–${_kcalRange.end.round()}'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.activeBlue.withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.activeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterProtein)
                          Chip(
                            label: const Text('Foco proteína'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.activeBlue.withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.activeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterCarb)
                          Chip(
                            label: const Text('Foco carbo'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.successGreen.withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_filterFat)
                          Chip(
                            label: const Text('Foco gorduras'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
                            shape: StadiumBorder(
                              side: BorderSide(
                                  color: AppTheme.errorRed.withValues(alpha: 0.6)),
                            ),
                            labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (_sortKey != 'relevance')
                          Chip(
                            label: Text('Ordenação: ${_sortKey}') ,
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppTheme.secondaryBackgroundDark.withValues(alpha: 0.18),
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

              // Macro view toggle (100g vs porção)
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                child: Row(
                  children: [
                    Text('Exibir macros por:',
                        style: AppTheme.darkTheme.textTheme.bodySmall),
                    SizedBox(width: 2.w),
                    ChoiceChip(
                      label: const Text('100g'),
                      selected: _showPer100g,
                      onSelected: (v) {
                        if (!v) return;
                        _setShowPer100g(true);
                      },
                    ),
                    SizedBox(width: 2.w),
                    ChoiceChip(
                      label: const Text('porção'),
                      selected: !_showPer100g,
                      onSelected: (v) {
                        if (!v) return;
                        _setShowPer100g(false);
                      },
                    ),
                  ],
                ),
              ),

              // Search history chips (shown when field vazio)
              if (_searchController.text.isEmpty && _searchHistory.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.h),
                  child: Align(
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
                  ),
                ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // (SearchBar moved to fixed area above)

                      // Tabs
                      if (_searchController.text.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                      SizedBox(height: 1.h),
                      // Tab content when not searching
                      if (_searchController.text.isEmpty &&
                          _activeTab == 'recent')
                        FutureBuilder<List<double>>(
                          future: UserPreferences.getQuickPortionGramsForMeal(
                              _selectedMealTime),
                          builder: (context, snap) {
                            // Note: RecentFoodsWidget internally reads global defaults for header chips.
                            return RecentFoodsWidget(
                              recentFoods: _recentFoods,
                              onFoodTap: _onFoodTap,
                              onQuickSaveRequested: (food) async {
                                await _openPortionAndSave(food);
                              },
                              quickSaveMealLabel: _currentMealLabel(),
                              onQuickAddWithGrams: (food, grams) async {
                                await _quickAddWithGrams(food, grams);
                              },
                              mealKey: _selectedMealTime,
                            );
                          },
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
                        ),
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
                                          color: AppTheme.darkTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 2.h),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          final Map<String, dynamic> blankFood =
                                              {
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
                                        label:
                                            const Text('Adicionar manualmente'),
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
                                                arguments: {'scrollTo': 'foods_import'},
                                              );
                                            },
                                            icon: const Icon(Icons.file_upload),
                                            label: const Text('Importar alimentos'),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, AppRoutes.recipeBrowser);
                                            },
                                            icon: const Icon(Icons.menu_book_outlined),
                                            label: const Text('Explorar receitas'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _myFoods.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final food = _myFoods[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 2.h),
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .darkTheme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
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
                                                          AppTheme.activeBlue),
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
                                                            top:
                                                                Radius.circular(
                                                                    20),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.w),
                                                          child: _PortionPicker(
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
                                                                'calories': updated[
                                                                    'calories'],
                                                                'carbs': updated[
                                                                    'carbs'],
                                                                'protein': updated[
                                                                    'protein'],
                                                                'fat': updated[
                                                                    'fat'],
                                                                'brand': (updated[
                                                                            'brand']
                                                                        as String?) ??
                                                                    'Genérico',
                                                                'quantity': 1.0,
                                                                'serving': updated[
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
                                                                textColor: AppTheme
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
                                                      style: AppTheme.darkTheme
                                                          .textTheme.bodySmall,
                                                    ),
                                                  ],
                                                ),
                                                tooltip: 'Salvar no diário — ' +
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
                                                        food['name'] as String),
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

                      // Manual Entry
                      ManualEntryWidget(
                        selectedFood: _selectedFood,
                        onQuantityChanged: _onQuantityChanged,
                        onServingSizeChanged: _onServingSizeChanged,
                      ),

                      // Meal Timing Selector
                      if (_selectedFood != null)
                        FutureBuilder<MealSummary>(
                          future: MealSummaryService.compute(
                            date: _targetDate ?? DateTime.now(),
                            mealKey: _selectedMealTime,
                          ),
                          builder: (context, snap) {
                            final s = snap.data;
                            Widget summary = const SizedBox.shrink();
                            if (s != null) {
                              final int diffK = s.goalKcal - s.usedKcal;
                              final int diffC = s.goalCarb - s.usedCarb;
                              final int diffP = s.goalProt - s.usedProt;
                              final int diffF = s.goalFat - s.usedFat;
                              final int remK = diffK < 0 ? 0 : diffK;
                              final int remC = diffC < 0 ? 0 : diffC;
                              final int remP = diffP < 0 ? 0 : diffP;
                              final int remF = diffF < 0 ? 0 : diffF;
                              summary = Row(
                                children: [
                                  _chip('kcal', remK, AppTheme.warningAmber,
                                      exceeded: diffK < 0),
                                  SizedBox(width: 2.w),
                                  _chip('C', remC, AppTheme.successGreen,
                                      exceeded: diffC < 0),
                                  SizedBox(width: 2.w),
                                  _chip('P', remP, AppTheme.activeBlue,
                                      exceeded: diffP < 0),
                                  SizedBox(width: 2.w),
                                  _chip('G', remF, AppTheme.errorRed,
                                      exceeded: diffF < 0),
                                ],
                              );
                            }
                            return MealTimingSelectorWidget(
                              selectedMealTime: _selectedMealTime,
                              onMealTimeChanged: (m) {
                                _onMealTimeChanged(m);
                                setState(() {});
                              },
                              trailing: summary,
                            );
                          },
                        ),

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
                  child: ElevatedButton(
                    onPressed: _canSave ? _saveFood : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSave
                          ? AppTheme.activeBlue
                          : AppTheme.darkTheme.colorScheme.outline,
                      foregroundColor: AppTheme.textPrimary,
                      padding: EdgeInsets.symmetric(vertical: 3.h),
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
                        Builder(builder: (context) {
                          final num baseKcal =
                              (_selectedFood!['calories'] as num?) ?? 0;
                          final int totalKcal = (baseKcal * _quantity).round();
                          return Text(
                            'Adicionar ao ' + _currentMealLabel() + ' • ' +
                                totalKcal.toString() + ' kcal',
                            style: AppTheme.darkTheme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          );
                        }),
                      ],
                    ),
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

  Widget _tabButton(String label, String key) {
    final bool active = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.4.h),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.activeBlue.withValues(alpha: 0.18)
                : AppTheme.darkTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppTheme.activeBlue
                  : AppTheme.darkTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: active ? AppTheme.activeBlue : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
