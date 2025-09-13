import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/user_preferences.dart';
import '../../services/achievement_service.dart';
import '../../services/streak_service.dart';
import '../../services/streak_recalculator.dart';
import '../../services/nutrition_storage.dart';
import '../../services/body_metrics_storage.dart';
import '../common/celebration_overlay.dart';
import '../../services/weekly_goal_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  bool _isPremium = false;
  String _tab = 'me'; // 'me' | 'friends'
  bool _uiPrefsExpanded = false;
  final _calController = TextEditingController();
  final _carbController = TextEditingController();
  final _protController = TextEditingController();
  final _fatController = TextEditingController();
  final _waterGoalController = TextEditingController(text: '2000');
  bool _hydrationEnabled = false;
  final _hydrationIntervalController = TextEditingController(text: '60');
  // Meal goals controllers
  final Map<String, TextEditingController> _mealKcal = {
    'breakfast': TextEditingController(),
    'lunch': TextEditingController(),
    'dinner': TextEditingController(),
    'snack': TextEditingController(),
  };
  final Map<String, TextEditingController> _mealCarb = {
    'breakfast': TextEditingController(),
    'lunch': TextEditingController(),
    'dinner': TextEditingController(),
    'snack': TextEditingController(),
  };
  final Map<String, TextEditingController> _mealProt = {
    'breakfast': TextEditingController(),
    'lunch': TextEditingController(),
    'dinner': TextEditingController(),
    'snack': TextEditingController(),
  };
  final Map<String, TextEditingController> _mealFat = {
    'breakfast': TextEditingController(),
    'lunch': TextEditingController(),
    'dinner': TextEditingController(),
    'snack': TextEditingController(),
  };
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _uiPrefsKey = GlobalKey();
  // Objectives/diet
  String _dietType = 'Padrão';
  String _weightObjective = 'ganhar'; // ganhar|perder|manter
  double? _weightStart;
  double? _weightGoal;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['scrollTo'] == 'ui_prefs') {
        if (_uiPrefsKey.currentContext != null) {
          Scrollable.ensureVisible(
            _uiPrefsKey.currentContext!,
            duration: const Duration(milliseconds: 400),
            alignment: 0.1,
          );
        }
      }
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('user_email') ?? 'usuário@nutritracker.com';
      _isPremium = prefs.getBool('premium_status') ?? false;
    });
    final goals = await UserPreferences.getGoals();
    if (!mounted) return;
    setState(() {
      _calController.text = goals.totalCalories.toString();
      _carbController.text = goals.carbs.toString();
      _protController.text = goals.proteins.toString();
      _fatController.text = goals.fats.toString();
      _waterGoalController.text = goals.waterGoalMl.toString();
    });
    final hyd = await UserPreferences.getHydrationReminder();
    if (!mounted) return;
    setState(() {
      _hydrationEnabled = hyd.enabled;
      _hydrationIntervalController.text = hyd.intervalMinutes.toString();
    });
    final mealGoals = await UserPreferences.getMealGoals();
    if (!mounted) return;
    setState(() {
      for (final key in mealGoals.keys) {
        final g = mealGoals[key]!;
        _mealKcal[key]!.text = g.kcal.toString();
        _mealCarb[key]!.text = g.carbs.toString();
        _mealProt[key]!.text = g.proteins.toString();
        _mealFat[key]!.text = g.fats.toString();
      }
    });
    // objectives/diet
    _dietType = await UserPreferences.getDietType();
    _weightObjective = await UserPreferences.getWeightObjective();
    _weightStart = await UserPreferences.getWeightStartKg();
    _weightGoal = await UserPreferences.getWeightGoalKg();
    // expanded state for advanced block
    _uiPrefsExpanded = await UserPreferences.getUiPrefsExpanded();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('user_email');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.goalsWizard);
              if (mounted) {
                await _loadProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Metas atualizadas'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            icon: const Icon(Icons.flag),
            label: const Text('Configurar metas'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.activeBlue),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs EU | AMIGOS
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'me', label: Text('EU')),
                                ButtonSegment(value: 'friends', label: Text('AMIGOS')),
                              ],
                              selected: {_tab},
                              onSelectionChanged: (s) => setState(() => _tab = s.first),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.2.h),

                      if (_tab == 'me') ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 8.w,
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                (_email ?? 'U').substring(0, 1).toUpperCase(),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _email ?? '-',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: _isPremium ? 'star' : 'person',
                                        color: _isPremium
                                            ? AppTheme.premiumGold
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 5.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        _isPremium ? 'Assinatura PRO' : 'Plano Gratuito',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      _buildMyProgressCard(),
                      SizedBox(height: 2.h),
                      _buildMyObjectivesCard(),
                      SizedBox(height: 3.h),
                      Text(
                        'Metas Diárias',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      _buildGoalsForm(),
                      SizedBox(height: 3.h),
                      _buildHydrationReminderSection(),
                      SizedBox(height: 3.h),
                      _buildPerMealGoalsSection(),
                      SizedBox(height: 3.h),
                      _buildBackupSection(),
                      SizedBox(height: 3.h),
                      KeyedSubtree(
                          key: _uiPrefsKey,
                          child: _buildUiPreferencesSection()),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed: _confirmLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'logout',
                              color: AppTheme.textPrimary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            const Text('Sair'),
                          ],
                        ),
                      ),
                      ] else ...[
                        _buildFriendsPlaceholder(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final controller = TextEditingController();
    bool valid = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text(
              'Sair da conta?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você precisará fazer login novamente. Para confirmar, digite: SAIR',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (v) => setState(() => valid = v.trim().toUpperCase() == 'SAIR'),
                  decoration: const InputDecoration(hintText: 'SAIR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: !valid ? null : () async {
                  Navigator.pop(context);
                  await _logout();
                },
                child: const Text('Sair'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildFriendsPlaceholder() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 2.2.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.activeBlue.withValues(alpha: 0.12),
            child: const Icon(Icons.group_outlined, color: AppTheme.activeBlue, size: 18),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amigos', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text('Conecte-se com amigos para comparar progresso. Em breve.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyProgressCard() {
    return FutureBuilder<List<(DateTime, Map<String, dynamic>)>>(
      future: BodyMetricsStorage.getRecent(days: 90),
      builder: (context, snap) {
        final cs = Theme.of(context).colorScheme;
        final data = snap.data ?? const [];
        double? current;
        double? first;
        for (final e in data) {
          final w = (e.$2['weightKg'] as num?)?.toDouble();
          if (w != null) {
            first ??= w;
            current = w; // last valid becomes current
          }
        }
        final start = _weightStart ?? first;
        final goal = _weightGoal;
        final delta = (current != null && start != null) ? (current - start) : null;
        // progress ratio 0..1 depending on objective direction
        double progress = 0;
        if (current != null && start != null && goal != null && goal != start) {
          if (goal > start) {
            progress = ((current - start) / (goal - start)).clamp(0, 1).toDouble();
          } else {
            progress = ((start - current) / (start - goal)).clamp(0, 1).toDouble();
          }
        }
        // choose bar color based on direction
        Color barColor = AppTheme.activeBlue;
        if (start != null && goal != null) {
          barColor = goal > start
              ? AppTheme.successGreen
              : (goal < start ? AppTheme.errorRed : AppTheme.activeBlue);
        }
        final bool reached = (current != null && goal != null)
            ? (current - goal).abs() < 0.2
            : false;
        // show bar only when we have meaningful range
        final bool showBar =
            current != null && start != null && goal != null && (goal - start).abs() >= 0.5;

        // Estimate weeks to goal using simple linear trend (first vs last point)
        double? weeks;
        if (goal != null && current != null) {
          final pts = <(DateTime, double)>[];
          for (final e in data) {
            final w = (e.$2['weightKg'] as num?)?.toDouble();
            if (w != null) pts.add((e.$1, w));
          }
          if (pts.length >= 2) {
            final firstPt = pts.first;
            final lastPt = pts.last;
            final days = lastPt.$1.difference(firstPt.$1).inDays;
            if (days > 0) {
              final slopePerDay = (lastPt.$2 - firstPt.$2) / days;
              final need = (goal - current).abs();
              final dirOk = (goal > current && slopePerDay > 0) ||
                  (goal < current && slopePerDay < 0);
              if (dirOk && slopePerDay.abs() > 0.0001) {
                weeks = (need / slopePerDay.abs()) / 7.0;
              }
            }
          }
        }

        String subtitle;
        if (reached && showBar) {
          subtitle = 'Meta atingida!';
        } else if (delta != null) {
          final abs = delta.abs();
          if (abs < 0.1) {
            subtitle = 'Sem variação ainda';
          } else {
            final base = delta >= 0
                ? 'Você ganhou ${abs.toStringAsFixed(1)} kg'
                : 'Você perdeu ${abs.toStringAsFixed(1)} kg';
            if (weeks != null && weeks.isFinite) {
              final w = weeks < 1 ? '<1' : weeks.round().toString();
              subtitle = '$base • ~${w} sem. para a meta';
            } else {
              subtitle = '$base';
            }
          }
        } else {
          subtitle = 'Defina sua meta de peso para acompanhar a barra';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('Meu progresso',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                )),
                        if (reached) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle,
                              color: AppTheme.successGreen, size: 18),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bodyMetrics);
                    },
                    child: const Text('ANÁLISE'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bodyMetrics, arguments: {
                        'openEditor': true,
                      });
                    },
                    child: const Text('REGISTRAR PESO'),
                  ),
                  if (!showBar) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _openObjectivesEditor,
                      child: const Text('DEFINIR META'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
              if (showBar) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: reached
                        ? 1.0
                        : (progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0),
                    backgroundColor:
                        cs.outlineVariant.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(start != null ? '${start.toStringAsFixed(1)} kg' : '--',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    Text(current != null ? '${current.toStringAsFixed(1)} kg' : '--',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    Text(goal != null ? '${goal.toStringAsFixed(1)} kg' : '--',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyObjectivesCard() {
    final cs = Theme.of(context).colorScheme;
    String objLabel = _weightObjective == 'perder'
        ? 'Perder peso'
        : (_weightObjective == 'manter' ? 'Manter peso' : 'Ganhar peso');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Meus objetivos', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.w600,
                )),
              ),
              TextButton(
                onPressed: _openObjectivesEditor,
                child: const Text('EDITAR'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: Text('Alimentação: $_dietType', style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: Text('Objetivo: $objLabel', style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openObjectivesEditor() async {
    final dietOptions = ['Padrão', 'Vegetariana', 'Vegana', 'Low carb', 'Keto'];
    final cs = Theme.of(context).colorScheme;
    final startCtrl = TextEditingController(text: _weightStart?.toStringAsFixed(1) ?? '');
    final goalCtrl = TextEditingController(text: _weightGoal?.toStringAsFixed(1) ?? '');
    String selDiet = _dietType;
    String selObj = _weightObjective;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 2.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 2.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editar objetivos', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('Alimentação', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: selDiet,
                  items: dietOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => selDiet = v ?? selDiet),
                ),
                const SizedBox(height: 12),
                Text('Objetivo de peso', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'perder', label: Text('Perder')),
                    ButtonSegment(value: 'manter', label: Text('Manter')),
                    ButtonSegment(value: 'ganhar', label: Text('Ganhar')),
                  ],
                  selected: {selObj},
                  onSelectionChanged: (s) => selObj = s.first,
                ),
                const SizedBox(height: 12),
                Text('Peso inicial (kg)', style: Theme.of(context).textTheme.bodySmall),
                TextField(
                  controller: startCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'ex.: 70.0'),
                ),
                const SizedBox(height: 12),
                Text('Meta de peso (kg)', style: Theme.of(context).textTheme.bodySmall),
                TextField(
                  controller: goalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'ex.: 71.0'),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await UserPreferences.setDietType(selDiet);
                      await UserPreferences.setWeightObjective(selObj);
                      final s = double.tryParse(startCtrl.text.trim().replaceAll(',', '.'));
                      final g = double.tryParse(goalCtrl.text.trim().replaceAll(',', '.'));
                      await UserPreferences.setWeightStartKg(s);
                      await UserPreferences.setWeightGoalKg(g);
                      if (!mounted) return;
                      setState(() {
                        _dietType = selDiet;
                        _weightObjective = selObj;
                        _weightStart = s;
                        _weightGoal = g;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Objetivos atualizados'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsForm() {
  return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
    ),
      child: Column(
        children: [
          _rowField('Calorias (kcal)', _calController),
          SizedBox(height: 1.h),
          _rowField('Carboidratos (g)', _carbController),
          SizedBox(height: 1.h),
          _rowField('Proteínas (g)', _protController),
          SizedBox(height: 1.h),
          _rowField('Gorduras (g)', _fatController),
          SizedBox(height: 1.h),
          _rowField(
            'Água (ml)',
            _waterGoalController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: 1.5.h),
          Align(
            alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final total = int.tryParse(_calController.text.trim()) ?? 2000;
                  final carbs = int.tryParse(_carbController.text.trim()) ?? 250;
                  final prots = int.tryParse(_protController.text.trim()) ?? 120;
                  final fats = int.tryParse(_fatController.text.trim()) ?? 80;
                  await UserPreferences.setGoals(
                    totalCalories: total,
                    carbs: carbs,
                    proteins: prots,
                    fats: fats,
                  );
                  await UserPreferences.setWaterGoal(
                      int.tryParse(_waterGoalController.text.trim()) ?? 2000);
                  if (!mounted) return;
                  // Notificar o dashboard para recarregar metas
                  try {
                    NutritionStorage.changes.value =
                        NutritionStorage.changes.value + 1;
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metas atualizadas'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text('Salvar metas'),
              ),
            ),
        ],
      ),
    );
  });
  }

  Widget _buildHydrationReminderSection() {
  return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lembretes de Hidratação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ativar lembretes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              Switch(
                value: _hydrationEnabled,
                onChanged: (v) async {
                  setState(() => _hydrationEnabled = v);
                  await UserPreferences.setHydrationReminder(
                    enabled: v,
                    intervalMinutes: int.tryParse(
                            _hydrationIntervalController.text.trim()) ??
                        60,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Intervalo (minutos)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 28.w,
                child: TextField(
                  controller: _hydrationIntervalController,
                  keyboardType: TextInputType.number,
                  enabled: _hydrationEnabled,
                  decoration: const InputDecoration(hintText: '60'),
                  onChanged: (val) async {
                    final minutes = int.tryParse(val.trim()) ?? 60;
                    await UserPreferences.setHydrationReminder(
                      enabled: _hydrationEnabled,
                      intervalMinutes: minutes,
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  });
  }

  Widget _rowField(String label, TextEditingController controller,
      {List<TextInputFormatter>? inputFormatters}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        SizedBox(
          width: 28.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(
              hintText: '0',
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBackupSection() {
  return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup do Diário',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportDiary,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Exportar JSON'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importDiary,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Importar JSON'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Templates (Dia/Semana)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportTemplates,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Exportar JSON'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importTemplates,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Importar JSON'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _confirmClearTemplates,
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Limpar templates'),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Alimentos (Favoritos / Meus)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportFoods,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Exportar JSON'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importFoods,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Importar JSON'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _confirmClearFoods,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Limpar alimentos'),
            ),
          ),
        ],
      ),
    );
  });
  }

  Widget _buildUiPreferencesSection() {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preferências de UI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                tooltip: _uiPrefsExpanded ? 'Recolher' : 'Expandir',
                onPressed: () async {
                  final next = !_uiPrefsExpanded;
                  setState(() => _uiPrefsExpanded = next);
                  await UserPreferences.setUiPrefsExpanded(next);
                },
                icon: Icon(_uiPrefsExpanded ? Icons.expand_less : Icons.expand_more),
              )
            ],
          ),
          if (!_uiPrefsExpanded) ...[
            const SizedBox(height: 4),
            Text(
              'Exportar/Importar • Chips rápidos • Destaque “novo”',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ] else ...[
            SizedBox(height: 1.h),
            _buildAICacheRow(),
            SizedBox(height: 1.2.h),
            _buildQuickPortionRow(),
            SizedBox(height: 0.8.h),
            _buildPerMealQuickPortionRow(),
            SizedBox(height: 1.2.h),
            FutureBuilder<bool>(
              future: UserPreferences.getReduceAnimations(),
              builder: (context, snap) {
                final value = snap.data ?? false;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduzir animações'),
                  subtitle: const Text('Evita confetes/transições exageradas'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setReduceAnimations(v);
                    if (v) {
                      // If animations reduced, cancel any active celebration overlay immediately
                      try { CelebrationOverlay.cancelActive(); } catch (_) {}
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Animações reduzidas'),
                            backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.3),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Animações normais'),
                            backgroundColor: AppTheme.successGreen,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(height: 0.8.h),
            FutureBuilder<bool>(
              future: UserPreferences.getEnableMilestoneCelebration(),
              builder: (context, snap) {
                final value = snap.data ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Celebrar conquistas'),
                  subtitle: const Text('Mostra confete ao desbloquear badges'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setEnableMilestoneCelebration(v);
                    if (!v) {
                      // Immediately stop any active overlay if celebrations disabled
                      try { CelebrationOverlay.cancelActive(); } catch (_) {}
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Celebrações desativadas'),
                            backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.3),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Celebrações ativadas'),
                            backgroundColor: AppTheme.successGreen,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(height: 0.8.h),
            FutureBuilder<bool>(
              future: UserPreferences.getShowNextMilestoneCaptions(),
              builder: (context, snap) {
                final value = snap.data ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exibir “Próximo marco” nos chips'),
                  subtitle: const Text('Mostra “• próx: Nd” nos chips de streak'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setShowNextMilestoneCaptions(v);
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(height: 0.8.h),
            FutureBuilder<bool>(
              future: UserPreferences.getUseLottieCelebrations(),
              builder: (context, snap) {
                final value = snap.data ?? false;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usar Lottie nas celebrações'),
                  subtitle: const Text('Animações Lottie quando disponível (fallback para confete)'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setUseLottieCelebrations(v);
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(height: 0.8.h),

            // Search & food preferences
            Text('Busca e alimentos', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            FutureBuilder<bool>(
              future: UserPreferences.getUseNlq(),
              builder: (context, snap) {
                final value = snap.data ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Interpretar quantidades no texto (NLQ)'),
                  subtitle: const Text('Ex.: "150g frango", "2 ovos e 1 banana"'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setUseNlq(v);
                    if (!mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(v ? 'NLQ ativado por padrão' : 'NLQ desativado por padrão'),
                        backgroundColor: v ? AppTheme.successGreen : AppTheme.textSecondary.withValues(alpha: 0.3),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
            FutureBuilder<bool>(
              future: UserPreferences.getShowSourceBadges(),
              builder: (context, snap) {
                final value = snap.data ?? true;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostrar fonte dos dados (OFF/FDC/NLQ)'),
                  value: value,
                  onChanged: (v) async {
                    await UserPreferences.setShowSourceBadges(v);
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            // QA helpers (local only)
            Text('QA / Depuração', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await AchievementService.clearAll();
                  await StreakService.clearAll();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Conquistas e streaks limpos'), backgroundColor: AppTheme.activeBlue),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpar conquistas/streaks'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await AchievementService.add({
                    'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
                    'type': 'star',
                    'title': 'Badge de Teste',
                    'dateIso': DateTime.now().toIso8601String(),
                    'metaKey': 'test',
                    'value': 1,
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Badge de teste concedido'), backgroundColor: AppTheme.successGreen),
                  );
                },
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Conceder badge de teste'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await StreakRecalculator.recalcAllOverDays(days: 60);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Streaks recalculados (últimos 60 dias)'), backgroundColor: AppTheme.successGreen),
                  );
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Recalcular streaks (60 dias)'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await WeeklyGoalService.clearLastPerfectWeek();
                  final created = await WeeklyGoalService.evaluatePerfectCaloriesWeek();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(created ? 'Semana perfeita reavaliada e concedida' : 'Semana perfeita reavaliada (sem mudança)'),
                      backgroundColor: created ? AppTheme.successGreen : AppTheme.activeBlue,
                    ),
                  );
                },
                icon: const Icon(Icons.checklist_rtl),
                label: const Text('Recalcular semana perfeita'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await CelebrationOverlay.maybeShow(context, variant: CelebrationVariant.achievement);
                },
                icon: const Icon(Icons.celebration_outlined),
                label: const Text('Testar celebração'),
              ),
            ]),
            SizedBox(height: 1.2.h),
            FutureBuilder<int>(
              future: UserPreferences.getNewBadgeMinutes(),
              builder: (context, snap) {
                final current = snap.data ?? 5;
                controller.text = current.toString();
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Duração do destaque “novo” (minutos)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 28.w,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '5'),
                        onSubmitted: (val) async {
                          final m = int.tryParse(val.trim()) ?? 5;
                          await UserPreferences.setNewBadgeMinutes(m.clamp(1, 60));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Preferência salva'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAICacheRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cache de IA (normalização de alimentos)',
            style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 0.8.h),
        FutureBuilder<Map<String, dynamic>>(
          future: _loadAICacheStats(),
          builder: (context, snap) {
            final count = (snap.data?['count'] as int?) ?? 0;
            final ts = (snap.data?['ts'] as int?) ?? 0;
            return Text(
              'Itens no cache: $count • Atualizado: ${_formatTs(ts)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            );
          },
        ),
        SizedBox(height: 0.8.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportAICache,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar JSON'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _importAICache,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Importar JSON'),
              ),
            ),
            SizedBox(width: 2.w),
            IconButton(
              onPressed: _clearAICache,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Limpar cache de IA',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPortionRow() {
    final controller = TextEditingController();
    return FutureBuilder<List<double>>(
      future: UserPreferences.getQuickPortionGrams(),
      builder: (context, snap) {
        final current = snap.data ?? [50, 100, 150, 200, 250];
        controller.text = current.map((e) => e.toInt()).join(',');
        return Row(
          children: [
            Expanded(
              child: Text(
                'Chips de porção rápida (g, separados por vírgula)',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 40.w,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration:
                    const InputDecoration(hintText: '50,100,150,200,250'),
                onSubmitted: (val) async {
                  final parts = val.split(',');
                  final list = <double>[];
                  for (final p in parts) {
                    final v = double.tryParse(p.trim());
                    if (v != null && v > 0) list.add(v);
                  }
                  await UserPreferences.setQuickPortionGrams(
                      list.isEmpty ? [50, 100, 150, 200, 250] : list);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Chips atualizados'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerMealQuickPortionRow() {
    final bCtrl = TextEditingController();
    final lCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    final sCtrl = TextEditingController();
    return FutureBuilder<Map<String, List<double>>>(
      future: () async {
        final b =
            await UserPreferences.getQuickPortionGramsForMeal('breakfast');
        final l = await UserPreferences.getQuickPortionGramsForMeal('lunch');
        final d = await UserPreferences.getQuickPortionGramsForMeal('dinner');
        final s = await UserPreferences.getQuickPortionGramsForMeal('snack');
        return {'breakfast': b, 'lunch': l, 'dinner': d, 'snack': s};
      }(),
      builder: (context, snap) {
        final data = snap.data;
        bCtrl.text = (data?['breakfast'] ?? [50, 100, 150, 200])
            .map((e) => e.toInt())
            .join(',');
        lCtrl.text = (data?['lunch'] ?? [50, 100, 150, 200])
            .map((e) => e.toInt())
            .join(',');
        dCtrl.text = (data?['dinner'] ?? [50, 100, 150, 200])
            .map((e) => e.toInt())
            .join(',');
        sCtrl.text = (data?['snack'] ?? [50, 100, 150, 200])
            .map((e) => e.toInt())
            .join(',');

        Widget field(String label, TextEditingController c, String meal) {
          return Padding(
            padding: EdgeInsets.only(bottom: 0.8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28.w,
                  child: TextField(
                    controller: c,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(hintText: '50,100,200'),
                    onSubmitted: (val) async {
                      final parts = val.split(',');
                      final list = <double>[];
                      for (final p in parts) {
                        final v = double.tryParse(p.trim());
                        if (v != null && v > 0) list.add(v);
                      }
                      await UserPreferences.setQuickPortionGramsForMeal(
                        meal,
                        list.isEmpty ? [50, 100, 150, 200] : list,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Chips atualizados'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chips por refeição (g)',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              field('Café da manhã', bCtrl, 'breakfast'),
              field('Almoço', lCtrl, 'lunch'),
              field('Jantar', dCtrl, 'dinner'),
              field('Lanches', sCtrl, 'snack'),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadAICacheStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('food_normalizer_cache_v1');
    if (raw == null) {
      return {'count': 0, 'ts': 0};
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final items = (data['items'] as Map?)?.length ?? 0;
      final ts = (data['ts'] as int?) ?? 0;
      return {'count': items, 'ts': ts};
    } catch (_) {
      return {'count': 0, 'ts': 0};
    }
  }

  String _formatTs(int ts) {
    if (ts <= 0) return '-';
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _clearAICache() async {
    final controller = TextEditingController();
    bool valid = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text(
              'Limpar cache de IA?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta ação remove o cache de normalização de alimentos. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (v) => setState(() => valid = v.trim().toUpperCase() == 'LIMPAR'),
                  decoration: const InputDecoration(hintText: 'LIMPAR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: !valid
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('food_normalizer_cache_v1');
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Cache de IA limpo'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                child: const Text('Limpar'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _exportAICache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('food_normalizer_cache_v1');
    final pretty = raw == null
        ? '{"items":{},"ts":${DateTime.now().millisecondsSinceEpoch}}'
        : const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    await Clipboard.setData(ClipboardData(text: pretty));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cache de IA copiado'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  Future<void> _importAICache() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Importar Cache de IA (JSON)',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(hintText: '{...}'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data =
                      jsonDecode(controller.text) as Map<String, dynamic>;
                  // valida estrutura mínima
                  data['items'] as Map;
                  data['ts'] as int;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      'food_normalizer_cache_v1', jsonEncode(data));
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cache de IA importado'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON inválido: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerMealGoalsSection() {
    Widget row(String title, String mealKey) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.6.h),
              Row(
                children: [
                  Expanded(child: _miniField('kcal', _mealKcal[mealKey]!)),
                  SizedBox(width: 2.w),
                  Expanded(child: _miniField('Carboidratos (g)', _mealCarb[mealKey]!)),
                  SizedBox(width: 2.w),
              Expanded(child: _miniField('Proteínas (g)', _mealProt[mealKey]!)),
              SizedBox(width: 2.w),
              Expanded(child: _miniField('Gorduras (g)', _mealFat[mealKey]!)),
                ],
              ),
          SizedBox(height: 1.h),
        ],
      );
    }

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metas por refeição',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          row('Café da manhã', 'breakfast'),
          row('Almoço', 'lunch'),
          row('Jantar', 'dinner'),
          row('Lanches', 'snack'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _confirmClearMealGoals,
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('Limpar metas por refeição'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final map = <String, MealGoals>{
                    'breakfast': MealGoals(
                      kcal:
                          int.tryParse(_mealKcal['breakfast']!.text.trim()) ?? 0,
                      carbs:
                          int.tryParse(_mealCarb['breakfast']!.text.trim()) ?? 0,
                      proteins:
                          int.tryParse(_mealProt['breakfast']!.text.trim()) ?? 0,
                      fats: int.tryParse(_mealFat['breakfast']!.text.trim()) ?? 0,
                    ),
                    'lunch': MealGoals(
                      kcal: int.tryParse(_mealKcal['lunch']!.text.trim()) ?? 0,
                      carbs: int.tryParse(_mealCarb['lunch']!.text.trim()) ?? 0,
                      proteins:
                          int.tryParse(_mealProt['lunch']!.text.trim()) ?? 0,
                      fats: int.tryParse(_mealFat['lunch']!.text.trim()) ?? 0,
                    ),
                    'dinner': MealGoals(
                      kcal: int.tryParse(_mealKcal['dinner']!.text.trim()) ?? 0,
                      carbs: int.tryParse(_mealCarb['dinner']!.text.trim()) ?? 0,
                      proteins:
                          int.tryParse(_mealProt['dinner']!.text.trim()) ?? 0,
                      fats: int.tryParse(_mealFat['dinner']!.text.trim()) ?? 0,
                    ),
                    'snack': MealGoals(
                      kcal: int.tryParse(_mealKcal['snack']!.text.trim()) ?? 0,
                      carbs: int.tryParse(_mealCarb['snack']!.text.trim()) ?? 0,
                      proteins:
                          int.tryParse(_mealProt['snack']!.text.trim()) ?? 0,
                      fats: int.tryParse(_mealFat['snack']!.text.trim()) ?? 0,
                    ),
                  };
                  await UserPreferences.setMealGoals(map);
                  if (!mounted) return;
                  // Notificar dashboards
                  try {
                    NutritionStorage.changes.value =
                        NutritionStorage.changes.value + 1;
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metas por refeição salvas!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text('Salvar metas por refeição'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearMealGoals() async {
    final controller = TextEditingController();
    bool valid = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text(
              'Limpar metas por refeição?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta ação zera as metas de Café, Almoço, Jantar e Lanches.\nPara confirmar, digite: CONFIRMAR',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (v) => setState(() => valid = v.trim().toUpperCase() == 'CONFIRMAR'),
                  decoration: const InputDecoration(hintText: 'CONFIRMAR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: !valid
                    ? null
                    : () async {
                        await UserPreferences.clearMealGoals();
                        if (!mounted) return;
                        // Limpar campos locais
                        for (final key in _mealKcal.keys) {
                          _mealKcal[key]!.text = '0';
                          _mealCarb[key]!.text = '0';
                          _mealProt[key]!.text = '0';
                          _mealFat[key]!.text = '0';
                        }
                        // Notificar dashboards
                        try {
                          NutritionStorage.changes.value =
                              NutritionStorage.changes.value + 1;
                        } catch (_) {}
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Metas por refeição limpas'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                child: const Text('Limpar'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _miniField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 0.4.h),
        TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '0'),
        ),
      ],
    );
  }

  Future<void> _exportDiary() async {
    try {
      final data = await NutritionStorage.exportDiary();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Diário exportado para a área de transferência'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao exportar: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _importDiary() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Importar Diário (JSON)',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(hintText: '{...}'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data =
                      jsonDecode(controller.text) as Map<String, dynamic>;
                  await NutritionStorage.importDiary(data);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Diário importado com sucesso'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON inválido: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final day = prefs.getString('day_templates_v1');
      final week = prefs.getString('week_templates_v1');
      final Map<String, dynamic> obj = {
        'day_templates': day != null ? jsonDecode(day) : [],
        'week_templates': week != null ? jsonDecode(week) : [],
        'version': 1,
      };
      final jsonStr = const JsonEncoder.withIndent('  ').convert(obj);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Templates copiados para a área de transferência'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao exportar templates: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _importTemplates() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Importar Templates (JSON)',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(hintText: '{...}'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data =
                      jsonDecode(controller.text) as Map<String, dynamic>;
                  final day = (data['day_templates'] as List?) ?? [];
                  final week = (data['week_templates'] as List?) ?? [];
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('day_templates_v1', jsonEncode(day));
                  await prefs.setString('week_templates_v1', jsonEncode(week));
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Templates importados com sucesso'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON inválido: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fav = prefs.getString('favorite_foods_v1');
      final mine = prefs.getString('my_foods_v1');
      final Map<String, dynamic> obj = {
        'favorites': fav != null ? jsonDecode(fav) : [],
        'my_foods': mine != null ? jsonDecode(mine) : [],
        'version': 1,
      };
      final jsonStr = const JsonEncoder.withIndent('  ').convert(obj);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Alimentos copiados para a área de transferência'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao exportar alimentos: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _importFoods() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Importar Alimentos (JSON)',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 600,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(hintText: '{...}'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data =
                      jsonDecode(controller.text) as Map<String, dynamic>;
                  final fav = (data['favorites'] as List?) ?? [];
                  final mine = (data['my_foods'] as List?) ?? [];
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('favorite_foods_v1', jsonEncode(fav));
                  await prefs.setString('my_foods_v1', jsonEncode(mine));
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alimentos importados com sucesso'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON inválido: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearFoods() async {
    final controller = TextEditingController();
    bool valid = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text(
              'Limpar todos os alimentos?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta ação remove Favoritos e Meus Alimentos. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (v) => setState(() => valid = v.trim().toUpperCase() == 'LIMPAR'),
                  decoration: const InputDecoration(hintText: 'LIMPAR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: !valid
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('favorite_foods_v1');
                        await prefs.remove('my_foods_v1');
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Alimentos limpos'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                child: const Text('Limpar'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _confirmClearTemplates() async {
    final controller = TextEditingController();
    bool valid = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.secondaryBackgroundDark,
            title: Text(
              'Limpar todos os templates?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta ação remove todos os templates de dia e semana. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (v) => setState(() => valid = v.trim().toUpperCase() == 'LIMPAR'),
                  decoration: const InputDecoration(hintText: 'LIMPAR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: !valid
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('day_templates_v1');
                        await prefs.remove('week_templates_v1');
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Templates limpos'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                child: const Text('Limpar'),
              ),
            ],
          );
        });
      },
    );
  }
}
