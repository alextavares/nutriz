import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../services/user_preferences.dart';

class GoalsWizardScreen extends StatefulWidget {
  const GoalsWizardScreen({super.key});

  @override
  State<GoalsWizardScreen> createState() => _GoalsWizardScreenState();
}

class _GoalsWizardScreenState extends State<GoalsWizardScreen> {
  int _step = 0; // 0: calorias, 1: macros, 2: confirmar
  final _calController = TextEditingController(text: '2000');
  final _carbController = TextEditingController(text: '250');
  final _protController = TextEditingController(text: '120');
  final _fatController = TextEditingController(text: '80');

  @override
  void dispose() {
    _calController.dispose();
    _carbController.dispose();
    _protController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      final v = int.tryParse(_calController.text.trim()) ?? 0;
      if (v <= 0) {
        _warn('Informe calorias válidas (> 0)');
        return;
      }
    }
    if (_step == 1) {
      final c = int.tryParse(_carbController.text.trim()) ?? -1;
      final p = int.tryParse(_protController.text.trim()) ?? -1;
      final f = int.tryParse(_fatController.text.trim()) ?? -1;
      if (c < 0 || p < 0 || f < 0) {
        _warn('Macros devem ser números ≥ 0');
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _save() async {
    final total = int.tryParse(_calController.text.trim()) ?? 2000;
    final carb = int.tryParse(_carbController.text.trim()) ?? 250;
    final prot = int.tryParse(_protController.text.trim()) ?? 120;
    final fat = int.tryParse(_fatController.text.trim()) ?? 80;
    // Validação leve: calorias estimadas pelas macros
    final est = (carb * 4) + (prot * 4) + (fat * 9);
    final diff = (est - total).abs();
    if (diff > (total * 0.25)) {
      _warn('Aviso: calorias estimadas pelas macros diferem do total');
    }
    await UserPreferences.setGoals(
      totalCalories: total,
      carbs: carb,
      proteins: prot,
      fats: fat,
    );
    // Opcional: preencher metas por refeição dividindo igualmente (pode ajustar depois)
    final perMeal = {
      'breakfast': MealGoals(
          kcal: (total * 0.25).round(),
          carbs: (carb * 0.25).round(),
          proteins: (prot * 0.25).round(),
          fats: (fat * 0.25).round()),
      'lunch': MealGoals(
          kcal: (total * 0.35).round(),
          carbs: (carb * 0.35).round(),
          proteins: (prot * 0.35).round(),
          fats: (fat * 0.35).round()),
      'dinner': MealGoals(
          kcal: (total * 0.30).round(),
          carbs: (carb * 0.30).round(),
          proteins: (prot * 0.30).round(),
          fats: (fat * 0.30).round()),
      'snack': MealGoals(
          kcal: (total * 0.10).round(),
          carbs: (carb * 0.10).round(),
          proteins: (prot * 0.10).round(),
          fats: (fat * 0.10).round()),
    };
    await UserPreferences.setMealGoals(perMeal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text('Metas salvas'),
          backgroundColor: AppTheme.successGreen),
    );
    Navigator.pop(context, true);
  }

  void _warn(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.warningAmber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        title: const Text('Definir Metas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              _back();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(step: _step),
              SizedBox(height: 2.h),
              Expanded(child: _buildStep()),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_step < 2 ? 'Continuar' : 'Salvar metas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepCard(
          title: 'Meta diária de calorias',
          child: TextField(
            controller: _calController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Calorias (kcal)'),
          ),
        );
      case 1:
        return _StepCard(
          title: 'Metas de macronutrientes',
          child: Column(
            children: [
              TextField(
                controller: _carbController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    const InputDecoration(labelText: 'Carboidratos (g)'),
              ),
              SizedBox(height: 1.2.h),
              TextField(
                controller: _protController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Proteínas (g)'),
              ),
              SizedBox(height: 1.2.h),
              TextField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Gorduras (g)'),
              ),
            ],
          ),
        );
      case 2:
      default:
        final cal = int.tryParse(_calController.text.trim()) ?? 2000;
        final carb = int.tryParse(_carbController.text.trim()) ?? 250;
        final prot = int.tryParse(_protController.text.trim()) ?? 120;
        final fat = int.tryParse(_fatController.text.trim()) ?? 80;
        return _StepCard(
          title: 'Confirme suas metas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Calorias', '$cal kcal'),
              _row('Carboidratos', '$carb g'),
              _row('Proteínas', '$prot g'),
              _row('Gorduras', '$fat g'),
            ],
          ),
        );
    }
  }

  Widget _row(String a, String b) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(a, style: AppTheme.darkTheme.textTheme.bodyLarge),
          Text(b,
              style: AppTheme.darkTheme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});
  @override
  Widget build(BuildContext context) {
    final labels = ['Calorias', 'Macros', 'Confirmar'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final active = i <= step;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    active ? AppTheme.activeBlue : AppTheme.dividerGray,
                child: Text('${i + 1}',
                    style: TextStyle(color: AppTheme.textPrimary)),
              ),
              SizedBox(height: 0.6.h),
              Text(labels[i], style: AppTheme.darkTheme.textTheme.bodySmall),
            ],
          ),
        );
      }),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _StepCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.darkTheme.textTheme.titleMedium),
          SizedBox(height: 1.2.h),
          child,
        ],
      ),
    );
  }
}
