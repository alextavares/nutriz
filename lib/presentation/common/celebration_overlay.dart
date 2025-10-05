import 'dart:async';
import 'dart:math';
import '../../services/user_preferences.dart';
import '../../theme/design_tokens.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';

/// Lightweight confetti overlay used for quick celebrations.
enum CelebrationVariant { goal, milestone, achievement }

class CelebrationOverlay extends StatefulWidget {
  final Duration duration;
  const CelebrationOverlay(
      {super.key, this.duration = const Duration(milliseconds: 1200)});

  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;
  static bool _listening = false;

  static void _ensureListening() {
    if (_listening) return;
    _listening = true;
    UserPreferences.changes.addListener(() async {
      final reduce = await UserPreferences.getReduceAnimations();
      final enabled = await UserPreferences.getEnableMilestoneCelebration();
      if (reduce || !enabled) {
        cancelActive();
      }
    });
  }

  static void cancelActive() {
    try {
      _activeTimer?.cancel();
      _activeTimer = null;
    } catch (_) {}
    try {
      _activeEntry?.remove();
    } catch (_) {}
    _activeEntry = null;
  }

  static Future<void> show(BuildContext context,
      {Duration duration = const Duration(milliseconds: 1200)}) async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => CelebrationOverlay(duration: duration),
    );
    _ensureListening();
    // Remove any existing entry before adding a new one
    cancelActive();
    overlay.insert(entry);
    _activeEntry = entry;
    _activeTimer = Timer(duration, () {
      try {
        entry.remove();
      } catch (_) {}
      if (identical(_activeEntry, entry)) {
        _activeEntry = null;
      }
      _activeTimer = null;
    });
  }

  static Duration _durationFor(CelebrationVariant variant) {
    switch (variant) {
      case CelebrationVariant.goal:
        return const Duration(milliseconds: 1200);
      case CelebrationVariant.milestone:
        return const Duration(milliseconds: 1600);
      case CelebrationVariant.achievement:
        return const Duration(milliseconds: 2000);
    }
  }

  static Future<void> maybeShow(
    BuildContext context, {
    Duration? duration,
    CelebrationVariant variant = CelebrationVariant.goal,
  }) async {
    final reduce = await UserPreferences.getReduceAnimations();
    final enabled = await UserPreferences.getEnableMilestoneCelebration();
    if (reduce || !enabled) return; // honor user preference
    final d = duration ?? _durationFor(variant);
    await show(context, duration: d);
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    // Auto dispose after
    Timer(widget.duration, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: FutureBuilder<bool>(
        future: _shouldUseLottie(),
        builder: (context, snap) {
          final useLottie = (snap.data ?? false);
          if (useLottie) {
            // Try to render Lottie; fall back if asset unavailable
            return _LottieCelebration(duration: widget.duration);
          }
          // Lightweight confetti painter fallback
          final palette = _confettiPalette(context);
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  progress: _ctrl.value,
                  palette: palette,
                ),
                child: Container(color: Colors.transparent),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _shouldUseLottie() async {
    try {
      final pref = await UserPreferences.getUseLottieCelebrations();
      if (!pref) return false;
      // Soft check: ensure asset exists before opting-in
      // We don't throw if missing; we just skip to fallback
      final bytes = await rootBundle.load('assets/celebration.json');
      return bytes.lengthInBytes > 24; // arbitrary sanity
    } catch (_) {
      return false;
    }
  }
}

class _LottieCelebration extends StatefulWidget {
  final Duration duration;
  const _LottieCelebration({required this.duration});

  @override
  State<_LottieCelebration> createState() => _LottieCelebrationState();
}

class _LottieCelebrationState extends State<_LottieCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // Local controller used only for the error fallback painter below
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in SizedBox.expand to cover area; IgnorePointer handled by parent
    return SizedBox.expand(
      child: Center(
        child: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            final minSide = min(size.width, size.height);
            final dim = min(max(minSide * 0.40, 160.0), 300.0);
            return LottieBuilder.asset(
              'assets/celebration.json',
              width: dim,
              height: dim,
              fit: BoxFit.contain,
              repeat: false,
              // If Lottie fails to parse/load, gracefully fall back to confetti
              errorBuilder: (context, error, stackTrace) {
                final palette = _confettiPalette(context);
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _ctrl.value,
                      palette: palette,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
              onLoaded: (comp) async {
                // Keep overlay roughly aligned with composition duration
                // comp.duration is a Duration; clamp between 600ms and 1200ms
                final ms = comp.duration.inMilliseconds;
                final clampedMs = ms < 600 ? 600 : (ms > 1200 ? 1200 : ms);
                await Future<void>.delayed(Duration(milliseconds: clampedMs));
                if (mounted) CelebrationOverlay.cancelActive();
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress; // 0..1
  final List<Color> palette;
  _ConfettiPainter({required this.progress, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final count = 36; // small for perf
    for (int i = 0; i < count; i++) {
      final seed = i * 9973;
      final t = progress;
      final baseX = (seed % size.width).toDouble();
      final baseY = (seed % 40).toDouble();
      final fall =
          Curves.easeOut.transform(t) * (size.height * 0.7 + (seed % 60));
      final dx = sin((seed % 360) * pi / 180 + t * 8.0) * 12.0;
      final pos = Offset(baseX + dx, baseY + fall);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = palette[seed % palette.length].withValues(alpha: 1 - t * 0.2);
      final w = 6.0 + (seed % 6);
      final h = 4.0 + (seed % 4);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate((seed % 360) * pi / 180 + t * 6.0);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(-w / 2, -h / 2, w, h), const Radius.circular(2)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

List<Color> _confettiPalette(BuildContext context) {
  final colors = context.colors;
  final semantic = context.semanticColors;
  return <Color>[
    colors.primary,
    semantic.success,
    semantic.warning,
    semantic.premium,
    colors.secondary,
  ];
}
