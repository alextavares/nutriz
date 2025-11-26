import 'package:flutter/material.dart';
import '../app_export.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? size;
  final Color? color;

  const AddButton({
    super.key,
    required this.onPressed,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? AppDimensions.addButtonSize;
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: color ?? AppColorsDS.addButtonBackground,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          AppIcons.add,
          color: Colors.white,
          size: buttonSize * 0.6,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

