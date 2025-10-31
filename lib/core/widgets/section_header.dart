import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Standard section header with optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppTextStyles.h2(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: text.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (trailingText != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTrailingTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  trailingText!,
                  style: AppTextStyles.body2(context)
                      .copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

