import 'package:flutter/material.dart';

class SoftButton extends StatelessWidget {
  final String label;
  final String? iconText; // e.g., '+', '🎯', '⚙️'
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconText,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.borderRadius = 10,
  });

  static const _bg = Color(0xFFE8EEFF);
  static const _bgHover = Color(0xFFD5E1FF);
  static const _bgActive = Color(0xFFC5D5FF);
  static const _bgDisabled = Color(0xFFF0F0F0);
  static const _fg = Color(0xFF5B7FFF);
  static const _fgDisabled = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: _bg,
      foregroundColor: _fg,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return _bgDisabled;
        if (states.contains(WidgetState.pressed)) return _bgActive;
        if (states.contains(WidgetState.hovered)) return _bgHover;
        return _bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return _fgDisabled;
        return _fg;
      }),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconText != null) ...[
            Text(iconText!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
    );
  }
}

class SoftButtonCompact extends StatelessWidget {
  final String iconText;
  final VoidCallback onPressed;
  final double size;
  const SoftButtonCompact({super.key, required this.iconText, required this.onPressed, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SoftButton(
      label: '',
      onPressed: onPressed,
      iconText: iconText,
      padding: EdgeInsets.zero,
      borderRadius: 10,
    );
  }
}

