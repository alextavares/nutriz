import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:nutritracker/l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  // Display text is localized; underlying values match stored recipe data (PT) for filtering.
  List<Map<String, String>> _mealTypePairs(BuildContext context) => [
        {
          "label": AppLocalizations.of(context)?.mealBreakfast ?? 'Breakfast',
          "value": 'Café da Manhã'
        },
        {
          "label": AppLocalizations.of(context)?.mealLunch ?? 'Lunch',
          "value": 'Almoço'
        },
        {
          "label": AppLocalizations.of(context)?.mealDinner ?? 'Dinner',
          "value": 'Jantar'
        },
        {
          "label": AppLocalizations.of(context)?.mealSnack ?? 'Snack',
          "value": 'Lanche'
        },
      ];
  List<Map<String, String>> _dietPairs(BuildContext context) => [
        {
          "label": AppLocalizations.of(context)?.dietVegetarian ?? 'Vegetarian',
          "value": 'Vegetariano'
        },
        {
          "label": AppLocalizations.of(context)?.dietVegan ?? 'Vegan',
          "value": 'Vegano'
        },
        {
          "label":
              AppLocalizations.of(context)?.dietGlutenFree ?? 'Gluten-Free',
          "value": 'Sem Glúten'
        },
        {"label": 'Low-Carb', "value": 'Low-Carb'},
        {"label": 'Keto', "value": 'Keto'},
      ];
  List<Map<String, String>> _prepPairs(BuildContext context) => [
        {
          "label": AppLocalizations.of(context)?.prepLt15 ?? '< 15 min',
          "value": '< 15 min'
        },
        {
          "label": AppLocalizations.of(context)?.prep15to30 ?? '15-30 min',
          "value": '15-30 min'
        },
        {
          "label": AppLocalizations.of(context)?.prep30to60 ?? '30-60 min',
          "value": '30-60 min'
        },
        {
          "label": AppLocalizations.of(context)?.prepGt60 ?? '> 60 min',
          "value": '> 60 min'
        },
      ];
  List<Map<String, String>> _calPairs(BuildContext context) => [
        {
          "label": AppLocalizations.of(context)?.calLt200 ?? '< 200 cal',
          "value": '< 200 cal'
        },
        {
          "label": AppLocalizations.of(context)?.cal200to400 ?? '200-400 cal',
          "value": '200-400 cal'
        },
        {
          "label": AppLocalizations.of(context)?.cal400to600 ?? '400-600 cal',
          "value": '400-600 cal'
        },
        {
          "label": AppLocalizations.of(context)?.calGt600 ?? '> 600 cal',
          "value": '> 600 cal'
        },
      ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.filtersTitle ?? 'Filters',
                  style: textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        AppLocalizations.of(context)?.clearAll ?? 'Clear all',
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _applyFilters,
                      child: Text(
                        AppLocalizations.of(context)?.apply ?? 'Apply',
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Filter Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  _buildFilterSectionPairs(
                      AppLocalizations.of(context)?.mealType ?? 'Meal Type',
                      _mealTypePairs(context),
                      'mealTypes'),
                  _buildFilterSectionPairs(
                      AppLocalizations.of(context)?.dietaryRestrictions ??
                          'Dietary Restrictions',
                      _dietPairs(context),
                      'dietaryRestrictions'),
                  _buildFilterSectionPairs(
                      AppLocalizations.of(context)?.prepTime ?? 'Prep Time',
                      _prepPairs(context),
                      'prepTimes'),
                  _buildFilterSectionPairs(
                      AppLocalizations.of(context)?.calories ?? 'Calories',
                      _calPairs(context),
                      'calorieRanges'),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSectionPairs(
      String title, List<Map<String, String>> pairs, String filterKey) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selectedOptions = (_filters[filterKey] as List<String>?) ?? [];
    return ExpansionTile(
      title: Text(
        title,
        style: textStyles.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      iconColor: colors.onSurfaceVariant,
      collapsedIconColor: colors.onSurfaceVariant,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              for (final p in pairs)
                GestureDetector(
                  onTap: () => _toggleOption(filterKey, p['value']!),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: selectedOptions.contains(p['value'])
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedOptions.contains(p['value'])
                            ? colors.primary
                            : colors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      p['label']!,
                      style: textStyles.bodySmall?.copyWith(
                        color: selectedOptions.contains(p['value'])
                            ? colors.primary
                            : colors.onSurface,
                        fontWeight: selectedOptions.contains(p['value'])
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildFilterSection(
      String title, List<String> options, String filterKey) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selectedOptions = (_filters[filterKey] as List<String>?) ?? [];

    return ExpansionTile(
      title: Text(
        title,
        style: textStyles.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      iconColor: colors.onSurfaceVariant,
      collapsedIconColor: colors.onSurfaceVariant,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return GestureDetector(
                onTap: () => _toggleOption(filterKey, option),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: textStyles.bodySmall?.copyWith(
                      color:
                          isSelected ? colors.primary : colors.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _toggleOption(String filterKey, String option) {
    setState(() {
      final currentList = (_filters[filterKey] as List<String>?) ?? <String>[];
      if (currentList.contains(option)) {
        currentList.remove(option);
      } else {
        currentList.add(option);
      }
      _filters[filterKey] = currentList;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}
