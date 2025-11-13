import 'package:flutter/material.dart';

class StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bg = color?.withOpacity(0.10) ?? colors.primary.withOpacity(0.08);
    final fg = color ?? colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(label, style: textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
