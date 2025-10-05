import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';

class ExerciseLoggingScreen extends StatefulWidget {
  const ExerciseLoggingScreen({super.key});

  @override
  State<ExerciseLoggingScreen> createState() => _ExerciseLoggingScreenState();
}

class _ExerciseLoggingScreenState extends State<ExerciseLoggingScreen> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _weightCtl = TextEditingController(text: '70');
  DateTime _targetDate = DateTime.now();
  bool _openedPreset = false;

  final List<_Activity> _all = [
    _Activity('Caminhada', 3.5, MdiIcons.walk),
    _Activity('Corrida', 9.0, MdiIcons.run),
    _Activity('Ciclismo', 7.5, MdiIcons.bike),
    _Activity('Natação', 8.0, MdiIcons.swim),
    _Activity('Musculação', 6.0, MdiIcons.dumbbell),
    _Activity('Yoga', 3.0, MdiIcons.yoga),
    _Activity('Pilates', 3.5, MdiIcons.yoga),
    _Activity('HIIT', 10.0, MdiIcons.lightningBolt),
    _Activity('Trilha', 6.5, MdiIcons.hiking),
    _Activity('Basquete', 7.0, MdiIcons.basketball),
    _Activity('Futebol', 8.0, MdiIcons.soccer),
    _Activity('Dança', 6.0, MdiIcons.music),
    _Activity('Pular corda', 11.0, MdiIcons.jumpRope),
    _Activity('Remo', 7.0, MdiIcons.rowing),
    _Activity('Escada/Step', 8.5, MdiIcons.stairs),
    _Activity('Elíptico', 7.0, MdiIcons.ellipseOutline),
    _Activity('Vôlei', 3.8, MdiIcons.volleyball),
    _Activity('Lutas/Boxe', 9.0, MdiIcons.boxingGlove),
    _Activity('Ginástica', 6.0, MdiIcons.human),
    _Activity('Caminhada Leve', 2.8, MdiIcons.walk),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final dateStr = args['date'] as String?;
      if (dateStr != null) {
        final d = DateTime.tryParse(dateStr);
        if (d != null) _targetDate = DateTime(d.year, d.month, d.day);
      }
      // Optional preset: open editor directly
      if (!_openedPreset) {
        final name = args['activityName'] as String?;
        if (name != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final match = _all.firstWhere(
              (a) => a.name.toLowerCase() == name.toLowerCase(),
              orElse: () => _all.first,
            );
            _openedPreset = true;
            _openActivity(match);
          });
        }
      }
    }
  }

  List<_Activity> get _filtered {
    final t = _search.text.trim().toLowerCase();
    if (t.isEmpty) return _all;
    return _all
        .where((a) => a.name.toLowerCase().contains(t))
        .toList(growable: false);
  }

  void _openActivity(_Activity a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use themed elevated surface for YAZIO-like sheet appearance
      backgroundColor:
          Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ActivityEditor(
        activity: a,
        initialWeight: double.tryParse(_weightCtl.text) ?? 70,
        onSaved: (kcal, meta) async {
          await NutritionStorage.addExerciseCalories(_targetDate, kcal);
          await NutritionStorage.setExerciseMeta(_targetDate, meta);
          await NutritionStorage.addExerciseLog(_targetDate, meta);
          if (!mounted) return;
          Navigator.pop(ctx); // close sheet
          Navigator.pop(context, true); // back to dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exercício registrado: +$kcal kcal'),
              backgroundColor: context.semanticColors.success,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Atividades'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: SizedBox(
              width: 28.w,
              child: TextField(
                controller: _weightCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Buscar atividade',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 1.2.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final a = _filtered[i];
                  return Material(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openActivity(a),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: context.semanticColors.success
                                  .withValues(alpha: 0.12),
                              child: Icon(a.icon,
                                  color: context.semanticColors.success, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                a.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Activity {
  final String name;
  final double met; // metabolic equivalent
  final IconData icon;
  const _Activity(this.name, this.met, this.icon);
}

class _ActivityEditor extends StatefulWidget {
  final _Activity activity;
  final double initialWeight;
  final void Function(int kcal, Map<String, dynamic> meta) onSaved;

  const _ActivityEditor({
    required this.activity,
    required this.initialWeight,
    required this.onSaved,
  });

  @override
  State<_ActivityEditor> createState() => _ActivityEditorState();
}

class _ActivityEditorState extends State<_ActivityEditor> {
  double minutes = 30;
  int intensity = 1; // 0=leve,1=moderado,2=intenso
  late TextEditingController weightCtl;

  @override
  void initState() {
    super.initState();
    weightCtl =
        TextEditingController(text: widget.initialWeight.toStringAsFixed(0));
  }

  double _met() {
    // scale MET by intensity
    final base = widget.activity.met;
    switch (intensity) {
      case 0:
        return base * 0.8;
      case 2:
        return base * 1.2;
      default:
        return base;
    }
  }

  int _estimateKcal() {
    final w = double.tryParse(weightCtl.text.trim()) ?? 70.0;
    final h = (minutes / 60.0);
    final kcal = _met() * w * h;
    return kcal.round();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final kcal = _estimateKcal();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 1.2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 1.2.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      context.semanticColors.success.withValues(alpha: 0.12),
                  child: Icon(widget.activity.icon,
                      color: context.semanticColors.success, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.activity.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            Text('Duração: ${minutes.round()} min'),
            Slider(
              value: minutes,
              min: 5,
              max: 180,
              divisions: 35,
              label: '${minutes.round()} min',
              onChanged: (v) => setState(() => minutes = v),
            ),
            SizedBox(height: 0.6.h),
            Text('Intensidade'),
            const SizedBox(height: 6),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Leve')),
                ButtonSegment(value: 1, label: Text('Moderado')),
                ButtonSegment(value: 2, label: Text('Intenso')),
              ],
              selected: {intensity},
              onSelectionChanged: (s) => setState(() => intensity = s.first),
              showSelectedIcon: false,
              multiSelectionEnabled: false,
            ),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 3.w),
                Chip(
                  label: Text('~ $kcal kcal'),
                  avatar: const Icon(Icons.local_fire_department, size: 16),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final meta = {
                    'name': widget.activity.name,
                    'minutes': minutes.round(),
                    'intensity': intensity,
                    'weightKg': double.tryParse(weightCtl.text.trim()) ??
                        widget.initialWeight,
                    'kcal': kcal,
                    'savedAt': DateTime.now().toIso8601String(),
                  };
                  widget.onSaved(kcal, meta);
                },
                icon: const Icon(Icons.add),
                label: const Text('Salvar exercício'),
                // Rely on theme’s ElevatedButtonTheme (mapped to preset)
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
