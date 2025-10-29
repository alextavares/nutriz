import 'package:flutter/material.dart';
import '../components/achievement_toast.dart';

class ToastManager {
  static OverlayEntry? _current;

  static void showAchievement({
    required BuildContext context,
    required String title,
    required String message,
    required String emoji,
  }) {
    _current?.remove();
    _current = OverlayEntry(
      builder: (context) => AchievementToast(
        title: title,
        message: message,
        emoji: emoji,
        onClose: () {
          _current?.remove();
          _current = null;
        },
      ),
    );
    Overlay.of(context).insert(_current!);
  }
}

