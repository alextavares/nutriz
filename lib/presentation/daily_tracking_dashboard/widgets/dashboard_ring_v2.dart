import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Design tokens per spec (scoped to widget to avoid global theme changes)
// Softer ring color as requested
const Color _kPrimaryPurple = Color(0xFF7B61FF);
const Color _kPrimaryDeepPurple = Color(0xFF7B61FF);
const Color _kBackgroundDark = Color(0xFFE2E8F0); // ring track
const Color _kTextPrimary = Color(0xFF2D3748);
const Color _kTextSecondary = Color(0xFF718096);
const Color _kTextTertiary = Color(0xFFA0AEC0);

const double _kRingThickness = 18.0;

class DashboardRingV2 extends StatelessWidget {
  final int consumedCalories;
  final int spentCalories;
  final int totalCalories;
  final VoidCallback? onTap; // breakdown handler

  const DashboardRingV2({
    super.key,
    required this.consumedCalories,
    required this.spentCalories,
    required this.totalCalories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_RingState>(
      create: (_) => _RingState(
        consumed: consumedCalories,
        burned: spentCalories,
        goal: totalCalories,
      ),
      child: _DashboardRingBody(
        onTap: onTap,
        consumed: consumedCalories,
        burned: spentCalories,
        goal: totalCalories,
      ),
    );
  }
}

class _DashboardRingBody extends StatefulWidget {
  final VoidCallback? onTap;
  final int consumed;
  final int burned;
  final int goal;
  const _DashboardRingBody({this.onTap, required this.consumed, required this.burned, required this.goal});

  @override
  State<_DashboardRingBody> createState() => _DashboardRingBodyState();
}

class _DashboardRingBodyState extends State<_DashboardRingBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    final s = context.read<_RingState>();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _ctrl.forward();
      s.addListener(_onStateChange);
    });
  }

  void _onStateChange() {
    if (!mounted) return;
    // Restart animation after current frame to avoid relayout during layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _ctrl.forward(from: 0);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    context.read<_RingState>().removeListener(_onStateChange);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DashboardRingBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final st = context.read<_RingState>();
    if (oldWidget.consumed != widget.consumed ||
        oldWidget.burned != widget.burned ||
        oldWidget.goal != widget.goal) {
      // Post-frame to avoid notifying listeners during layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          st.update(widget.consumed, widget.burned, widget.goal);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<_RingState>();
    final double progress = state.progress; // 0..1

    // Responsive ring size
    final width = MediaQuery.of(context).size.width;
    final double size = width < 480 ? 240 : (width < 600 ? 260 : 280);

    final gradient = const LinearGradient(
      colors: [_kPrimaryPurple, _kPrimaryDeepPurple],
    );

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Reduced side padding to use more horizontal space on phones
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header removed (already present at top app bar)

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(value: state.consumed.toString(), label: 'Consumido'),
                _Stat(value: state.burned.toString(), label: 'Queimado'),
              ],
            ),

            _buildRing(context, baseSize: size, progress: progress,
                gradient: gradient, remaining: state.remainingClamped,
                onTap: widget.onTap),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(
    BuildContext context, {
    required double baseSize,
    required double progress,
    required Gradient gradient,
    required int remaining,
    VoidCallback? onTap,
  }) {
    final double maxW = MediaQuery.of(context).size.width - 32;
    double ringSize = min(baseSize, maxW);
    if (ringSize < 200) ringSize = 200;
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 32),
      width: ringSize,
      height: ringSize,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glow
          Container(
            width: ringSize - 20,
            height: ringSize - 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _kPrimaryPurple.withOpacity(0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          // background
          CustomPaint(
            size: Size(ringSize, ringSize),
            painter:
                _RingBackgroundPainter(strokeWidth: _kRingThickness, color: _kBackgroundDark),
          ),
          // progress
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return CustomPaint(
                size: Size(ringSize, ringSize),
                painter: _RingProgressPainter(
                  strokeWidth: _kRingThickness,
                  progress: progress * _anim.value,
                  gradient: gradient,
                ),
              );
            },
          ),
          // Center labels
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (r) => gradient.createShader(Rect.fromLTWH(0, 0, r.width, 70)),
                child: Text(
                  remaining.toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: width < 480 ? 48 : 56,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Restante',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(100 * (1 - progress)).round()}% do dia',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kTextTertiary,
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _RingState extends ChangeNotifier {
  int consumed;
  int burned;
  int goal;
  _RingState({required this.consumed, required this.burned, required this.goal});

  double get progress {
    if (goal <= 0) return 0.0;
    return ((consumed - burned) / goal).clamp(0.0, 1.0);
  }

  int get remainingClamped {
    final r = goal - consumed + burned;
    return max(0, r);
  }

  void update(int consumedCalories, int spentCalories, int total) {
    consumed = consumedCalories;
    burned = spentCalories;
    goal = total;
    notifyListeners();
  }
}

class _RingBackgroundPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  _RingBackgroundPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingBackgroundPainter oldDelegate) => false;
}

class _RingProgressPainter extends CustomPainter {
  final double strokeWidth;
  final double progress; // 0..1
  final Gradient gradient;
  _RingProgressPainter({
    required this.strokeWidth,
    required this.progress,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -pi / 2; // top
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
