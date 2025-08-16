import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.hasActiveFilters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dividerGray.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTheme.darkTheme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar receitas...',
                  hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.textSecondary,
                      size: 5.w,
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChanged('');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.textSecondary,
                              size: 5.w,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 3.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Filter Button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? AppTheme.activeBlue.withValues(alpha: 0.2)
                    : AppTheme.secondaryBackgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveFilters
                      ? AppTheme.activeBlue
                      : AppTheme.dividerGray.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: hasActiveFilters
                        ? AppTheme.activeBlue
                        : AppTheme.textSecondary,
                    size: 6.w,
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: const BoxDecoration(
                          color: AppTheme.activeBlue,
                          shape: BoxShape.circle,
                        ),
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
}
