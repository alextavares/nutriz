import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

/// Representa um log de exercício
class ExerciseLog {
  final String name;
  final int kcal;
  final int minutes;
  final DateTime? savedAt;

  const ExerciseLog({
    required this.name,
    required this.kcal,
    required this.minutes,
    this.savedAt,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      name: (map['name'] as String?) ?? '-',
      kcal: (map['kcal'] as num?)?.toInt() ?? 0,
      minutes: (map['minutes'] as num?)?.toInt() ?? 0,
      savedAt: DateTime.tryParse((map['savedAt'] as String?) ?? ''),
    );
  }
}

/// Card de atividades físicas - extraído do DailyTrackingDashboard
class ActivitiesCard extends StatefulWidget {
  final int spentCalories;
  final int goalCalories;
  final int exerciseStreak;
  final List<ExerciseLog> exerciseLogs;
  final ExerciseLog? lastExercise;
  final VoidCallback onAddExercise;
  final void Function(int currentGoal) onEditGoal;
  final void Function(String activityName, int minutes, int intensity) onQuickActivity;

  const ActivitiesCard({
    super.key,
    required this.spentCalories,
    required this.goalCalories,
    this.exerciseStreak = 0,
    this.exerciseLogs = const [],
    this.lastExercise,
    required this.onAddExercise,
    required this.onEditGoal,
    required this.onQuickActivity,
  });

  @override
  State<ActivitiesCard> createState() => _ActivitiesCardState();
}

class _ActivitiesCardState extends State<ActivitiesCard> {
  bool _expanded = false;

  // Animation constants
  static const _kAnimDuration = Duration(milliseconds: 900);
  static const _kAnimCurve = Curves.easeOutCubic;
  static const _kDelayLeft = 0.15;
  static const _kDelayCenter = 0.25;

  String _fmtInt(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spent = widget.spentCalories;
    final goal = widget.goalCalories;
    final ratio = goal > 0 ? (spent / goal).clamp(0.0, 1.0) : 0.0;
    final remain = (goal - spent).clamp(0, goal);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.10),
            cs.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: 6,
            top: 6,
            child: Icon(
              Icons.local_fire_department,
              size: 42,
              color: context.semanticColors.success.withValues(alpha: 0.18),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.semanticColors.success.withValues(alpha: 0.15),
                child: Icon(
                  Icons.local_fire_department,
                  color: context.semanticColors.success,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(cs),
                    const SizedBox(height: 2),
                    _buildProgress(cs, spent, goal, ratio, remain),
                  ],
                ),
              ),
              _buildAddButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Atividades',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (widget.exerciseStreak > 0) _buildStreakChip(),
      ],
    );
  }

  Widget _buildStreakChip() {
    final w = MediaQuery.of(context).size.width;
    final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
    final double padH = w < 360 ? 6 : 8;
    final double padV = w < 360 ? 2 : 3;
    final successColor = context.semanticColors.success;

    return Chip(
      label: Text('Streak: ${widget.exerciseStreak}d'),
      visualDensity: VisualDensity.compact,
      backgroundColor: successColor.withValues(alpha: 0.12),
      side: BorderSide(color: successColor.withValues(alpha: 0.3)),
      labelPadding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: successColor,
            fontWeight: FontWeight.w700,
            fontSize: fs,
          ),
    );
  }


  Widget _buildProgress(ColorScheme cs, int spent, int goal, double ratio, int remain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calories row
        Row(
          children: [
            _buildAnimatedCalories(spent, goal),
            const SizedBox(width: 8),
            if (remain > 0) _buildAnimatedRemaining(remain, cs),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Editar meta',
              icon: Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
              onPressed: () => widget.onEditGoal(goal),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        _buildProgressBar(cs, ratio),
        const SizedBox(height: 8),
        // Last exercise
        if (widget.lastExercise != null) _buildLastExercise(cs),
        // Exercise logs
        if (widget.exerciseLogs.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildExerciseLogs(cs),
        ],
        const SizedBox(height: 8),
        // Quick activity chips
        _buildQuickActivityChips(),
      ],
    );
  }

  Widget _buildAnimatedCalories(int spent, int goal) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(spent),
      tween: Tween(begin: 0.0, end: spent.toDouble()),
      duration: _kAnimDuration,
      curve: Curves.linear,
      builder: (context, v, _) {
        if (spent <= 0) {
          return Text(
            '${_fmtInt(0)}/${_fmtInt(goal)} kcal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w700,
                ),
          );
        }
        final p = (v / spent).clamp(0.0, 1.0);
        final delayed = p <= _kDelayLeft ? 0.0 : (p - _kDelayLeft) / (1.0 - _kDelayLeft);
        final eased = _kAnimCurve.transform(delayed);
        final shown = (spent * eased).toInt();
        return Text(
          '${_fmtInt(shown)}/${_fmtInt(goal)} kcal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.successGreen,
                fontWeight: FontWeight.w700,
              ),
        );
      },
    );
  }

  Widget _buildAnimatedRemaining(int remain, ColorScheme cs) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(remain),
      tween: Tween(begin: 0.0, end: remain.toDouble()),
      duration: _kAnimDuration,
      curve: Curves.linear,
      builder: (context, v, _) {
        final p = (v / remain).clamp(0.0, 1.0);
        final delayed = p <= _kDelayCenter ? 0.0 : (p - _kDelayCenter) / (1.0 - _kDelayCenter);
        final eased = _kAnimCurve.transform(delayed);
        final shown = (remain * eased).toInt();
        return Text(
          'Faltam ${_fmtInt(shown)} kcal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        );
      },
    );
  }

  Widget _buildProgressBar(ColorScheme cs, double ratio) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(ratio),
        tween: Tween<double>(begin: 0, end: ratio),
        duration: _kAnimDuration,
        curve: Curves.linear,
        builder: (context, val, _) {
          if (ratio <= 0) {
            return LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
              color: AppTheme.successGreen,
            );
          }
          final p = (val / ratio).clamp(0.0, 1.0);
          final eased = _kAnimCurve.transform(p);
          return LinearProgressIndicator(
            value: eased * ratio,
            minHeight: 4,
            backgroundColor: cs.outlineVariant.withValues(alpha: 0.20),
            color: AppTheme.successGreen,
          );
        },
      ),
    );
  }

  Widget _buildLastExercise(ColorScheme cs) {
    final last = widget.lastExercise!;
    final dt = last.savedAt ?? DateTime.now();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    return Row(
      children: [
        Icon(Icons.fitness_center, size: 16, color: context.semanticColors.success),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Último: ${last.name} · +${last.kcal} kcal'
            '${last.minutes > 0 ? ' · ${last.minutes} min' : ''}'
            ' · $hh:$mm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  Widget _buildExerciseLogs(ColorScheme cs) {
    final logsToShow = _expanded ? widget.exerciseLogs : widget.exerciseLogs.take(2).toList();

    return Column(
      children: [
        ...logsToShow.map((log) => _buildLogRow(log, cs)),
        if (widget.exerciseLogs.length > 2)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Builder(builder: (context) {
                final extra = widget.exerciseLogs.length - 2;
                return Text(_expanded
                    ? 'Mostrar menos'
                    : (extra > 0 ? 'Ver todos (+$extra)' : 'Ver todos'));
              }),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLogRow(ExerciseLog log, ColorScheme cs) {
    final dt = log.savedAt ?? DateTime.now();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    return Row(
      children: [
        Icon(
          Icons.watch_later_outlined,
          size: 14,
          color: context.semanticColors.success,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${log.name}: +${log.kcal} kcal · ${log.minutes} min · $hh:$mm',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActivityChips() {
    final w = MediaQuery.of(context).size.width;
    final double space = w < 360 ? 6.0 : 8.0;
    final double rspace = w < 360 ? 4.0 : 6.0;

    return Wrap(
      spacing: space,
      runSpacing: rspace,
      children: [
        _quickActivityChip('Caminhada 30m', () {
          widget.onQuickActivity('Caminhada', 30, 1);
        }),
        _quickActivityChip('Corrida 20m', () {
          widget.onQuickActivity('Corrida', 20, 2);
        }),
        _quickActivityChip('Bike 30m', () {
          widget.onQuickActivity('Ciclismo', 30, 1);
        }),
      ],
    );
  }

  Widget _quickActivityChip(String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
    final double padH = w < 360 ? 8 : 12;
    final double padV = w < 360 ? 4 : 6;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: fs,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: AppTheme.activeBlue,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onAddExercise,
          child: const Icon(Icons.add, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}
