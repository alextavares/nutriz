import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../services/user_preferences.dart';
import '../../services/nutrition_storage.dart';
import '../../services/body_metrics_storage.dart';

import '../../widgets/profile_section.dart';
import '../../widgets/key_value_list.dart';
import '../../widgets/stat_pill.dart';

/// Cleaner profile screen inspired by YAZIO:
/// - Top card: identidade + stats principais
/// - Card de progresso: peso atual + previsão em semanas
/// - Card de metas: resumo e atalho para tela detalhada
/// - Ferramentas: link para backup/export/import.
class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2> {
  String _displayName = '';
  String _email = '';
  int _todayCalories = 0;
  int _calorieGoal = 2000;
  int _stepsToday = 0; // placeholder; integrar com tracker depois

  String _weightObjective = 'manter';
  double? _weightStart;
  double? _weightGoal;
  double? _weightCurrent;
  double? _weeklyDeltaKg; // meta semanal de peso (kg/sem)

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await UserPreferences.getGoals();
    final entries = await NutritionStorage.getEntriesForDate(DateTime.now());
    final metrics = await BodyMetricsStorage.getRecent(days: 60);

    final int kcal = entries.fold<int>(
      0,
      (sum, it) => sum + ((it['calories'] as num?)?.toInt() ?? 0),
    );

    final lastWeight = metrics
        .map((e) => e.$2['weightKg'] as num?)
        .where((w) => w != null)
        .cast<num>()
        .lastOrNull;

    final weightObjective = await UserPreferences.getWeightObjective();
    final weightStart = await UserPreferences.getWeightStartKg();
    final weightGoal = await UserPreferences.getWeightGoalKg();
    final weeklyDelta = await UserPreferences.getWeeklyWeightDeltaKg();

    setState(() {
      _displayName = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _calorieGoal = goals.totalCalories;
      _todayCalories = kcal;
      _weightObjective = weightObjective;
      _weightStart = weightStart;
      _weightGoal = weightGoal;
      _weightCurrent = lastWeight?.toDouble();
      _weeklyDeltaKg = weeklyDelta;
    });
  }

  double _progressToGoal() {
    final s = _weightStart;
    final g = _weightGoal;
    final c = _weightCurrent;
    if (s == null || g == null || c == null) return 0.0;
    final total = (s - g).abs();
    if (total <= 0) return 0.0;
    final covered = (s - c).abs();
    final pct = (covered / total).clamp(0.0, 1.0);
    return pct;
  }

  int? _weeksToGoal() {
    final current = _weightCurrent;
    final goal = _weightGoal;
    final weekly = _weeklyDeltaKg;
    if (current == null || goal == null || weekly == null || weekly == 0) {
      return null;
    }
    final remaining = goal - current;
    if (remaining == 0) return 0;
    if (remaining > 0 && weekly <= 0) return null;
    if (remaining < 0 && weekly >= 0) return null;
    final weeks = (remaining.abs() / weekly.abs()).ceil();
    if (weeks <= 0) return null;
    return weeks;
  }

  String _progressCaption() {
    final weeks = _weeksToGoal();
    if (_weightCurrent == null || _weightGoal == null || weeks == null) {
      return 'Defina objetivo de peso e meta semanal para ver previsão.';
    }
    if (weeks == 0) {
      return 'Você já está no seu objetivo de peso.';
    }
    if (weeks == 1) {
      return 'Em cerca de 1 semana você chega ao objetivo.';
    }
    return 'Em cerca de $weeks semanas você chega ao objetivo.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final calLeft = (_calorieGoal - _todayCalories).clamp(-9999, 99999);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identidade + stats rápidos
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            child: Text(
                              (_displayName.isNotEmpty
                                      ? _displayName[0]
                                      : (_email.isNotEmpty ? _email[0] : '?'))
                                  .toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayName.isNotEmpty
                                      ? _displayName
                                      : 'Usuário',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_email.isNotEmpty)
                                  Text(
                                    _email,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatPill(
                            icon: Icons.local_fire_department_outlined,
                            label: 'Calorias restantes',
                            value: calLeft.toString(),
                            color: colors.primary,
                          ),
                          if (_stepsToday > 0)
                            StatPill(
                              icon: Icons.directions_walk_outlined,
                              label: 'Passos',
                              value: _stepsToday.toString(),
                              color: colors.secondary,
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Progresso de peso
              ProfileSection(
                title: 'Meu Progresso',
                actionLabel: 'Análises',
                onAction: () {
                  Navigator.of(context).pushNamed(AppRoutes.progressOverview);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weightCurrent == null
                          ? 'Sem dados suficientes ainda'
                          : 'Peso atual: ${_weightCurrent!.toStringAsFixed(1)} kg',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _progressCaption(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressToGoal(),
                        minHeight: 8,
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _weightStart != null
                              ? '${_weightStart!.toStringAsFixed(1)} kg'
                              : '-',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _weightGoal != null
                              ? '${_weightGoal!.toStringAsFixed(1)} kg'
                              : '-',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Resumo das metas
              ProfileSection(
                title: 'Minhas Metas',
                actionLabel: 'Ver tudo',
                onAction: () {
                  Navigator.of(context).pushNamed(AppRoutes.goalsOverview);
                },
                child: Builder(builder: (context) {
                  final items = <KeyValue>[];
                  items.add(
                    KeyValue(
                      'Objetivo',
                      _weightObjective == 'perder'
                          ? 'Perder peso'
                          : _weightObjective == 'ganhar'
                              ? 'Ganhar peso'
                              : 'Manter peso',
                    ),
                  );
                  items.add(
                    KeyValue(
                      'Peso meta',
                      _weightGoal != null
                          ? '${_weightGoal!.toStringAsFixed(1)} kg'
                          : 'Definir',
                    ),
                  );
                  items.add(
                    KeyValue(
                      'Calorias diárias',
                      '$_calorieGoal kcal',
                    ),
                  );
                  return KeyValueList(items: items);
                }),
              ),

              const SizedBox(height: 8),

              // Ferramentas
              ProfileSection(
                title: 'Ferramentas',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.build_outlined),
                  title: const Text('Backup e ferramentas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.toolsBackup),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _IterableLastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}

