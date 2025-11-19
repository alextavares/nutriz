import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';
import '../../common/celebration_overlay.dart';
import '../../../core/haptic_helper.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Water tracker card with a cleaner, YAZIO‑like visual.
///
/// Keeps the same public API as the previous V2 implementation:
///  - [currentMl]: current water for the day
///  - [goalMl]: daily goal in mL
///  - [onChange]: callback to mutate the storage and return the new total
///  - [onEditGoal]: optional handler to edit the water goal
///  - [foodWaterMl]: water coming from food (shown in caption)
class WaterTrackerCardV2 extends StatefulWidget {
  final int currentMl;
  final int goalMl;
  final Future<int> Function(int delta) onChange;
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

class _WaterTrackerCardV2State extends State<WaterTrackerCardV2> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.currentMl.clamp(0, _goal);
  }

  @override
  void didUpdateWidget(covariant WaterTrackerCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMl != widget.currentMl ||
        oldWidget.goalMl != widget.goalMl) {
      _current = widget.currentMl.clamp(0, _goal);
    }
  }

  int get _goal => widget.goalMl <= 0 ? 2000 : widget.goalMl;

  double get _pct =>
      _goal == 0 ? 0 : (_current / _goal.toDouble()).clamp(0.0, 1.0);

  String get _pctText => '${(_pct * 100).round()}%';

  String get _remainingLiters {
    final remaining = (_goal - _current).clamp(0, _goal);
    final l = remaining / 1000;
    return '${l.toStringAsFixed(2)} L';
  }

  Future<void> _applyDelta(int delta) async {
    if (delta == 0) return;
    final before = _current;
    final after = await widget.onChange(delta);
    if (!mounted) return;

    final clampedAfter = after.clamp(0, _goal);

    // Simple goal‑crossing celebration, kept from original card.
    if (before < _goal && clampedAfter >= _goal) {
      // ignore: unawaited_futures
      CelebrationOverlay.maybeShow(context, variant: CelebrationVariant.goal);
      // ignore: unawaited_futures
      HapticHelper.medium();
    }

    setState(() => _current = clampedAfter);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: const Color(0xFFD7E8FF)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 8,
            offset: Offset(0, 4),
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
                    child: const Icon(
                      Icons.water_drop,
                      size: 18,
                      color: Color(0xFF2F7DFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.water,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              if (widget.onEditGoal != null)
                InkWell(
                  onTap: widget.onEditGoal,
                  child: Text(
                    '${t.waterGoal}: ${(_goal / 1000).toStringAsFixed(2)} L',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.primary,
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
              duration: const Duration(milliseconds: 300),
              builder: (context, v, _) {
                final liters = (v / 1000).toStringAsFixed(2);
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: liters,
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' L ',
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: t.waterToday,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE3EEFF),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _pct,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF2F7DFF),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Percent + remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _pctText,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${t.remaining}: $_remainingLiters',
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WaterChip(
                label: '+100 mL',
                onTap: () => _applyDelta(100),
              ),
              _WaterChip(
                label: '+200 mL',
                onTap: () => _applyDelta(200),
              ),
              _WaterChip(
                label: 'Custom',
                onTap: () => _showCustomDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Caption
          Text(
            '${t.waterFromFood}: ${widget.foodWaterMl} mL · ${t.remaining}: $_remainingLiters',
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Adicionar água (mL)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'ex.: 250'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final v = int.tryParse(controller.text.trim()) ?? 0;
      if (v > 0) {
        unawaited(_applyDelta(v));
      }
    }
  }
}

class _WaterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD0DFF5)),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
