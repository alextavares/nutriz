import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/user_preferences.dart';

class RecentFoodsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> recentFoods;
  final Function(Map<String, dynamic>) onFoodTap;
  final void Function(Map<String, dynamic>)? onQuickSaveRequested;
  final String? quickSaveMealLabel;
  final void Function(Map<String, dynamic> food, double grams)?
      onQuickAddWithGrams;
  final String? mealKey;

  const RecentFoodsWidget({
    Key? key,
    required this.recentFoods,
    required this.onFoodTap,
    this.onQuickSaveRequested,
    this.quickSaveMealLabel,
    this.onQuickAddWithGrams,
    this.mealKey,
  }) : super(key: key);

  @override
  State<RecentFoodsWidget> createState() => _RecentFoodsWidgetState();
}

class _RecentFoodsWidgetState extends State<RecentFoodsWidget> {
  List<double> _quickOptions = const [50, 100, 150, 200, 250];

  @override
  void initState() {
    super.initState();
    _loadQuickOptions();
  }

  @override
  void didUpdateWidget(covariant RecentFoodsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealKey != widget.mealKey) {
      _loadQuickOptions();
    }
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

  Future<void> _loadQuickOptions() async {
    try {
      List<double> list;
      if (widget.mealKey != null && widget.mealKey!.isNotEmpty) {
        list =
            await UserPreferences.getQuickPortionGramsForMeal(widget.mealKey!);
      } else {
        list = await UserPreferences.getQuickPortionGrams();
      }
      if (!mounted) return;
      setState(() => _quickOptions = list);
    } catch (_) {}
  }

  double _averageCaloriesPerGram(List<Map<String, dynamic>> foods) {
    double sum = 0;
    int count = 0;
    for (final f in foods) {
      final cpg = _calcCaloriesPerGram(f);
      if (cpg > 0) {
        sum += cpg;
        count++;
      }
    }
    if (count == 0) return 0.0;
    return sum / count;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recentFoods.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Alimentos Recentes',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Tooltip(
                message:
                    'Kcal por chip estimada pela média de kcal/grama dos itens recentes.',
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 0.8.h,
            children: [
              for (final g in _quickOptions)
                Chip(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.2.h),
                  backgroundColor: AppTheme.secondaryBackgroundDark,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AppTheme.activeBlue.withValues(alpha: 0.5)),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${g.toInt()}g',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.activeBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Builder(builder: (context) {
                        final avg = _averageCaloriesPerGram(widget.recentFoods);
                        if (avg <= 0) return const SizedBox.shrink();
                        final kcal = (avg * g).round();
                        return Text(
                          '• ~${kcal} kcal',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      })
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 0.8.h),
        SizedBox(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: widget.recentFoods.length,
            itemBuilder: (context, index) {
              final food = widget.recentFoods[index];
              return GestureDetector(
                onTap: () => widget.onFoodTap(food),
                child: Container(
                  width: 25.w,
                  margin: EdgeInsets.only(right: 3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppTheme.activeBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'restaurant',
                            color: AppTheme.activeBlue,
                            size: 4.w,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          food['name'] as String,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.onQuickAddWithGrams != null) ...[
                          SizedBox(height: 0.4.h),
                          Wrap(
                            spacing: 1.w,
                            children: _quickOptions
                                .map((g) => GestureDetector(
                                      onTap: () =>
                                          widget.onQuickAddWithGrams!(food, g),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.6.w, vertical: 0.2.h),
                                        decoration: BoxDecoration(
                                          color: AppTheme.activeBlue
                                              .withValues(alpha: 0.16),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppTheme.activeBlue
                                                  .withValues(alpha: 0.6)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${g.toInt()}g',
                                                style: AppTheme.darkTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppTheme.activeBlue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 0.8.w),
                                            Builder(builder: (context) {
                                              final cpg =
                                                  _calcCaloriesPerGram(food);
                                              if (cpg <= 0) {
                                                return const SizedBox.shrink();
                                              }
                                              final kcal = (cpg * g).round();
                                              return Text(
                                                '• ~${kcal} kcal',
                                                style: AppTheme.darkTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppTheme
                                                      .darkTheme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (widget.onQuickSaveRequested != null) ...[
                          SizedBox(height: 0.6.h),
                          SizedBox(
                            height: 3.6.h,
                            child: TextButton.icon(
                              onPressed: () =>
                                  widget.onQuickSaveRequested!(food),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.2.h),
                                foregroundColor: AppTheme.successGreen,
                              ),
                              icon: const Icon(Icons.playlist_add, size: 16),
                              label: Text(
                                widget.quickSaveMealLabel ?? '',
                                style: AppTheme.darkTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 0.4.h),
                        Text(
                          (food['brand'] as String?) ?? '—',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
