// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class ManualEntryWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedFood;
  final Function(double) onQuantityChanged;
  final Function(String) onServingSizeChanged;

  const ManualEntryWidget({
    Key? key,
    this.selectedFood,
    required this.onQuantityChanged,
    required this.onServingSizeChanged,
  }) : super(key: key);

  @override
  State<ManualEntryWidget> createState() => _ManualEntryWidgetState();
}

class _ManualEntryWidgetState extends State<ManualEntryWidget> {
  double _quantity = 1.0;
  String _selectedServingSize = 'porção';
  bool saveAsDefault = false;
  bool _showDetails = false;

  final List<String> _servingSizes = [
    'porção',
    'gramas',
    'xícara',
    'colher de sopa',
    'colher de chá',
    'unidade',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.selectedFood == null) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Food Info (compact header)
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppTheme.activeBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'restaurant',
                    color: AppTheme.activeBlue,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedFood!['name'] as String,
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Builder(builder: (context) {
                        final baseCal = (widget.selectedFood!['calories'] as num?)?.toInt() ?? 0;
                        final currentCal = (baseCal * _quantity).round();
                        return Row(
                          children: [
                            Text(
                              '≈ ' + currentCal.toString() + ' kcal',
                              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.activeBlue,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.selectedFood!['calories']} kcal por porção',
                              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      }),
                      if ((widget.selectedFood!['name'] as String?)?.toLowerCase().contains('(total)') == true ||
                          (widget.selectedFood!['name'] as String?)?.toLowerCase().contains(' total') == true)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.activeBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppTheme.activeBlue.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Sugestão: prato inteiro',
                            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.activeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Quantity (simplified stepper)
          Row(
            children: [
              Text(
                'Quantidade:',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (_quantity > 0.25) {
                          setState(() { _quantity -= 0.25; });
                          widget.onQuantityChanged(_quantity);
                        }
                      },
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppTheme.activeBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'remove',
                          color: AppTheme.activeBlue,
                          size: 5.w,
                        ),
                      ),
                    ),
                    Container(
                      width: 20.w,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        _quantity.toString(),
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (_quantity < 10) {
                          setState(() { _quantity += 0.25; });
                          widget.onQuantityChanged(_quantity);
                        }
                      },
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppTheme.activeBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.activeBlue,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
// Quick suggestions
          SizedBox(height: 1.2.h),
          _buildQuickSuggestions(),



          SizedBox(height: 3.h),

          // Serving Size Picker (ChoiceChips + fallback dropdown)
          
          if (_selectedServingSize.toLowerCase().contains('grama')) ...[
            SizedBox(height: 1.2.h),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _quantity.clamp(0.5, 5.0),
                    min: 0.5,
                    max: 5.0,
                    divisions: 18, // 25 g steps if 1.0 = 100 g
                    label: '${((_quantity)*100).round()} g',
                    onChanged: (v) {
                      setState(() { _quantity = double.parse(v.toStringAsFixed(2)); });
                      widget.onQuantityChanged(_quantity);
                    },
                    activeColor: AppTheme.activeBlue,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${((_quantity)*100).round()} g',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],


          // Serving Size Picker (Segmented)
          Text('Tipo de porção',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
          SizedBox(height: 0.8.h),
          _buildServingSegmented(),


          // Details (collapsed by default)
          SizedBox(height: 1.2.h),
          InkWell(
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Row(
              children: [
                Icon(
                  _showDetails ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Detalhes',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 1.h),
                // Calculated Nutrition
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valores nutricionais (' + _quantity.toStringAsFixed(2) + ' ' + _selectedServingSize + ')',
                        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNutrientInfo(
                            'Calorias',
                            '${((widget.selectedFood!['calories'] as int) * _quantity).round()} kcal',
                            AppTheme.warningAmber,
                          ),
                          _buildNutrientInfo(
                            'Carboidratos',
                            '${((widget.selectedFood!['carbs'] as int) * _quantity).round()} g',
                            AppTheme.successGreen,
                          ),
                          _buildNutrientInfo(
                            'Proteínas',
                            '${((widget.selectedFood!['protein'] as int) * _quantity).round()} g',
                            AppTheme.activeBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.2.h),
                // Save as default (chip-like row)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundDark,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_outlined, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: 1.w),
                      Text(
                        'Salvar como padrão',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Switch(
                        value: saveAsDefault,
                        onChanged: (v) => setState(() => saveAsDefault = v),
                        activeColor: AppTheme.activeBlue,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _showDetails ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String label, double qty) {
    return ChoiceChip(
      label: Text(label),
      selected: _quantity == qty,
      onSelected: (_) {
        setState(() => _quantity = qty);
        widget.onQuantityChanged(_quantity);
      },
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppTheme.secondaryBackgroundDark,
      selectedColor: AppTheme.activeBlue.withValues(alpha: 0.12),
      shape: StadiumBorder(
        side: BorderSide(
          color: AppTheme.dividerGray.withValues(alpha: 0.6),
        ),
      ),
    );
  }


  Widget _buildQuickSuggestions() {
    final isGrams = _selectedServingSize.toLowerCase().contains('grama');
    final List<Map<String, dynamic>> items = isGrams
        ? [
            {'label': '100 g', 'qty': 1.0},
            {'label': '150 g', 'qty': 1.5},
            {'label': '200 g', 'qty': 2.0},
          ]
        : [
            {'label': '0,5x', 'qty': 0.5},
            {'label': '1x', 'qty': 1.0},
            {'label': '2x', 'qty': 2.0},
          ];
    return Row(
      children: [
        Text(
          'Sugestões:',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 2.w),
        Wrap(
          spacing: 8,
          children: items
              .map((i) => _quickChip(i['label'] as String, (i['qty'] as num).toDouble()))
              .toList(),
        ),
      ],
    );
  }


  Widget _buildServingSegmented() {
    final primary = ['gramas', 'unidade', 'xícara'];
    final labels = {'gramas': 'g', 'unidade': 'unid.', 'xícara': 'xíc.'};
    Color selectedBg = AppTheme.activeBlue.withValues(alpha: 0.12);
    Color outline = AppTheme.dividerGray.withValues(alpha: 0.6);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Row(
        children: [
          for (final key in primary)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() => _selectedServingSize = key);
                  widget.onServingSizeChanged(key);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedServingSize == key ? selectedBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[key] ?? key,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: _selectedServingSize == key ? AppTheme.activeBlue : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _openServingMore,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Mais',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openServingMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Outros tipos de porção', style: AppTheme.darkTheme.textTheme.titleMedium),
              ),
              for (final s in _servingSizes)
                ListTile(
                  title: Text(s),
                  trailing: _selectedServingSize == s
                      ? Icon(Icons.check, color: AppTheme.activeBlue)
                      : null,
                  onTap: () {
                    setState(() => _selectedServingSize = s);
                    widget.onServingSizeChanged(s);
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

}
