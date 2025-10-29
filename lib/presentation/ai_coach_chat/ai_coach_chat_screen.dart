import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../services/coach_api_service.dart';
import '../../services/nutrition_storage.dart';
import '../../services/user_preferences.dart';
import '../../theme/design_tokens.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

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
  bool _isPremiumUser = false;
  late final VoidCallback _prefsListener;

  @override
  void initState() {
    super.initState();
    _prefsListener = () => _loadPremiumStatus();
    UserPreferences.changes.addListener(_prefsListener);
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final status = await UserPreferences.getPremiumStatus();
    if (!mounted) return;
    setState(() => _isPremiumUser = status);
  }

  @override
  void dispose() {
    UserPreferences.changes.removeListener(_prefsListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!_isPremiumUser) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Coach de IA'),
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildLockedState(context),
      );
    }
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
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(cs.primary),
                              )),
                        )
                      : IconButton(
                          onPressed: _onSend,
                          icon: Icon(Icons.send, color: cs.primary),
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
                  backgroundColor:
                      cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSend() async {
    if (!_isPremiumUser) {
      _showProUpgradeMessage('Coach de IA');
      return;
    }
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
      final ctx = await _buildDailyContext();
      final coachReply = await CoachApiService.instance
          .sendMessage(message: text, history: history, context: ctx);
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

  Future<Map<String, dynamic>> _buildDailyContext() async {
    final date = DateTime(_targetDate.year, _targetDate.month, _targetDate.day);
    final entries = await NutritionStorage.getEntriesForDate(date);
    int kcal = 0;
    double carbs = 0, protein = 0, fat = 0;
    for (final e in entries) {
      kcal += (e['calories'] as num?)?.toInt() ?? 0;
      carbs += (e['carbs'] as num?)?.toDouble() ?? 0.0;
      protein += (e['protein'] as num?)?.toDouble() ?? 0.0;
      fat += (e['fat'] as num?)?.toDouble() ?? 0.0;
    }
    final water = await NutritionStorage.getWaterMl(date);
    final goals = await UserPreferences.getGoals();
    final remainingKcal =
        (goals.totalCalories - kcal).clamp(0, goals.totalCalories);
    final remainingCarb = (goals.carbs - carbs).clamp(0, goals.carbs).toInt();
    final remainingProt =
        (goals.proteins - protein).clamp(0, goals.proteins).toInt();
    final remainingFat = (goals.fats - fat).clamp(0, goals.fats).toInt();
    final remainingWater =
        (goals.waterGoalMl - water).clamp(0, goals.waterGoalMl);
    return {
      'date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'goals': {
        'calories': goals.totalCalories,
        'carbs_g': goals.carbs,
        'protein_g': goals.proteins,
        'fat_g': goals.fats,
        'water_ml': goals.waterGoalMl,
      },
      'consumed': {
        'calories': kcal,
        'carbs_g': carbs,
        'protein_g': protein,
        'fat_g': fat,
        'water_ml': water,
      },
      'remaining': {
        'calories': remainingKcal,
        'carbs_g': remainingCarb,
        'protein_g': remainingProt,
        'fat_g': remainingFat,
        'water_ml': remainingWater,
      }
    };
  }

  Future<void> _onAttachPhoto() async {
    if (!_isPremiumUser) {
      _showProUpgradeMessage('Anexar fotos no Coach');
      return;
    }
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, 'gallery')),
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, 'camera')),
          const SizedBox(height: 6),
        ]),
      ),
    );
    if (choice == null) return;
    try {
      XFile? picked;
      if (choice == 'gallery') {
        picked = await _picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
      } else {
        picked = await _picker.pickImage(
            source: ImageSource.camera, imageQuality: 90);
      }
      if (picked == null) return;
      final file = File(picked.path);
      await _sendPhoto(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao anexar: ${e.toString()}')));
    }
  }

  Future<void> _sendPhoto(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      setState(() => _items.add(_ChatTyping()));
      final cands =
          await CoachApiService.instance.analyzePhoto(imageBase64: b64);
      if (!mounted) return;
      setState(() {
        // remove typing
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
        _items.add(_ChatEvents([
          {
            'tool': 'analisar_foto',
            'ok': true,
            'result': {'candidatos': cands}
          },
        ]));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final idx = _items.lastIndexWhere((e) => e is _ChatTyping);
        if (idx >= 0) _items.removeAt(idx);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha na análise da foto: ${e.toString()}')));
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
            SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
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
        final names = itens
            .take(3)
            .map((it) => (it['nome'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .join(', ');
        content =
            Text('OFF resultados: ${names.isEmpty ? 'sem itens' : names}');
        break;
      case 'analisar_barcode':
        final item = (result['item'] as Map?) ?? const {};
        final nome = (item['nome'] ?? '').toString();
        final porcao = (item['porcao'] ?? '').toString();
        final np = (item['nutricao_por_porcao'] as Map?) ?? const {};
        final kcal = np['kcal']?.toString() ?? '';
        content = Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
                'Código: ${nome.isEmpty ? 'produto' : nome} • ${porcao.isEmpty ? '' : porcao} • ${kcal.isEmpty ? '' : '$kcal kcal'}'),
            TextButton(
              onPressed: () {
                final typed = Map<String, dynamic>.from(
                  (item).map((k, v) => MapEntry(k.toString(), v)),
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
        content = Text(
            'Adicionado: ${nomeLog.isEmpty ? 'alimento' : nomeLog} • ${porcaoLog.isEmpty ? '' : porcaoLog} • ${kcalLog.isEmpty ? '' : '$kcalLog kcal'} ${meal.isNotEmpty ? '• $meal' : ''}');
        break;
      case 'analisar_foto':
        final cands = (result['candidatos'] as List?)
                ?.cast<dynamic>()
                .map<Map<String, dynamic>>(
                    (x) => (x as Map).map((k, v) => MapEntry(k.toString(), v)))
                .toList() ??
            const [];
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Foto: candidatos detectados'),
            const SizedBox(height: 6),
            for (final c in cands)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                        '${c['nome'] ?? ''} • ${(c['porcao'] ?? '').toString()} • conf ${((c['confianca'] ?? '')).toString()}'),
                    TextButton(
                      onPressed: () =>
                          _searchAndLogCandidate(c['nome']?.toString() ?? ''),
                      child: const Text('Buscar e Logar'),
                    ),
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
        content = Text(
            'Sugestão: ${nome.isEmpty ? 'refeição' : nome} ${kcal.isNotEmpty ? '• $kcal kcal' : ''}');
        break;
      case 'sugerir_log_refeicao':
        final sugAny = ((result['sugestao'] as Map?) ?? result);
        final sug = Map<String, dynamic>.from(
            sugAny.map((k, v) => MapEntry(k.toString(), v)));
        final nomeS = (sug['nome'] ?? '').toString();
        final porcaoS = (sug['porcao'] ?? '').toString();
        final kcalS = (sug['kcal'] ?? '').toString();
        final mg = (sug['macros_g'] as Map?) ?? const {};
        final c = (mg['carbo'] as num?)?.toInt() ?? 0;
        final p = (mg['proteina'] as num?)?.toInt() ?? 0;
        final g = (mg['gordura'] as num?)?.toInt() ?? 0;
        final meal = (sug['mealTime'] ?? '').toString();
        content = Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
                '${nomeS.isEmpty ? 'Sugestão' : nomeS}${porcaoS.isNotEmpty ? ' • $porcaoS' : ''}${kcalS.isNotEmpty ? ' • $kcalS kcal' : ''} • C ${c}g • P ${p}g • G ${g}g${meal.isNotEmpty ? ' • $meal' : ''}'),
            ElevatedButton(
              onPressed: () => _confirmAndLogSuggestion(sug),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
        break;
      default:
        content = Text('Ferramenta: $tool');
    }
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? cs.surfaceContainerHighest : cs.errorContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ok ? Icons.task_alt : Icons.error_outline,
                  size: 16, color: ok ? cs.primary : cs.error),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW - 40),
                child: content,
              ),
            ],
          );
        },
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
                  decoration:
                      const InputDecoration(labelText: 'Quantidade de porções'),
                  onChanged: (v) {
                    portions = double.tryParse(v.replaceAll(',', '.')) ?? 1.0;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: mealKey,
                  items: [
                    DropdownMenuItem(value: 'breakfast', child: Text(AppLocalizations.of(context)!.mealBreakfast)),
                    DropdownMenuItem(value: 'lunch', child: Text(AppLocalizations.of(context)!.mealLunch)),
                    DropdownMenuItem(value: 'dinner', child: Text(AppLocalizations.of(context)!.mealDinner)),
                    DropdownMenuItem(value: 'snack', child: Text(AppLocalizations.of(context)!.mealSnack)),
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
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppLocalizations.of(context)!.save)),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
  }

  Future<void> _searchAndLogCandidate(String name) async {
    if (name.isEmpty) return;
    try {
      final items = await CoachApiService.instance.searchFoods(name, topK: 5);
      if (!mounted) return;
      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nenhum item encontrado para "$name"')));
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
                        subtitle: Text(
                            'kcal/100g: ${(it['nutricao_por_100g']?['kcal'] ?? '').toString()}'),
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
                    items: [
                      DropdownMenuItem(value: 'breakfast', child: Text(AppLocalizations.of(context)!.mealBreakfast)),
                      DropdownMenuItem(value: 'lunch', child: Text(AppLocalizations.of(context)!.mealLunch)),
                      DropdownMenuItem(value: 'dinner', child: Text(AppLocalizations.of(context)!.mealDinner)),
                      DropdownMenuItem(value: 'snack', child: Text(AppLocalizations.of(context)!.mealSnack)),
                    ],
                    onChanged: (v) => mealKey = v ?? 'snack',
                    decoration: const InputDecoration(labelText: 'Período'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(AppLocalizations.of(context)!.save)),
            ],
          );
        },
      );
      if (ok != true) return;

      final grams = int.tryParse(gramsController.text.trim()) ?? 0;
      if (grams <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid portion')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao buscar/logar: ${e.toString()}')));
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nenhum item encontrado para "$name"')));
        return;
      }
      final selected = items.first;
      final per100 = selected['nutricao_por_100g'] as Map? ?? const {};
      int grams =
          _parseGramsFromPortion((cand['porcao'] ?? '').toString()) ?? 150;

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
                    final baseKcal2 =
                        (per100['kcal'] as num?)?.toDouble() ?? 0.0;
                    final baseCarb2 =
                        (per100['carbo'] as num?)?.toDouble() ?? 0.0;
                    final baseProt2 =
                        (per100['proteina'] as num?)?.toDouble() ?? 0.0;
                    final baseFat2 =
                        (per100['gordura'] as num?)?.toDouble() ?? 0.0;
                    kcal = (baseKcal2 * r).round();
                    carbs = baseCarb2 * r;
                    protein = baseProt2 * r;
                    fat = baseFat2 * r;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: mealKey,
                  items: [
                    DropdownMenuItem(value: 'breakfast', child: Text(AppLocalizations.of(context)!.mealBreakfast)),
                    DropdownMenuItem(value: 'lunch', child: Text(AppLocalizations.of(context)!.mealLunch)),
                    DropdownMenuItem(value: 'dinner', child: Text(AppLocalizations.of(context)!.mealDinner)),
                    DropdownMenuItem(value: 'snack', child: Text(AppLocalizations.of(context)!.mealSnack)),
                  ],
                  onChanged: (v) => mealKey = v ?? 'snack',
                  decoration: const InputDecoration(labelText: 'Período'),
                ),
                const SizedBox(height: 10),
                Text('Estimativa: $kcal kcal'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(AppLocalizations.of(context)!.save)),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alimento adicionado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no log rápido: ${e.toString()}')));
    }
  }

  Future<void> _confirmAndLogSuggestion(Map<String, dynamic> sug) async {
    final name = (sug['nome'] ?? '').toString();
    final porcao = (sug['porcao'] ?? '1 porção').toString();
    final kcal = (sug['kcal'] as num?)?.toInt() ?? 0;
    final mg = (sug['macros_g'] as Map?) ?? const {};
    final carbs = (mg['carbo'] as num?)?.toDouble() ?? 0.0;
    final protein = (mg['proteina'] as num?)?.toDouble() ?? 0.0;
    final fat = (mg['gordura'] as num?)?.toDouble() ?? 0.0;
    String mealKey = (sug['mealTime'] ?? '').toString();
    if (mealKey.isEmpty) mealKey = _defaultMealKey;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String localMeal = mealKey;
        return StatefulBuilder(builder: (ctx2, setSt) {
          return AlertDialog(
            title: const Text('Confirmar registro'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '$name\n$porcao • ${kcal > 0 ? '$kcal kcal' : ''}\nC ${carbs.toStringAsFixed(0)}g • P ${protein.toStringAsFixed(0)}g • G ${fat.toStringAsFixed(0)}g'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: localMeal,
                  items: [
                    DropdownMenuItem(value: 'breakfast', child: Text(AppLocalizations.of(context)!.mealBreakfast)),
                    DropdownMenuItem(value: 'lunch', child: Text(AppLocalizations.of(context)!.mealLunch)),
                    DropdownMenuItem(value: 'dinner', child: Text(AppLocalizations.of(context)!.mealDinner)),
                    DropdownMenuItem(value: 'snack', child: Text(AppLocalizations.of(context)!.mealSnack)),
                  ],
                  onChanged: (v) => setSt(() => localMeal = v ?? 'snack'),
                  decoration: const InputDecoration(labelText: 'Período'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx2, false),
                  child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                  onPressed: () {
                    mealKey = localMeal;
                    Navigator.pop(ctx2, true);
                  },
                  child: Text(AppLocalizations.of(context)!.save)),
            ],
          );
        });
      },
    );
    if (ok != true) return;

    final entry = <String, dynamic>{
      'name': name.isEmpty ? 'Alimento' : name,
      'brand': null,
      'calories': kcal,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'quantity': 1.0,
      'serving': porcao,
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Alimento registrado')));
  }

  Widget _buildLockedState(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy_outlined,
                      color: colors.primary, size: 26),
                  SizedBox(width: 2.w),
                  Text(
                    'Desbloqueie o Coach de IA',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Text(
                'Assinantes PRO recebem orientações personalizadas, registro rápido via IA e análise instantânea de fotos.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: 1.6.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openProPlans,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 1.6.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Conhecer planos PRO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProUpgradeMessage(String feature) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('$feature está disponível no NutriTracker PRO'),
        action: SnackBarAction(
          label: 'Ver planos',
          onPressed: _openProPlans,
        ),
      ),
    );
  }

  void _openProPlans() {
    Navigator.pushNamed(context, AppRoutes.proSubscription);
  }
}

