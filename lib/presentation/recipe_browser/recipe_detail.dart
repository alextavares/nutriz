import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  int portions = 1;
  String mealKey = 'lunch';
  DateTime targetDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      recipe = args;
    }
  }

  Widget _macroChip(String text, Color color) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      backgroundColor: color.withValues(alpha: 0.12),
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.6)),
      ),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = recipe;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receita')),
        body: const Center(child: Text('Receita não encontrada')),
      );
    }
    final kcalPerPortion = (r['calories'] as num?)?.toInt() ?? 0;
    final cPer = (r['carbs'] as num?)?.toInt() ?? 0;
    final pPer = (r['protein'] as num?)?.toInt() ?? 0;
    final fPer = (r['fat'] as num?)?.toInt() ?? 0;
    final totalKcal = kcalPerPortion * portions;
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        title: Text(r['name'] as String? ?? 'Receita'),
      ),
      body: Column(
        children: [
          // Header image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomImageWidget(
                  imageUrl: (r['imageUrl'] as String?) ?? '',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xAA000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 4.w,
                  bottom: 2.h,
                  right: 4.w,
                  child: Row(
                    children: [
                      _pill(Icons.access_time, '${r['prepTime']}min'),
                      SizedBox(width: 2.w),
                      _pill(Icons.local_fire_department,
                          '${kcalPerPortion} kcal/porção',
                          color: AppTheme.warningAmber),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['name'] as String,
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.6.h),
                  if (r['description'] != null)
                    Text(
                      r['description'] as String,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  SizedBox(height: 1.2.h),
                  // Macros per portion (and total by portions)
                  if (cPer + pPer + fPer > 0) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _macroChip('C ${cPer}g', AppTheme.warningAmber),
                        _macroChip('P ${pPer}g', AppTheme.successGreen),
                        _macroChip('G ${fPer}g', AppTheme.activeBlue),
                        if (portions > 1)
                          _macroChip(
                              'Total: C ${cPer * portions}g • P ${pPer * portions}g • G ${fPer * portions}g',
                              AppTheme.textSecondary),
                      ],
                    ),
                    SizedBox(height: 1.2.h),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in (r['mealTypes'] as List? ?? const []))
                        _chip(t),
                      for (final t
                          in (r['dietaryRestrictions'] as List? ?? const []))
                        _chip(t),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text('Porções',
                      style: AppTheme.darkTheme.textTheme.titleMedium),
                  SizedBox(height: 0.8.h),
                  Row(
                    children: [
                      _stepperButton(Icons.remove, () {
                        if (portions > 1) setState(() => portions--);
                      }),
                      SizedBox(width: 4.w),
                      Text('$portions',
                          style: AppTheme.darkTheme.textTheme.titleLarge),
                      SizedBox(width: 4.w),
                      _stepperButton(
                          Icons.add, () => setState(() => portions++)),
                      const Spacer(),
                      Text('Total: $totalKcal kcal',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                                  color: AppTheme.activeBlue,
                                  fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text('Modo de preparo',
                      style: AppTheme.darkTheme.textTheme.titleMedium),
                  SizedBox(height: 0.6.h),
                  Text(
                      'Detalhes de preparo não disponíveis nesta versão (mock).',
                      style: AppTheme.darkTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: ElevatedButton(
                onPressed: _openAddToDiary,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.6.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIconWidget(iconName: 'playlist_add'),
                    SizedBox(width: 2.w),
                    Text('Adicionar ao diário',
                        style: AppTheme.darkTheme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryBackgroundDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: (color ?? AppTheme.textSecondary).withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.textSecondary),
          SizedBox(width: 1.w),
          Text(text,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: color ?? AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: StadiumBorder(
          side: BorderSide(color: AppTheme.dividerGray.withValues(alpha: 0.6))),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall,
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundDark,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  void _openAddToDiary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu),
                    const SizedBox(width: 8),
                    const Text('Selecionar refeição'),
                    const Spacer(),
                    DropdownButton<String>(
                      value: mealKey,
                      items: const [
                        DropdownMenuItem(
                            value: 'breakfast', child: Text('Café')),
                        DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                        DropdownMenuItem(
                            value: 'dinner', child: Text('Jantar')),
                        DropdownMenuItem(
                            value: 'snack', child: Text('Lanches')),
                      ],
                      onChanged: (v) => setState(() => mealKey = v ?? 'lunch'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 8),
                    const Text('Data'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 1),
                          initialDate: targetDate,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(primary: AppTheme.activeBlue),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => targetDate =
                              DateTime(picked.year, picked.month, picked.day));
                        }
                      },
                      child: Text(
                        '${targetDate.day.toString().padLeft(2, '0')}/${targetDate.month.toString().padLeft(2, '0')}',
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmAdd,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAdd() async {
    final r = recipe;
    if (r == null) return;
    final kcalPerPortion = (r['calories'] as num?)?.toInt() ?? 0;
    final cPer = (r['carbs'] as num?)?.toInt() ?? 0;
    final pPer = (r['protein'] as num?)?.toInt() ?? 0;
    final fPer = (r['fat'] as num?)?.toInt() ?? 0;
    final totalKcal = kcalPerPortion * portions;
    final entry = <String, dynamic>{
      'name': (r['name'] as String?) ?? 'Receita',
      'calories': totalKcal,
      'carbs': cPer * portions,
      'protein': pPer * portions,
      'fat': fPer * portions,
      'brand': 'Receita',
      'quantity': portions.toDouble(),
      'serving': '$portions porção(ões)',
      'mealTime': mealKey,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await NutritionStorage.addEntry(targetDate, entry);
    if (!mounted) return;
    Navigator.pop(context); // close sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receita adicionada ao diário'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
