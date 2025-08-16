import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onBarcodePressed;
  final VoidCallback? onDuplicateLastMeal;
  final VoidCallback? onOpenFilters;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onBarcodePressed,
    this.onDuplicateLastMeal,
    this.onOpenFilters,
    this.onSubmitted,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTheme.darkTheme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Buscar alimentos... (nome ou marca)',
          hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (onOpenFilters != null)
                GestureDetector(
                  onTap: onOpenFilters,
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              if (onDuplicateLastMeal != null)
                GestureDetector(
                  onTap: onDuplicateLastMeal,
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'content_copy',
                      color: AppTheme.textPrimary,
                      size: 5.w,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: onBarcodePressed,
                child: Container(
                  margin: EdgeInsets.all(2.w),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: AppTheme.textPrimary,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.2.h),
        ),
      ),
    );
  }
}
