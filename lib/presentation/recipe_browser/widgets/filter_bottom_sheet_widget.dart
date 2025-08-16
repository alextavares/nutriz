import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

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

  final List<String> _mealTypes = [
    'Café da Manhã',
    'Almoço',
    'Jantar',
    'Lanche'
  ];
  final List<String> _dietaryRestrictions = [
    'Vegetariano',
    'Vegano',
    'Sem Glúten',
    'Low-Carb',
    'Keto'
  ];
  final List<String> _prepTimes = [
    '< 15 min',
    '15-30 min',
    '30-60 min',
    '> 60 min'
  ];
  final List<String> _calorieRanges = [
    '< 200 cal',
    '200-400 cal',
    '400-600 cal',
    '> 600 cal'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
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
              color: AppTheme.dividerGray,
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
                  'Filtros',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Limpar Tudo',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _applyFilters,
                      child: Text(
                        'Aplicar',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.activeBlue,
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
                  _buildFilterSection(
                      'Tipo de Refeição', _mealTypes, 'mealTypes'),
                  _buildFilterSection('Restrições Alimentares',
                      _dietaryRestrictions, 'dietaryRestrictions'),
                  _buildFilterSection(
                      'Tempo de Preparo', _prepTimes, 'prepTimes'),
                  _buildFilterSection(
                      'Calorias', _calorieRanges, 'calorieRanges'),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
      String title, List<String> options, String filterKey) {
    final selectedOptions = (_filters[filterKey] as List<String>?) ?? [];

    return ExpansionTile(
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      iconColor: AppTheme.textSecondary,
      collapsedIconColor: AppTheme.textSecondary,
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
                        ? AppTheme.activeBlue.withValues(alpha: 0.2)
                        : AppTheme.primaryBackgroundDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.activeBlue
                          : AppTheme.dividerGray,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.activeBlue
                          : AppTheme.textPrimary,
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
