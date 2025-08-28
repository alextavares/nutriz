import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/user_preferences.dart';
import '../../services/nutrition_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  bool _isPremium = false;
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
                        onPressed: _logout,
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
                Navigator.pop(context, true);
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
                child: OutlinedButton(
                  onPressed: _exportDiary,
                  child: const Text('Exportar (copiar JSON)'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _importDiary,
                  child: const Text('Importar (colar JSON)'),
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
                child: OutlinedButton(
                  onPressed: _exportTemplates,
                  child: const Text('Exportar templates (copiar JSON)'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _importTemplates,
                  child: const Text('Importar templates (colar JSON)'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _confirmClearTemplates,
              child: const Text('Limpar templates'),
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
                child: OutlinedButton(
                  onPressed: _exportFoods,
                  child: const Text('Exportar alimentos (copiar JSON)'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _importFoods,
                  child: const Text('Importar alimentos (colar JSON)'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _confirmClearFoods,
              child: const Text('Limpar alimentos'),
            ),
          ),
        ],
      ),
    );
  });
  }

  Widget _buildUiPreferencesSection() {
    final controller = TextEditingController();
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
    decoration: BoxDecoration(
      color: AppTheme.secondaryBackgroundDark,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.2)),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferências de UI',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          _buildAICacheRow(),
          SizedBox(height: 1.2.h),
          _buildQuickPortionRow(),
          SizedBox(height: 0.8.h),
          _buildPerMealQuickPortionRow(),
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
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
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
                        await UserPreferences.setNewBadgeMinutes(
                            m.clamp(1, 60));
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
      ),
    );
  }

  Widget _buildAICacheRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cache de IA (normalização de alimentos)',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        FutureBuilder<Map<String, dynamic>>(
          future: _loadAICacheStats(),
          builder: (context, snap) {
            final count = (snap.data?['count'] as int?) ?? 0;
            final ts = (snap.data?['ts'] as int?) ?? 0;
            return Text(
              'Itens no cache: $count • Atualizado: ${_formatTs(ts)}',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            );
          },
        ),
        SizedBox(height: 0.8.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _exportAICache,
                child: const Text('Exportar cache (copiar JSON)'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _importAICache,
                child: const Text('Importar cache (colar JSON)'),
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('food_normalizer_cache_v1');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cache de IA limpo'),
        backgroundColor: AppTheme.successGreen,
      ),
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
              Expanded(child: _miniField('carb (g)', _mealCarb[mealKey]!)),
              SizedBox(width: 2.w),
              Expanded(child: _miniField('prot (g)', _mealProt[mealKey]!)),
              SizedBox(width: 2.w),
              Expanded(child: _miniField('gord (g)', _mealFat[mealKey]!)),
            ],
          ),
          SizedBox(height: 1.h),
        ],
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
            'Metas por refeição',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          row('Café da manhã', 'breakfast'),
          row('Almoço', 'lunch'),
          row('Jantar', 'dinner'),
          row('Lanches', 'snack'),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Metas por refeição salvas!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              child: const Text('Salvar metas por refeição'),
            ),
          ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Limpar todos os alimentos?',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Esta ação remove Favoritos e Meus Alimentos. Não pode ser desfeita.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
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
      },
    );
  }

  Future<void> _confirmClearTemplates() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          title: Text(
            'Limpar todos os templates?',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Esta ação remove todos os templates de dia e semana. Não pode ser desfeita.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
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
      },
    );
  }
}
