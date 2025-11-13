import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/nutrition_storage.dart';
import '../../widgets/profile_section.dart';

class ToolsAndBackupScreen extends StatefulWidget {
  const ToolsAndBackupScreen({super.key});

  @override
  State<ToolsAndBackupScreen> createState() => _ToolsAndBackupScreenState();
}

class _ToolsAndBackupScreenState extends State<ToolsAndBackupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ferramentas e backup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileSection(
              title: 'Backup do Diário',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportDiary,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Exportar JSON'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importDiary,
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Importar JSON'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            ProfileSection(
              title: 'Templates (Dia/Semana)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportTemplates,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Exportar JSON'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importTemplates,
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Importar JSON'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _confirmClearTemplates,
                      icon: const Icon(Icons.cleaning_services_outlined),
                      label: const Text('Limpar templates'),
                    ),
                  )
                ],
              ),
            ),
            ProfileSection(
              title: 'Alimentos (Favoritos / Meus)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportFoods,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Exportar JSON'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importFoods,
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Importar JSON'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _confirmClearFoods,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Limpar alimentos'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportDiary() async {
    try {
      final data = await NutritionStorage.exportDiary();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diário copiado para a área de transferência')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao exportar: $e')),
      );
    }
  }

  Future<void> _importDiary() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Diário (JSON)'),
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
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final Map<String, dynamic> data =
                      jsonDecode(controller.text) as Map<String, dynamic>;
                  await NutritionStorage.importDiary(data);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diário importado com sucesso')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('JSON inválido: $e')),
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
        const SnackBar(content: Text('Templates copiados para a área de transferência')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao exportar templates: $e')),
      );
    }
  }

  Future<void> _importTemplates() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Templates (JSON)'),
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
              child: const Text('Cancelar'),
            ),
            FilledButton(
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
                    const SnackBar(content: Text('Templates importados com sucesso')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('JSON inválido: $e')),
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
        const SnackBar(content: Text('Alimentos copiados para a área de transferência')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao exportar alimentos: $e')),
      );
    }
  }

  Future<void> _importFoods() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Alimentos (JSON)'),
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
              child: const Text('Cancelar'),
            ),
            FilledButton(
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
                    const SnackBar(content: Text('Alimentos importados com sucesso')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('JSON inválido: $e')),
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
            title: const Text('Limpar todos os alimentos?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Esta ação remove Favoritos e Meus Alimentos. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR'),
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
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: !valid
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('favorite_foods_v1');
                        await prefs.remove('my_foods_v1');
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alimentos limpos')),
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
            title: const Text('Limpar todos os templates?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Esta ação remove templates de dia e semana. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR'),
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
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: !valid
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('day_templates_v1');
                        await prefs.remove('week_templates_v1');
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Templates limpos')),
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

