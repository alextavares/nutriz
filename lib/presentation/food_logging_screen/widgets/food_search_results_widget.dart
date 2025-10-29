// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/favorites_storage.dart';
import '../../../services/user_preferences.dart';

class FoodSearchResultsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final Function(Map<String, dynamic>) onFoodTap;
  final Function(Map<String, dynamic>) onFoodSwipeRight;
  final Function(Map<String, dynamic>) onFoodSwipeLeft;
  final Future<void> Function()? onFavoritesChanged;
  final bool enableOnlyFavsToggle;
  final String title;
  final bool showEmptyPlaceholder;
  final String? emptyTitle;
  final String? emptySubtitle;
  final void Function(Map<String, dynamic>)? onQuickSaveRequested;
  final String? quickSaveMealLabel;
  final void Function(Map<String, dynamic> food, double grams)?
      onQuickAddWithGrams;
  final String? headerRightText;
  final VoidCallback? onHeaderRightTap;
  // Controls whether to display macros per 100g or per serving
  final bool showPer100g;
  // Controls whether to display source badges (OFF/FDC/NLQ)
  final bool showSourceBadges;

  const FoodSearchResultsWidget({
    Key? key,
    required this.searchResults,
    required this.onFoodTap,
    required this.onFoodSwipeRight,
    required this.onFoodSwipeLeft,
    this.onFavoritesChanged,
    this.enableOnlyFavsToggle = false,
    this.title = 'Resultados da Busca',
    this.showEmptyPlaceholder = false,
    this.emptyTitle,
    this.emptySubtitle,
    this.onQuickSaveRequested,
    this.quickSaveMealLabel,
    this.onQuickAddWithGrams,
    this.headerRightText,
    this.onHeaderRightTap,
    this.showPer100g = true,
    this.showSourceBadges = true,
  }) : super(key: key);

  @override
  State<FoodSearchResultsWidget> createState() =>
      _FoodSearchResultsWidgetState();
}

class _FoodSearchResultsWidgetState extends State<FoodSearchResultsWidget> {
  bool _onlyFavs = false;
  Set<String> _favNames = {};

  @override
  void initState() {
    super.initState();
    _refreshFavs();
  }

  Future<void> _refreshFavs() async {
    try {
      final favs = await FavoritesStorage.getFavorites();
      setState(() {
        _favNames = favs
            .map((e) => (e['name'] as String?)?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> baseList = widget.searchResults;
    final List<Map<String, dynamic>> effectiveList = _onlyFavs
        ? baseList
            .where((f) => _favNames.contains((f['name'] as String?) ?? ''))
            .toList()
        : baseList;
    final int displayedCount = effectiveList.length;
    final int favCount = baseList
        .where((f) => _favNames.contains((f['name'] as String?) ?? ''))
        .length;
    if (effectiveList.isEmpty && !widget.showEmptyPlaceholder) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const Spacer(),
                  if (widget.headerRightText != null &&
                      widget.onHeaderRightTap != null)
                    TextButton(
                      onPressed: widget.onHeaderRightTap,
                      child: Text(widget.headerRightText!),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '$displayedCount itens • $favCount favoritos',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const Spacer(),
                  if (widget.enableOnlyFavsToggle)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Somente favoritos',
                          style: AppTheme.darkTheme.textTheme.bodySmall,
                        ),
                        SizedBox(width: 2.w),
                        Switch(
                          value: _onlyFavs,
                          onChanged: (v) => setState(() => _onlyFavs = v),
                          activeColor: AppTheme.premiumGold,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (_onlyFavs) ...[
                          SizedBox(width: 1.w),
                          TextButton(
                            onPressed: () => setState(() => _onlyFavs = false),
                            child: const Text('Limpar'),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        if (effectiveList.isEmpty && widget.showEmptyPlaceholder)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Column(
              children: [
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: AppTheme.premiumGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.premiumGold,
                    size: 9.w,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.emptyTitle ?? 'Você ainda não tem favoritos',
                  style: AppTheme.darkTheme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.8.h),
                Text(
                  widget.emptySubtitle ??
                      'Toque na estrela para favoritar itens nas buscas e acesso rápido aqui.',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                if (widget.onHeaderRightTap != null)
                  ElevatedButton.icon(
                    onPressed: widget.onHeaderRightTap,
                    icon: const Icon(Icons.tune),
                    label: Text(AppLocalizations.of(context)!.openFilters),
                  ),
              ],
            ),
          ),
        if (effectiveList.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: effectiveList.length,
            itemBuilder: (context, index) {
              final food = effectiveList[index];
              final int kcal = _perServing(food)['cal'] ?? 0;
              return Dismissible(
                key: Key('${food['id']}_$index'),
                direction: DismissDirection.none,
                background: Container(
                  margin: EdgeInsets.only(bottom: 1.2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.textPrimary,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        AppLocalizations.of(context)!.navAdd,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  margin: EdgeInsets.only(bottom: 1.2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.activeBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.details,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'info_outline',
                        color: AppTheme.textPrimary,
                        size: 6.w,
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    widget.onFoodSwipeRight(food);
                  } else {
                    widget.onFoodSwipeLeft(food);
                  }
                },
                child: GestureDetector(
                  onTap: () => widget.onFoodTap(food),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 0.8.h),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBackgroundDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.dividerGray.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        _leadingThumb(food),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'] as String,
                                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              _brandRow(food),
                              // Simplified cell: keep clean, no macro chips here
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$kcal kcal',
                              style: AppTheme.darkTheme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 0),
                            if (widget.onQuickSaveRequested != null)
                              IconButton(
                                tooltip: widget.quickSaveMealLabel != null
                                    ? AppLocalizations.of(context)!
                                        .addToDiaryWithMeal(widget.quickSaveMealLabel!)
                                    : AppLocalizations.of(context)!.navAdd,
                                onPressed: () =>
                                    widget.onQuickSaveRequested!(food),
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppTheme.activeBlue,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                iconSize: 20,
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _leadingThumb(Map<String, dynamic> food) {
    final String? url = (food['imageUrl'] as String?);
    if (url != null && url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 12.w,
          height: 12.w,
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.08),
          child: Image.network(url, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: AppTheme.activeBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: 'restaurant',
        color: AppTheme.activeBlue,
        size: 6.w,
      ),
    );
  }

  bool _isVerified(Map<String, dynamic> food) {
    final barcode = (food['barcode'] as String?) ?? '';
    final verified = (food['verified'] as bool?) ?? false;
    final source = (food['source'] as String?) ?? '';
    return verified || barcode.isNotEmpty || source.toUpperCase() == 'OFF';
  }

  Widget _brandRow(Map<String, dynamic> food) {
    final brand = (food['brand'] as String?) ?? 'Genérico';
    final verified = _isVerified(food);
    final source = (food['source'] as String?)?.toUpperCase() ?? '';
    final style = AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
    );
    final hasKnownSource = widget.showSourceBadges && (source == 'NLQ' || source == 'OFF' || source == 'FDC');
    if (!verified && !hasKnownSource) {
      return Text(
        brand,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    // Show brand + optional verified icon and source badge
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            brand,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 1.w),
        if (verified)
          Tooltip(
            message: 'Dados verificados (código de barras)',
            child: Icon(
              Icons.verified,
              size: 16,
              color: AppTheme.premiumGold,
            ),
          ),
        if (widget.showSourceBadges && hasKnownSource) ...[
          SizedBox(width: 1.w),
          _sourceBadge(source),
        ],
      ],
    );
  }

  Widget _sourceBadge(String source) {
    final cs = AppTheme.darkTheme.colorScheme;
    IconData icon;
    String label;
    switch (source) {
      case 'OFF':
        icon = Icons.public;
        label = 'Fonte: OFF';
        break;
      case 'FDC':
        icon = Icons.storage;
        label = 'Fonte: FDC';
        break;
      case 'NLQ':
      default:
        icon = Icons.auto_awesome;
        label = 'Fonte: NLQ';
        break;
    }
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _macroChipsFor(Map<String, dynamic> food) {
    if (widget.showPer100g) {
      final per = _per100(food);
      return [
        _buildNutrientChip('${per['cal']} kcal/100g', AppTheme.warningAmber),
        _buildNutrientChip('C: ${per['carb']}g', AppTheme.successGreen),
        _buildNutrientChip('P: ${per['prot']}g', AppTheme.activeBlue),
        _buildNutrientChip('G: ${per['fat']}g', AppTheme.errorRed),
      ];
    }
    final perServing = _perServing(food);
    return [
      _buildNutrientChip('${perServing['cal']} kcal/porção', AppTheme.warningAmber),
      _buildNutrientChip('C: ${perServing['carb']}g', AppTheme.successGreen),
      _buildNutrientChip('P: ${perServing['prot']}g', AppTheme.activeBlue),
      _buildNutrientChip('G: ${perServing['fat']}g', AppTheme.errorRed),
    ];
  }

  double _calcCaloriesPerGram(Map<String, dynamic> food) {
    try {
      final int calories = (food['calories'] as num).toInt();
      final String? serving = food['serving'] as String?;
      double base = 100;
      if (serving != null) {
        final m = RegExp(r"(\\d+)\\s*g").firstMatch(serving);
        if (m != null) base = double.tryParse(m.group(1)!) ?? 100;
      }
      if (base <= 0) base = 100;
      return calories / base;
    } catch (_) {
      return 0.0;
    }
  }

  Map<String, int> _perServing(Map<String, dynamic> food) {
    int toInt(num? v) => (v ?? 0).toInt();
    return {
      'cal': toInt(food['calories'] as num?),
      'carb': toInt(food['carbs'] as num?),
      'prot': toInt(food['protein'] as num?),
      'fat': toInt(food['fat'] as num?),
    };
  }

  Map<String, int> _per100(Map<String, dynamic> food) {
    // Calculates per 100g macro values based on current serving info
    try {
      final String? serving = food['serving'] as String?;
      double base = 100;
      if (serving != null) {
        final m = RegExp(r"(\\d+)\\s*g").firstMatch(serving);
        if (m != null) base = double.tryParse(m.group(1)!) ?? 100;
      }
      base = base <= 0 ? 100 : base;
      double scale = 100 / base;
      int roundNum(num v) => (v.toDouble() * scale).round();
      return {
        'cal': roundNum((food['calories'] as num?) ?? 0),
        'carb': roundNum((food['carbs'] as num?) ?? 0),
        'prot': roundNum((food['protein'] as num?) ?? 0),
        'fat': roundNum((food['fat'] as num?) ?? 0),
      };
    } catch (_) {
      return {
        'cal': (food['calories'] as num?)?.toInt() ?? 0,
        'carb': (food['carbs'] as num?)?.toInt() ?? 0,
        'prot': (food['protein'] as num?)?.toInt() ?? 0,
        'fat': (food['fat'] as num?)?.toInt() ?? 0,
      };
    }
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
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
}

class _QuickAddChips extends StatefulWidget {
  final void Function(double grams) onTap;
  final double caloriesPerGram; // for preview kcal
  const _QuickAddChips({
    required this.onTap,
    this.caloriesPerGram = 0,
  });

  @override
  State<_QuickAddChips> createState() => _QuickAddChipsState();
}

class _QuickAddChipsState extends State<_QuickAddChips> {
  List<double> _options = const [50.0, 100.0, 150.0, 200.0, 250.0];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final grams = await UserPreferences.getQuickPortionGrams();
      if (!mounted) return;
      setState(() {
        _options = grams;
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 1.w,
      children: _options
          .map((g) => GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap(g);
                },
                child: Chip(
                  label: _buildChipText(g),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  backgroundColor: AppTheme.secondaryBackgroundDark,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AppTheme.activeBlue.withValues(alpha: 0.6)),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildChipText(double grams) {
    if (widget.caloriesPerGram > 0) {
      final kcal = (widget.caloriesPerGram * grams).round();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${grams.toInt()}g',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.activeBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 0.8.w),
          Text(
            '• ~${kcal} kcal',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    return Text(
      '${grams.toInt()}g',
      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.activeBlue,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}



