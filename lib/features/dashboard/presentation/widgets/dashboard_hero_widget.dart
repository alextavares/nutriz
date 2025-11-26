import 'package:flutter/material.dart';
import '../../../../theme/design_tokens.dart';
import '../../../../presentation/nutrition_details_screen/nutrition_details_screen.dart';

class DashboardHeroWidget extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesGoal;
  final int caloriesBurned;
  final int carbsConsumed;
  final int carbsGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int fatConsumed;
  final int fatGoal;
  final bool isFasting;
  final bool isEatingWindow;
  final String? fastingStatus;
  final Duration? fastingElapsed;
  final Duration? fastingGoal;
  final VoidCallback? onFastingTap;
  final VoidCallback? onCardTap;

  const DashboardHeroWidget({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    this.caloriesBurned = 0,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.fatConsumed,
    required this.fatGoal,
    this.isFasting = false,
    this.isEatingWindow = false,
    this.fastingStatus,
    this.fastingElapsed,
    this.fastingGoal,
    this.onFastingTap,
    this.onCardTap,
  });

  // Cores dos macros (estilo Yazio)
  static const Color _carbsColor = Color(0xFFFFB74D);  // Laranja
  static const Color _proteinColor = Color(0xFF81C784); // Verde
  static const Color _fatColor = Color(0xFFE57373);     // Vermelho

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final remaining = caloriesGoal - caloriesConsumed + caloriesBurned;
    final progress = caloriesGoal > 0 
        ? (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0) 
        : 0.0;

    final progressTrackColor = isDark 
        ? colors.surfaceContainerHighest 
        : const Color(0xFFE8E8E8);
    
    final progressColor = remaining < 0 
        ? colors.error
        : colors.primary;

    final showFastingBanner = isFasting || isEatingWindow;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: isDark ? null : const [AppShadows.card],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Conteúdo principal - Clicável
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openNutritionDetails(context),
              borderRadius: showFastingBanner 
                  ? const BorderRadius.vertical(top: Radius.circular(AppRadii.lg))
                  : BorderRadius.circular(AppRadii.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Linha principal: Comido - Círculo - Queimado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Comido
                        _buildSideStat(
                          context: context,
                          value: caloriesConsumed,
                          label: 'Comido',
                        ),
                        
                        // Círculo central
                        _buildCaloriesCircle(
                          context: context,
                          remaining: remaining,
                          progress: progress,
                          progressColor: progressColor,
                          trackColor: progressTrackColor,
                        ),
                        
                        // Queimado
                        _buildSideStat(
                          context: context,
                          value: caloriesBurned,
                          label: 'Queimado',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Macros com barras de progresso (estilo Yazio)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroBar(
                            context: context,
                            label: 'Carbs',
                            current: carbsConsumed,
                            goal: carbsGoal,
                            color: _carbsColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildMacroBar(
                            context: context,
                            label: 'Proteína',
                            current: proteinConsumed,
                            goal: proteinGoal,
                            color: _proteinColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildMacroBar(
                            context: context,
                            label: 'Gordura',
                            current: fatConsumed,
                            goal: fatGoal,
                            color: _fatColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Banner de Jejum
          if (showFastingBanner) _buildFastingBanner(context),
        ],
      ),
    );
  }

  void _openNutritionDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionDetailsScreen(
          caloriesConsumed: caloriesConsumed,
          caloriesGoal: caloriesGoal,
          carbsConsumed: carbsConsumed,
          carbsGoal: carbsGoal,
          proteinConsumed: proteinConsumed,
          proteinGoal: proteinGoal,
          fatConsumed: fatConsumed,
          fatGoal: fatGoal,
        ),
      ),
    );
  }

  Widget _buildCaloriesCircle({
    required BuildContext context,
    required int remaining,
    required double progress,
    required Color progressColor,
    required Color trackColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track (fundo)
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(trackColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progresso
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Texto central
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remaining',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Restantes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideStat({
    required BuildContext context,
    required int value,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBar({
    required BuildContext context,
    required String label,
    required int current,
    required int goal,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final trackColor = isDark 
        ? colors.surfaceContainerHighest 
        : const Color(0xFFEEEEEE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label e valores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              '$current/${goal}g',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barra de progresso
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFastingBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color bannerBg;
    final String emoji;
    final String statusText;
    
    if (isEatingWindow) {
      bannerBg = isDark ? const Color(0xFF880E4F) : const Color(0xFFE91E63);
      emoji = '🍎';
      statusText = fastingStatus ?? 'Janela Alimentar';
    } else {
      bannerBg = isDark ? const Color(0xFF1A237E) : const Color(0xFF5C6BC0);
      emoji = '🕐';
      statusText = fastingStatus ?? 'Jejum';
    }
    
    String timeText = '';
    if (fastingElapsed != null) {
      final hours = fastingElapsed!.inHours;
      final minutes = fastingElapsed!.inMinutes % 60;
      timeText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFastingTap,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppRadii.lg),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Agora: $statusText',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (timeText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
