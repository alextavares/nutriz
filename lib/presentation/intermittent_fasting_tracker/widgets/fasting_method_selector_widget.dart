import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class FastingMethodSelectorWidget extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const FastingMethodSelectorWidget({
    Key? key,
    required this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fastingMethods = [
      {
        "id": "16:8",
        "title": "16:8",
        "subtitle": "16h jejum, 8h alimentação",
        "description": "Método mais popular para iniciantes",
        "icon": "schedule",
        "color": context.colors.primary,
      },
      {
        "id": "18:6",
        "title": "18:6",
        "subtitle": "18h jejum, 6h alimentação",
        "description": "Nível intermediário",
        "icon": "timer",
        "color": context.semanticColors.warning,
      },
      {
        "id": "20:4",
        "title": "20:4",
        "subtitle": "20h jejum, 4h alimentação",
        "description": "Nível avançado",
        "icon": "fitness_center",
        "color": context.colors.error,
      },
      {
        "id": "custom",
        "title": "Personalizado",
        "subtitle": "Configure seu próprio",
        "description": "Defina horários específicos",
        "icon": "settings",
        "color": context.semanticColors.premium,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Método de Jejum',
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: fastingMethods.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final method = fastingMethods[index];
              final isSelected = selectedMethod == (method["id"] as String);

              return GestureDetector(
                onTap: () => onMethodSelected(method["id"] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (method["color"] as Color).withValues(alpha: 0.2)
                        : context.colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (method["color"] as Color)
                          : context.colors.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: method["icon"] as String,
                            color: isSelected
                                ? (method["color"] as Color)
                                : context.colors.onSurfaceVariant,
                            size: 20,
                          ),
                          const Spacer(),
                          if (isSelected)
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: method["color"] as Color,
                              size: 16,
                            ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        method["title"] as String,
                        style: context.textStyles.titleMedium?.copyWith(
                          color: isSelected
                              ? (method["color"] as Color)
                              : context.colors.onSurface,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        method["subtitle"] as String,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Expanded(
                        child: Text(
                          method["description"] as String,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant
                                .withValues(alpha: 0.8),
                            fontSize: 9.sp,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
