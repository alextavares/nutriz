import 'package:flutter/material.dart';

import '../../services/user_preferences.dart';
import '../../widgets/key_value_list.dart';
import '../../routes/app_routes.dart';

/// Overview of user goals, inspired by YAZIO's
/// "Meus objetivos" screen.
class GoalsOverviewScreen extends StatefulWidget {
  const GoalsOverviewScreen({super.key});

  @override
  State<GoalsOverviewScreen> createState() => _GoalsOverviewScreenState();
}

class _GoalsOverviewScreenState extends State<GoalsOverviewScreen> {
  String _objective = 'manter';
  double? _weightStart;
  double? _weightGoal;
  int _calorieGoal = 2000;
  String _diet = 'Padrão';
  String _activity = 'Moderado';
  double? _weeklyDeltaKg;
  int _stepsGoal = 10000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals = await UserPreferences.getGoals();
    final obj = await UserPreferences.getWeightObjective();
    final ws = await UserPreferences.getWeightStartKg();
    final wg = await UserPreferences.getWeightGoalKg();
    final diet = await UserPreferences.getDietType();
    final activity = await UserPreferences.getActivityLevel();
    final weeklyDelta = await UserPreferences.getWeeklyWeightDeltaKg();
    final stepsGoal = await UserPreferences.getDailyStepsGoal();

    setState(() {
      _calorieGoal = goals.totalCalories;
      _objective = obj;
      _weightStart = ws;
      _weightGoal = wg;
      _diet = _prettyDiet(diet);
      _activity = activity;
      _weeklyDeltaKg = weeklyDelta;
      _stepsGoal = stepsGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus objetivos'),
        actions: [
          TextButton(
            onPressed: _openEditSheet,
            child: const Text('Editar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          KeyValueList(
            labelStyle: textTheme.titleMedium,
            valueStyle: textTheme.bodyMedium,
            items: [
              KeyValue(
                'Objetivo',
                _labelForObjective(_objective),
                onTap: _editObjective,
              ),
              KeyValue(
                'Peso inicial',
                _fmtWeight(_weightStart),
                onTap: () => _editWeight(isStart: true),
              ),
              KeyValue(
                'Objetivo de peso',
                _fmtWeight(_weightGoal),
                onTap: () => _editWeight(isStart: false),
              ),
              KeyValue(
                'Nível de atividade',
                _activity,
                onTap: _openEditSheet,
              ),
              KeyValue(
                'Objetivo semanal',
                _fmtWeeklyDelta(_weeklyDeltaKg),
                onTap: _openEditSheet,
              ),
              KeyValue(
                'Objetivo calórico',
                '${_calorieGoal} kcal',
                onTap: _editCalorieGoal,
              ),
              KeyValue(
                'Passos',
                _fmtInt(_stepsGoal),
                onTap: _openEditSheet,
              ),
              KeyValue(
                'Objetivos nutricionais',
                _diet,
                onTap: _editDiet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelForObjective(String v) {
    switch (v) {
      case 'perder':
        return 'Perder peso';
      case 'ganhar':
        return 'Ganhar peso';
      default:
        return 'Manter peso';
    }
  }

  String _fmtWeight(double? kg) {
    if (kg == null) return '-';
    return '${kg.toStringAsFixed(1)} kg';
  }

  String _fmtWeeklyDelta(double? kg) {
    if (kg == null || kg == 0) return '-';
    final sign = kg > 0 ? '+' : '';
    return '$sign${kg.toStringAsFixed(1)} kg/sem';
  }

  String _fmtInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write('.');
      }
    }
    return buf.toString();
  }

  String _prettyDiet(String raw) {
    if (raw.startsWith('Padr')) return 'Padrão';
    return raw;
  }

  Future<void> _editObjective() async {
    const options = ['perder', 'manter', 'ganhar'];
    String selected = _objective;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Objetivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (o) => RadioListTile<String>(
                    title: Text(_labelForObjective(o)),
                    value: o,
                    groupValue: selected,
                    onChanged: (v) {
                      if (v == null) return;
                      selected = v;
                      Navigator.of(ctx).pop();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (!mounted || selected == _objective) return;
    await UserPreferences.setWeightObjective(selected);
    await _load();
  }

  Future<void> _editWeight({required bool isStart}) async {
    final current = isStart ? _weightStart : _weightGoal;
    final controller = TextEditingController(
      text: current?.toStringAsFixed(1) ?? '',
    );
    final title = isStart ? 'Peso inicial (kg)' : 'Objetivo de peso (kg)';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'ex.: 70.0'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final raw = controller.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (isStart) {
      await UserPreferences.setWeightStartKg(value);
    } else {
      await UserPreferences.setWeightGoalKg(value);
    }
    await _load();
  }

  Future<void> _editCalorieGoal() async {
    final goals = await UserPreferences.getGoals();
    final controller =
        TextEditingController(text: goals.totalCalories.toString());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Objetivo calórico (kcal/dia)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '2000'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final total = int.tryParse(controller.text.trim()) ?? goals.totalCalories;
    await UserPreferences.setGoals(
      totalCalories: total,
      carbs: goals.carbs,
      proteins: goals.proteins,
      fats: goals.fats,
    );
    await _load();
  }

  Future<void> _editDiet() async {
    final options = <String>[
      'Padrão',
      'Vegetariana',
      'Vegana',
      'Low carb',
      'Keto',
    ];
    String selected = _diet;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Objetivos nutricionais'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (o) => RadioListTile<String>(
                    title: Text(o),
                    value: o,
                    groupValue: selected,
                    onChanged: (v) {
                      if (v == null) return;
                      selected = v;
                      Navigator.of(ctx).pop();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (!mounted || selected == _diet) return;
    await UserPreferences.setDietType(selected);
    await _load();
  }

  void _openEditSheet() {
    final outerContext = context;
    final activityOptions = <String>['Leve', 'Moderado', 'Intenso'];
    String selectedActivity =
        activityOptions.contains(_activity) ? _activity : 'Moderado';
    final weeklyController = TextEditingController(
      text: _weeklyDeltaKg?.toStringAsFixed(1) ?? '',
    );
    final stepsController = TextEditingController(text: _stepsGoal.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar objetivos',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nível de atividade',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                StatefulBuilder(
                  builder: (ctx, setState) {
                    return DropdownButton<String>(
                      value: selectedActivity,
                      isExpanded: true,
                      items: activityOptions
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          selectedActivity = v;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Objetivo semanal (kg/sem)',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: weeklyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '-0.5 (perder) ou 0.5 (ganhar)',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Meta diária de passos',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: stepsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '10000'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(outerContext)
                            .pushNamed(AppRoutes.goalsWizard);
                      },
                      child: const Text('Editar calorias e macros'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final weeklyRaw =
                            weeklyController.text.trim().replaceAll(',', '.');
                        final weekly = double.tryParse(
                            weeklyRaw.isEmpty ? '0' : weeklyRaw);
                        final steps =
                            int.tryParse(stepsController.text.trim()) ?? 10000;

                        await UserPreferences.setActivityLevel(
                            selectedActivity);
                        await UserPreferences.setWeeklyWeightDeltaKg(
                            weekly == 0 ? null : weekly);
                        await UserPreferences.setDailyStepsGoal(
                            steps < 0 ? 0 : steps);

                        if (!mounted) return;
                        Navigator.of(sheetContext).pop();
                        await _load();
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text('Objetivos atualizados'),
                          ),
                        );
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

