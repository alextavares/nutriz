import 'package:flutter/material.dart';

class KeyValue {
  final String label;
  final String value;
  final String? helper;
  final VoidCallback? onTap;
  const KeyValue(this.label, this.value, {this.helper, this.onTap});
}

/// Vertical list of label/value pairs with consistent spacing and
/// typography. Designed for compact goal summaries like YAZIO's
/// "My Goals" screen.
class KeyValueList extends StatelessWidget {
  final List<KeyValue> items;
  final EdgeInsetsGeometry padding;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  const KeyValueList({
    super.key,
    required this.items,
    this.padding = EdgeInsets.zero,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: it.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.label,
                        style: (labelStyle ?? textTheme.bodyMedium)?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        it.value,
                        style: (valueStyle ?? textTheme.bodyMedium)?.copyWith(
                          color: onSurfaceVar,
                        ),
                      ),
                      if (it.helper != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          it.helper!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: onSurfaceVar),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
