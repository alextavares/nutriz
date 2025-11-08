import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../theme/app_colors.dart';
import '../../common/celebration_overlay.dart';
import '../../../core/haptic_helper.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Modern water tracker card adapted from the provided HTML.
/// Self‑contained visuals + simple callbacks to mutate the day total.
class WaterTrackerCardV2 extends StatefulWidget {
  final int currentMl;
  final int goalMl;
  final Future<int> Function(int delta) onChange; // returns new total after applying delta
  final VoidCallback? onEditGoal;
  final int foodWaterMl;

  const WaterTrackerCardV2({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.onChange,
    this.onEditGoal,
    this.foodWaterMl = 0,
  });

  @override
  State<WaterTrackerCardV2> createState() => _WaterTrackerCardV2State();
}

class _WaterTrackerCardV2State extends State<WaterTrackerCardV2>
    with TickerProviderStateMixin {
  late int _current;
  // Track which cup indices recently filled for a quick "cheers" bounce.
  final Set<int> _cheers = <int>{};
  // Transient falling drops
  final List<_Drop> _drops = [];

  @override
  void initState() {
    super.initState();
    _current = widget.currentMl.clamp(0, widget.goalMl);
  }

  @override
  void didUpdateWidget(covariant WaterTrackerCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMl != widget.currentMl ||
        oldWidget.goalMl != widget.goalMl) {
      setState(() {
        _current = widget.currentMl.clamp(0, widget.goalMl);
      });
    }
  }

  int get _goal => widget.goalMl <= 0 ? 2000 : widget.goalMl;
  double get _pct => _goal == 0 ? 0 : (_current / _goal).clamp(0.0, 1.0);
  String get _pctText => '${(_pct * 100).round()}%';
  String get _remainingText => _mlToLiters((_goal - _current).clamp(0, _goal));

  static String _mlToLiters(int ml) {
    return (ml / 1000).toStringAsFixed(2) + ' L';
  }

  Future<void> _applyDelta(int delta) async {
    if (delta == 0) return;
    final before = _current;
    final after = await widget.onChange(delta);
    if (!mounted) return;
    _animateCupCheers(before, after);
    _spawnDrop();
    // Trigger confetti when crossing the goal threshold
    final int goal = _goal;
    if (before < goal && after >= goal) {
      // Best-effort; overlay respects user reduce-animations preference
      // ignore: unawaited_futures
      CelebrationOverlay.maybeShow(context, variant: CelebrationVariant.goal);
      // Subtle medium haptic to reinforce the achievement
      // ignore: unawaited_futures
      HapticHelper.medium();
    }
    setState(() => _current = after.clamp(0, _goal));
  }

  void _animateCupCheers(int beforeMl, int afterMl) {
    final totalCups = max(1, (_goal / 250).round());
    final filledBefore = ((beforeMl / _goal) * totalCups).clamp(0, totalCups).floor();
    final filledAfter = ((afterMl / _goal) * totalCups).clamp(0, totalCups).floor();
    if (filledAfter <= filledBefore) return;
    for (int i = filledBefore; i < filledAfter; i++) {
      _cheers.add(i);
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _cheers.remove(i));
      });
    }
  }

  void _spawnDrop() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final anim = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    final d = _Drop(x: 0.1 + Random().nextDouble() * 0.8, anim: anim);
    setState(() => _drops.add(d));
    controller.forward().whenComplete(() {
      controller.dispose();
      if (mounted) setState(() => _drops.remove(d));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEEF7FF), Color(0xFFE8F3FF)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: const Color(0xFFD7E8FF)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(47, 125, 255, 0.12),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.06),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9ECFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text('💧', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.water,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: widget.onEditGoal,
                    child: Text(
                      '${AppLocalizations.of(context)!.waterGoal}: ${(_goal / 1000).toStringAsFixed(2)} L',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Current amount (animated)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _current.toDouble()),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, v, _) {
                    return RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: (v / 1000).toStringAsFixed(2),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.5),
                        ),
                        TextSpan(
                          text: ' L ',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        TextSpan(text: AppLocalizations.of(context)!.waterToday, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 6),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFEEFF),
                  ),
                  child: Stack(children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFDFEEFF),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _pct,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2F7DFF), Color(0xFF63B3FF)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_pctText,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text('${AppLocalizations.of(context)!.waterRemaining} $_remainingText',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: 12),

  // Cups grid
              _CupsGrid(
                currentMl: _current,
                goalMl: _goal,
                cheers: _cheers,
                onCupTap: (isFilled, index) async {
                  // Haptic feedback
                  await HapticHelper.light();

                  if (isFilled) {
                    // Remove 250 mL ao tocar em copo cheio
                    final remove = min(250, _current);
                    if (remove > 0) _applyDelta(-remove);
                  } else {
                    // Adiciona 250 mL ao tocar em copo vazio
                    final add = min(250, (_goal - _current).clamp(0, _goal));
                    if (add > 0) _applyDelta(add);
                  }
                },
              ),

              const SizedBox(height: 4),

              // Actions
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _actionButton(context, label: AppLocalizations.of(context)!.waterAdd100, onTap: () async {
                    await HapticHelper.light();
                    _applyDelta(100);
                  }),
                  _actionButton(context, label: AppLocalizations.of(context)!.waterAdd200, onTap: () async {
                    await HapticHelper.light();
                    _applyDelta(200);
                  }),
                  _actionButton(context, label: AppLocalizations.of(context)!.waterCustom, onTap: () async {
                    await HapticHelper.light();
                    final amount = await _askMl(context);
                    if (amount != null && amount > 0) {
                      _applyDelta(amount);
                    }
                  }),
                  _actionButton(context, label: AppLocalizations.of(context)!.waterReset, onTap: () async {
                    await HapticHelper.light();
                    _applyDelta(-_current);
                  }),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppLocalizations.of(context)!.waterFromFood}: ${widget.foodWaterMl} mL',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text(_motivationText(context),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.waterTipTap,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),

        // Falling drops overlay
        ..._drops.map((d) => Positioned.fill(
              child: AnimatedBuilder(
                animation: d.anim,
                builder: (context, _) {
                  final t = d.anim.value;
                  return IgnorePointer(
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                          (d.x * MediaQuery.of(context).size.width) - 12,
                          -30 + t * 140,
                        ),
                        child: const Text('💧', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  String _motivationText(BuildContext context) {
    final p = _pct * 100;
    if (p == 0) return AppLocalizations.of(context)!.waterMotivation0;
    if (p < 30) return AppLocalizations.of(context)!.waterMotivation30;
    if (p < 70) return AppLocalizations.of(context)!.waterMotivation70;
    if (p < 100) return AppLocalizations.of(context)!.waterMotivation100Less;
    return AppLocalizations.of(context)!.waterMotivation100;
  }

  Future<int?> _askMl(BuildContext context) async {
    final ctl = TextEditingController(text: '250');
    final r = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.waterAddWater),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'mL (ex.: 250)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.waterCancel)),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctl.text.trim());
              Navigator.pop(ctx, v);
            },
            child: Text(AppLocalizations.of(context)!.waterAdd),
          ),
        ],
      ),
    );
    return r;
  }

  Widget _actionButton(BuildContext context,
      {required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFD9E8FF)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _primaryButton(BuildContext context,
      {required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CupsGrid extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final Set<int> cheers;
  final void Function(bool isFilled, int index) onCupTap;

  const _CupsGrid({
    required this.currentMl,
    required this.goalMl,
    required this.cheers,
    required this.onCupTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = max(1, (goalMl / 250).round());
    final filled = ((currentMl / goalMl) * total).clamp(0, total).floor();

    return GridView.builder(
      itemCount: total,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final isFilled = i < filled;
        final bounce = cheers.contains(i) ? 1.15 : 1.0;
        return AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          scale: bounce,
          child: _Cup(
            isFilled: isFilled,
            onTap: () => onCupTap(isFilled, i),
          ),
        );
      },
    );
  }
}

class _Cup extends StatelessWidget {
  final bool isFilled;
  final VoidCallback onTap;
  const _Cup({required this.isFilled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isFilled ? '- 250 mL' : '+ 250 mL',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFilled
                        ? const Color(0xFF7DB8FF)
                        : const Color(0xFFB6D3FF),
                    width: 1.5,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  height: isFilled ? double.infinity : 0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF7DB8FF), Color(0xFF2F7DFF)],
                    ),
                  ),
                ),
              ),
              // Minimal cup glyph on top for clarity
              Center(
                child: Icon(
                  Icons.local_drink,
                  size: 22,
                  color: isFilled
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF6AA8FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Drop {
  final double x; // 0..1
  final Animation<double> anim;
  const _Drop({required this.x, required this.anim});
}
