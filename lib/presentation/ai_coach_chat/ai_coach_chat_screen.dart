import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../services/coach_api_service.dart';
import '../../services/nutrition_storage.dart';

abstract class _ChatEntry {}

class _ChatText extends _ChatEntry {
  final String role; // 'user' | 'assistant'
  final String content;
  _ChatText(this.role, this.content);
}

class _ChatEvents extends _ChatEntry {
  final List<Map<String, dynamic>> events;
  _ChatEvents(this.events);
}

class _ChatTyping extends _ChatEntry {}

class AiCoachChatScreen extends StatefulWidget {
  const AiCoachChatScreen({Key? key}) : super(key: key);

  @override
  State<AiCoachChatScreen> createState() => _AiCoachChatScreenState();
}

class _AiCoachChatScreenState extends State<AiCoachChatScreen> {
  final List<_ChatEntry> _items = [];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  final ImagePicker _picker = ImagePicker();
  DateTime _targetDate = DateTime.now();
  String _defaultMealKey = 'snack';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach de IA'),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildQuickChips(),
          Expanded(child: _buildList(cs)),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Anexar foto',
                    icon: const Icon(Icons.attach_file_outlined),
                    onPressed: _onAttachPhoto,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Pergunte sobre jejum, refeições, macros…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          onPressed: _onSend,
                          icon: const Icon(Icons.send),
                          tooltip: 'Enviar',
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    final cs = Theme.of(context).colorScheme;
    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.bolt_outlined,
        label: 'Calorias de hoje',
        onTap: () {
          _controller.text = 'Quantas calorias consumi hoje?';
          _onSend();
        },
      ),
      (
        icon: Icons.local_drink_outlined,
        label: '+250 ml agora',
        onTap: () async {
          final now = DateTime.now();
          await NutritionStorage.addWaterMl(now, 250);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Água registrada: +250ml')),
          );
        },
      ),
      (
        icon: Icons.restaurant_menu_outlined,
        label: 'Abrir receitas',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.recipeBrowser),
      ),
    ];
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final it in items)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: Icon(it.icon, size: 18),
                  label: Text(it.label),
                  onPressed: it.onTap,
                  backgroundColor: cs.surfaceVariant.withValues(alpha: 0.3),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _items.add(_ChatText('user', text));
      _items.add(_ChatTyping());
      _controller.clear();
    });
    try {
      final history = _buildHistory();
      final coachReply = await CoachApiService.instance.sendMessage(message: text, history: history);
      if (!mounted) return;
      setState(() {
        // remove typing
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
        if (coachReply.toolEvents.isNotEmpty) {
          _items.add(_ChatEvents(coachReply.toolEvents));
        }
        _items.add(_ChatText('assistant', coachReply.reply));
      });
    } catch (e) {
      if (!mounted) return;
      // remove typing
      setState(() {
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao contatar o coach: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _sending = false);
    }
  }

  List<CoachMessage> _buildHistory() {
    final hist = <CoachMessage>[];
    for (final it in _items) {
      if (it is _ChatText) {
        hist.add(CoachMessage(it.role, it.content));
      }
    }
    return hist;
  }

  Future<void> _onAttachPhoto() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Escolher da galeria'), onTap: () => Navigator.pop(ctx, 'gallery')),
          ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tirar foto'), onTap: () => Navigator.pop(ctx, 'camera')),
          const SizedBox(height: 6),
        ]),
      ),
    );
    if (choice == null) return;
    try {
      XFile? picked;
      if (choice == 'gallery') {
        picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      } else {
        picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      }
      if (picked == null) return;
      final file = File(picked.path);
      await _sendPhoto(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao anexar: ${e.toString()}')));
    }
  }

  Future<void> _sendPhoto(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      setState(() => _items.add(_ChatTyping()));
      final cands = await CoachApiService.instance.analyzePhoto(imageBase64: b64);
      if (!mounted) return;
      setState(() {
        // remove typing
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
        _items.add(_ChatEvents([
          { 'tool': 'analisar_foto', 'ok': true, 'result': { 'candidatos': cands } },
        ]));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha na análise da foto: ${e.toString()}')));
    }
  }

  Widget _buildList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _items.length,
      itemBuilder: (context, idx) {
        final it = _items[idx];
        if (it is _ChatText) return _buildBubble(cs, it);
        if (it is _ChatTyping) return _buildTyping(cs);
        if (it is _ChatEvents) return _buildEventsCards(cs, it.events);
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBubble(ColorScheme cs, _ChatText m) {
    final isUser = m.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(maxWidth: 80.w),
        decoration: BoxDecoration(
          color: isUser ? cs.primaryContainer : cs.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: SelectableText(
          m.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
        ),
      ),
    );
  }

  Widget _buildTyping(ColorScheme cs) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('Nutri está pensando…'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCards(ColorScheme cs, List<Map<String, dynamic>> events) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: events.map((e) => _buildEventCard(cs, e)).toList(),
    );
  }

  Widget _buildEventCard(ColorScheme cs, Map<String, dynamic> e) {
    final tool = (e['tool'] ?? '').toString();
    final ok = (e['ok'] ?? true) == true;
    final result = (e['result'] as Map?) ?? const {};
    Widget content;
    switch (tool) {
      case 'planejar_jejum':
        final janelas = (result['janelas'] as List?) ?? const [];
        final first = (janelas.isNotEmpty ? janelas.first : null) as Map?;
        final inicio = first?['inicio']?.toString() ?? '';
        final fim = first?['fim']?.toString() ?? '';
        content = Text('Jejum planejado: $inicio → $fim');
        break;
      case 'buscar_alimento':
        final itens = (result['itens'] as List?) ?? const [];
        final names = itens.take(3).map((it) => (it['nome'] ?? '').toString()).where((s) => s.isNotEmpty).join(', ');
        content = Text('OFF resultados: ${names.isEmpty ? 'sem itens' : names}');
        break;
      case 'analisar_barcode':
        final item = (result['item'] as Map?) ?? const {};
        final nome = (item['nome'] ?? '').toString();
        final porcao = (item['porcao'] ?? '').toString();
        final np = (item['nutricao_por_porcao'] as Map?) ?? const {};
        final kcal = np['kcal']?.toString() ?? '';
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text('Código: ${nome.isEmpty ? 'produto' : nome} • ${porcao.isEmpty ? '' : porcao} • ${kcal.isEmpty ? '' : '$kcal kcal'}')),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                final typed = Map<String, dynamic>.from(
                  (item as Map).map((k, v) => MapEntry(k.toString(), v)),
                );
                _quickLogBarcode(typed);
              },
              child: const Text('Logar porção'),
            ),
          ],
        );
        break;
      case 'log_refeicao':
        final nomeLog = (result['nome'] ?? '').toString();
        final porcaoLog = (result['porcao'] ?? '').toString();
        final kcalLog = (result['kcal'] ?? '').toString();
        final meal = (result['mealTime'] ?? '').toString();
        content = Text('Adicionado: ${nomeLog.isEmpty ? 'alimento' : nomeLog} • ${porcaoLog.isEmpty ? '' : porcaoLog} • ${kcalLog.isEmpty ? '' : '$kcalLog kcal'} ${meal.isNotEmpty ? '• $meal' : ''}');
        break;
      case 'analisar_foto':
        final cands = (result['candidatos'] as List?)?.cast<dynamic>().map<Map<String, dynamic>>((x) => (x as Map).map((k, v) => MapEntry(k.toString(), v))).toList() ?? const [];
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Foto: candidatos detectados'),
            const SizedBox(height: 6),
            for (final c in cands)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text('${c['nome'] ?? ''} • ${(c['porcao'] ?? '').toString()} • conf ${((c['confianca'] ?? '')).toString()}')),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _searchAndLogCandidate(c['nome']?.toString() ?? ''),
                      child: const Text('Buscar e Logar'),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => _quickLogCandidate(c),
                      child: const Text('Logar rápido'),
                    ),
                  ],
                ),
              ),
          ],
        );
        break;
      case 'obter_estatisticas_usuario':
        final resumo = (result['resumo'] as Map?) ?? const {};
        final hoje = (resumo['hoje'] as Map?) ?? const {};
        final kcal = hoje['kcal_restantes']?.toString() ?? '';
        content = Text('Hoje: ${kcal.isEmpty ? '' : '$kcal kcal restantes'}');
        break;
      case 'sugerir_refeicao':
        final sugs = (result['sugestoes'] as List?) ?? const [];
        final s = sugs.isNotEmpty ? (sugs.first as Map) : null;
        final nome = s?['nome']?.toString() ?? '';
        final kcal = s?['kcal']?.toString() ?? '';
        content = Text('Sugestão: ${nome.isEmpty ? 'refeição' : nome} ${kcal.isNotEmpty ? '• $kcal kcal' : ''}');
        break;
      default:
        content = Text('Ferramenta: $tool');
    }
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? cs.surfaceVariant : cs.errorContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.task_alt : Icons.error_outline, size: 16, color: ok ? cs.primary : cs.error),
          const SizedBox(width: 8),
          Flexible(child: content),
        ],
      ),
    );
  }

  Future<void> _quickLogBarcode(Map<String, dynamic> item) async {
    final nome = (item['nome'] ?? '').toString();
    final porcao = (item['porcao'] ?? '').toString();
    final np = (item['nutricao_por_porcao'] as Map?) ?? const {};
    num kcal = (np['kcal'] as num?) ?? 0;
    double carbs = ((np['carbo'] as num?)?.toDouble()) ?? 0.0;
    double protein = ((np['proteina'] as num?)?.toDouble()) ?? 0.0;
    double fat = ((np['gordura'] as num?)?.toDouble()) ?? 0.0;
    double portions = 1.0;
    String mealKey = _defaultMealKey;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: portions.toStringAsFixed(1));
        return AlertDialog(
          title: const Text('Confirmar porção'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome.isEmpty ? 'Produto' : nome),
                if (porcao.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Porção: $porcao'),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quantidade de porções'),
                  onChanged: (v) {
                    portions = double.tryParse(v.replaceAll(',', '.')) ?? 1.0;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: mealKey,
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Café')),
                    DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                    DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                    DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                  ],
                  onChanged: (v) => mealKey = v ?? 'snack',
                  decoration: const InputDecoration(labelText: 'Período'),
                ),
                const SizedBox(height: 10),
                Text('Estimativa: ${(kcal * portions).round()} kcal'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
          ],
        );
      },
    );
    if (ok != true) return;

    final entry = <String, dynamic>{
      'name': nome.isEmpty ? 'Produto' : nome,
      'brand': null,
      'calories': (kcal * portions).round(),
      'carbs': carbs * portions,
      'protein': protein * portions,
      'fat': fat * portions,
      'quantity': portions,
      'serving': porcao.isEmpty ? '1 porção' : porcao,
      'mealTime': mealKey,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await NutritionStorage.addEntry(_targetDate, entry);
    if (!mounted) return;
    setState(() {
      _items.add(_ChatEvents([
        {
          'tool': 'log_refeicao',
          'ok': true,
          'result': {
            'nome': entry['name'],
            'porcao': entry['serving'],
            'kcal': entry['calories'],
            'mealTime': entry['mealTime'],
          }
        }
      ]));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
  }

  Future<void> _searchAndLogCandidate(String name) async {
    if (name.isEmpty) return;
    try {
      final items = await CoachApiService.instance.searchFoods(name, topK: 5);
      if (!mounted) return;
      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nenhum item encontrado para "$name"')));
        return;
      }
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Escolher alimento'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final it in items)
                      ListTile(
                        title: Text((it['nome'] ?? '').toString()),
                        subtitle: Text('kcal/100g: ${(it['nutricao_por_100g']?['kcal'] ?? '').toString()}'),
                        onTap: () => Navigator.pop(ctx, it),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      if (selected == null) return;

      final gramsController = TextEditingController(text: '150');
      String mealKey = _defaultMealKey;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Confirmar porção'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((selected['nome'] ?? '').toString()),
                  const SizedBox(height: 10),
                  TextField(
                    controller: gramsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Gramas'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mealKey,
                    items: const [
                      DropdownMenuItem(value: 'breakfast', child: Text('Café')),
                      DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                      DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                      DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                    ],
                    onChanged: (v) => mealKey = v ?? 'snack',
                    decoration: const InputDecoration(labelText: 'Período'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
            ],
          );
        },
      );
      if (ok != true) return;

      final grams = int.tryParse(gramsController.text.trim()) ?? 0;
      if (grams <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Porção inválida')));
        return;
      }

      final per100 = selected['nutricao_por_100g'] as Map? ?? const {};
      double ratio = grams / 100.0;
      final baseKcal = (per100['kcal'] as num?)?.toDouble() ?? 0.0;
      final baseCarb = (per100['carbo'] as num?)?.toDouble() ?? 0.0;
      final baseProt = (per100['proteina'] as num?)?.toDouble() ?? 0.0;
      final baseFat = (per100['gordura'] as num?)?.toDouble() ?? 0.0;
      int kcal = (baseKcal * ratio).round();
      double carbs = baseCarb * ratio;
      double protein = baseProt * ratio;
      double fat = baseFat * ratio;

      final entry = <String, dynamic>{
        'name': (selected['nome'] ?? '').toString(),
        'brand': null,
        'calories': kcal,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'quantity': 1.0,
        'serving': '${grams} g',
        'mealTime': mealKey,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await NutritionStorage.addEntry(_targetDate, entry);
      if (!mounted) return;
      setState(() {
        _items.add(_ChatEvents([
          {
            'tool': 'log_refeicao',
            'ok': true,
            'result': {
              'nome': entry['name'],
              'porcao': entry['serving'],
              'kcal': entry['calories'],
              'mealTime': entry['mealTime'],
            }
          }
        ]));
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao buscar/logar: ${e.toString()}')));
    }
  }

  int? _parseGramsFromPortion(String? s) {
    if (s == null) return null;
    final txt = s.toLowerCase();
    final mg = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*mg").firstMatch(txt);
    if (mg != null) {
      final v = double.tryParse(mg.group(1)!);
      if (v != null) return (v / 1000.0).round();
    }
    final g = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*(g|gram|grams)").firstMatch(txt);
    if (g != null) {
      final v = double.tryParse(g.group(1)!);
      if (v != null) return v.round();
    }
    final ml = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*ml").firstMatch(txt);
    if (ml != null) {
      final v = double.tryParse(ml.group(1)!);
      if (v != null) return v.round(); // assume densidade ~1
    }
    final l = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*l").firstMatch(txt);
    if (l != null) {
      final v = double.tryParse(l.group(1)!);
      if (v != null) return (v * 1000).round();
    }
    final oz = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*oz").firstMatch(txt);
    if (oz != null) {
      final v = double.tryParse(oz.group(1)!);
      if (v != null) return (v * 28.3495).round();
    }
    return null;
  }

  Future<void> _quickLogCandidate(Map<String, dynamic> cand) async {
    final name = (cand['nome'] ?? '').toString();
    if (name.isEmpty) return;
    try {
      final items = await CoachApiService.instance.searchFoods(name, topK: 3);
      if (items.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nenhum item encontrado para "$name"')));
        return;
      }
      final selected = items.first;
      final per100 = selected['nutricao_por_100g'] as Map? ?? const {};
      int grams = _parseGramsFromPortion((cand['porcao'] ?? '').toString()) ?? 150;

      double ratio = grams / 100.0;
      final baseKcal = (per100['kcal'] as num?)?.toDouble() ?? 0.0;
      final baseCarb = (per100['carbo'] as num?)?.toDouble() ?? 0.0;
      final baseProt = (per100['proteina'] as num?)?.toDouble() ?? 0.0;
      final baseFat = (per100['gordura'] as num?)?.toDouble() ?? 0.0;
      int kcal = (baseKcal * ratio).round();
      double carbs = baseCarb * ratio;
      double protein = baseProt * ratio;
      double fat = baseFat * ratio;

      String mealKey = _defaultMealKey;
      final gramsController = TextEditingController(text: grams.toString());
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Confirmar registro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((selected['nome'] ?? name).toString()),
                const SizedBox(height: 6),
                Text('kcal/100g: ${(per100['kcal'] ?? '').toString()}'),
                const SizedBox(height: 8),
                TextField(
                  controller: gramsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Gramas'),
                  onChanged: (v) {
                    final g = int.tryParse(v.trim()) ?? grams;
                    final r = g / 100.0;
                    final baseKcal2 = (per100['kcal'] as num?)?.toDouble() ?? 0.0;
                    final baseCarb2 = (per100['carbo'] as num?)?.toDouble() ?? 0.0;
                    final baseProt2 = (per100['proteina'] as num?)?.toDouble() ?? 0.0;
                    final baseFat2 = (per100['gordura'] as num?)?.toDouble() ?? 0.0;
                    kcal = (baseKcal2 * r).round();
                    carbs = baseCarb2 * r;
                    protein = baseProt2 * r;
                    fat = baseFat2 * r;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: mealKey,
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Café')),
                    DropdownMenuItem(value: 'lunch', child: Text('Almoço')),
                    DropdownMenuItem(value: 'dinner', child: Text('Jantar')),
                    DropdownMenuItem(value: 'snack', child: Text('Lanche')),
                  ],
                  onChanged: (v) => mealKey = v ?? 'snack',
                  decoration: const InputDecoration(labelText: 'Período'),
                ),
                const SizedBox(height: 10),
                Text('Estimativa: $kcal kcal'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
            ],
          );
        },
      );
      if (ok != true) return;

      grams = int.tryParse(gramsController.text.trim()) ?? grams;
      final entry = <String, dynamic>{
        'name': (selected['nome'] ?? name).toString(),
        'brand': null,
        'calories': kcal,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'quantity': 1.0,
        'serving': '${grams} g',
        'mealTime': mealKey,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await NutritionStorage.addEntry(_targetDate, entry);
      if (!mounted) return;
      setState(() {
        _items.add(_ChatEvents([
          {
            'tool': 'log_refeicao',
            'ok': true,
            'result': {
              'nome': entry['name'],
              'porcao': entry['serving'],
              'kcal': entry['calories'],
              'mealTime': entry['mealTime'],
            }
          }
        ]));
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha no log rápido: ${e.toString()}')));
    }
  }
}
