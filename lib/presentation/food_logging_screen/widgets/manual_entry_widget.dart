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
          Text(
            'Quantidade e Porção',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Selected Food Info
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
                      Text(
                        '${widget.selectedFood!['calories']} kcal por porção',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Quantity Stepper
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
                          setState(() {
                            _quantity -= 0.25;
                          });
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
                          setState(() {
                            _quantity += 0.25;
                          });
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

          SizedBox(height: 3.h),

          // Serving Size Picker (ChoiceChips + fallback dropdown)
          Text('Tipo de Porção:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
          SizedBox(height: 0.8.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _servingSizes.map((s) {
              final selected = _selectedServingSize == s;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedServingSize = s);
                  widget.onServingSizeChanged(s);
                },
                labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: selected ? AppTheme.activeBlue : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: AppTheme.secondaryBackgroundDark,
                selectedColor: AppTheme.activeBlue.withValues(alpha: 0.12),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: (selected
                            ? AppTheme.activeBlue
                            : AppTheme.dividerGray)
                        .withValues(alpha: 0.6),
                  ),
                ),
              );
            }).toList(),
          ),

          // Save as default (chip-like row)
          SizedBox(height: 1.2.h),
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
                const Icon(Icons.save_outlined, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 1.w),
                Text('Salvar como padrão',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    )),
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

          SizedBox(height: 3.h),

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
                  'Valores Nutricionais (${_quantity} ${_selectedServingSize})',
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
                      '${((widget.selectedFood!['carbs'] as int) * _quantity).round()}g',
                      AppTheme.successGreen,
                    ),
                    _buildNutrientInfo(
                      'Proteínas',
                      '${((widget.selectedFood!['protein'] as int) * _quantity).round()}g',
                      AppTheme.activeBlue,
                    ),
                  ],
                ),
              ],
            ),
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
}
