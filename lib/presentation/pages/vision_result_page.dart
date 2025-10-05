import 'package:flutter/material.dart';
import 'package:nutritracker/services/gemini_client.dart' show FoodNutritionData, DetectedFood;

class VisionResultPage extends StatelessWidget {
  final FoodNutritionData data;
  const VisionResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final foods = data.foods;
    return Scaffold(
      appBar: AppBar(title: const Text('Análise da Foto')),
      body: foods.isEmpty
          ? const Center(child: Text('Nenhum alimento detectado.'))
          : ListView.separated(
              itemCount: foods.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _FoodTile(food: foods[i]),
            ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final DetectedFood food;
  const _FoodTile({required this.food});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(food.name),
      subtitle: Text('''Porção ${food.portionSize} • ${food.calories} kcal
C ${food.carbs}g • P ${food.protein}g • G ${food.fat}g'''),
      trailing: Text('${(food.confidence * 100).toStringAsFixed(0)}%'),
      isThreeLine: true,
    );
  }
}
