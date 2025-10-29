import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_export.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import '../../services/notes_storage.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _all = [];
  String _filter = 'today'; // today | all
  DateTime? _targetDate;
  final TextEditingController _search = TextEditingController();
  bool _openEditorOnStart = false;
  bool _handledInitialArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitialArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final dateStr = args['date'] as String?;
        if (dateStr != null) {
          final d = DateTime.tryParse(dateStr);
          if (d != null) _targetDate = DateTime(d.year, d.month, d.day);
        }
        _openEditorOnStart = (args['openEditor'] == true);
      }
      _handledInitialArgs = true;
    }
    _load();
  }

  Future<void> _load() async {
    final list = await NotesStorage.getAll();
    if (!mounted) return;
    setState(() => _all = list
      ..sort((a, b) => ((b['updatedAt'] ?? '') as String)
          .compareTo((a['updatedAt'] ?? '') as String)));
    if (_openEditorOnStart) {
      _openEditorOnStart = false;
      if (mounted)
        WidgetsBinding.instance.addPostFrameCallback((_) => _openEditor());
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final t = _search.text.trim().toLowerCase();
    Iterable<Map<String, dynamic>> notes = _all;
    if (_filter == 'today') {
      final d = _targetDate ?? DateTime.now();
      final today = DateTime(d.year, d.month, d.day);
      notes = notes.where((n) {
        final u = DateTime.tryParse(
                (n['updatedAt'] ?? n['createdAt']) as String? ?? '') ??
            DateTime(1970);
        final dd = DateTime(u.year, u.month, u.day);
        return dd == today;
      });
    }
    if (t.isNotEmpty) {
      notes = notes.where((n) =>
          ((n['title'] ?? '') as String).toLowerCase().contains(t) ||
          ((n['content'] ?? '') as String).toLowerCase().contains(t));
    }
    return notes.toList(growable: false);
  }

  Map<String, List<Map<String, dynamic>>> get _groupedByDay {
    final out = <String, List<Map<String, dynamic>>>{};
    for (final n in _filtered) {
      final d = DateTime.tryParse(
              (n['updatedAt'] ?? n['createdAt']) as String? ?? '') ??
          DateTime.now();
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      (out[key] ??= []).add(n);
    }
    // sort keys desc
    final sorted = Map.fromEntries(
        out.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
    return sorted;
  }

  void _openEditor({Map<String, dynamic>? note}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => NoteEditorPage(
          note: note,
          targetDate: _targetDate,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Widget _dayHeader(String ymd) {
    final parts = ymd.split('-');
    String label;
    if (parts.length == 3) {
      final d = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yest = today.subtract(const Duration(days: 1));
      final dd = DateTime(d.year, d.month, d.day);
      if (dd == today) {
        label = AppLocalizations.of(context)!.appbarToday;
      } else if (dd == yest) {
        label = AppLocalizations.of(context)!.yesterday;
      } else {
        label =
            '${dd.day.toString().padLeft(2, '0')}/${dd.month.toString().padLeft(2, '0')}';
      }
    } else {
      label = ymd;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  Color? _parseColor(dynamic v) {
    if (v is int) return Color(v);
    if (v is String && v.isNotEmpty) {
      String s = v.startsWith('#') ? v.substring(1) : v;
      if (s.length == 6) s = 'FF$s';
      final n = int.tryParse(s, radix: 16);
      if (n != null) return Color(n);
    }
    return null;
  }

  Widget _noteTile(Map<String, dynamic> n) {
    final cs = Theme.of(context).colorScheme;
    final updated = DateTime.tryParse(
            (n['updatedAt'] ?? n['createdAt']) as String? ?? '') ??
        DateTime.now();
    final dateStr =
        '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}';
    final color = _parseColor(n['color']);
    final emoji = (n['emoji'] as String?) ?? '';
    final List atts = (n['attachments'] as List?) ?? const [];
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openEditor(note: n),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color bar + emoji
                Column(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color ?? cs.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (emoji.isNotEmpty)
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (n['title'] as String?)?.trim().isNotEmpty == true
                              ? (n['title'] as String)
                              : 'Sem título',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      if ((n['content'] as String?)?.trim().isNotEmpty == true)
                        Text(
                          (n['content'] as String).trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      const SizedBox(height: 6),
                      // attachments preview
                      if (atts.isNotEmpty)
                        SizedBox(
                          height: 56,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: atts.length.clamp(0, 4),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (_, i) {
                              final p = atts[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (p is String && File(p).existsSync())
                                    ? Image.file(File(p),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        color: cs.outlineVariant
                                            .withValues(alpha: 0.2),
                                        child: const Icon(
                                            Icons.image_not_supported)),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // tags
                          Flexible(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final t
                                    in ((n['tags'] as List?) ?? const []))
                                  Chip(
                                      label: Text('$t'),
                                      visualDensity: VisualDensity.compact),
                              ],
                            ),
                          ),
                          Text(dateStr,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await NotesStorage.remove(n['id']);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anotação excluída')));
                    _load();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Anotações'),
        actions: [
          ChoiceChip(
            label: Text('Hoje'),
            selected: _filter == 'today',
            onSelected: (_) => setState(() => _filter = 'today'),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: Text('Todas'),
            selected: _filter == 'all',
            onSelected: (_) => setState(() => _filter = 'all'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Buscar notas',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 1.2.h),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('Sem anotações',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    )
                  : ListView(
                      children: [
                        for (final entry in _groupedByDay.entries) ...[
                          _dayHeader(entry.key),
                          const SizedBox(height: 8),
                          ...entry.value.map(_noteTile).toList(),
                          SizedBox(height: 1.2.h),
                        ]
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final Map<String, dynamic>? note;
  final DateTime? targetDate;
  final ValueChanged<bool>? onDone; // true = saved, false = cancel

  const NoteEditorPage({this.note, this.targetDate, this.onDone});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController title;
  late TextEditingController content;
  String? emoji;
  Color? color;
  final List<String> tags = [];
  final List<String> attachments = [];

  void _close(bool ok) {
    final handler = widget.onDone;
    if (handler != null) {
      handler(ok);
    } else {
      Navigator.of(context).pop(ok);
    }
  }

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.note?['title'] ?? '');
    content = TextEditingController(text: widget.note?['content'] ?? '');
    emoji = widget.note?['emoji'] as String?;
    final c = widget.note?['color'];
    if (c is int) color = Color(c);
    if (c is String && c.isNotEmpty) {
      String s = c.startsWith('#') ? c.substring(1) : c;
      if (s.length == 6) s = 'FF$s';
      final n = int.tryParse(s, radix: 16);
      if (n != null) color = Color(n);
    }
    final t = widget.note?['tags'];
    if (t is List) {
      tags.addAll(t.whereType<String>());
    }
    final a = widget.note?['attachments'];
    if (a is List) {
      attachments.addAll(a.whereType<String>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 1.2.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 1.2.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.dividerGray,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 1.2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _close(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                  ),
                  Text(
                    widget.note == null ? 'Nova anotação' : 'Editar anotação',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              SizedBox(height: 0.6.h),
              TextField(
                controller: title,
                decoration:
                    const InputDecoration(labelText: 'Título', isDense: true),
              ),
              SizedBox(height: 0.8.h),
              TextField(
                controller: content,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Escreva sua anotação...',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 0.8.h),
              // Emoji row
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (final e in [
                      '😀',
                      '🙂',
                      '😐',
                      '😓',
                      '😴',
                      '💪',
                      '🔥',
                      '💧',
                      '🥗'
                    ])
                      ChoiceChip(
                        label: Text(e, style: const TextStyle(fontSize: 16)),
                        selected: emoji == e,
                        onSelected: (_) => setState(() => emoji = e),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 0.8.h),
              // Tags
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final t in [
                      'Geral',
                      'Café da manhã',
                      'Almoço',
                      'Jantar',
                      'Lanches',
                      'Exercício',
                      'Água'
                    ])
                      FilterChip(
                        label: Text(t),
                        selected: tags.contains(t),
                        onSelected: (v) => setState(() {
                          v ? tags.add(t) : tags.remove(t);
                        }),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 0.8.h),
              // Color palette
              Row(
                children: [
                  Text('Cor:', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in [
                        AppTheme.warningAmber,
                        AppTheme.successGreen,
                        AppTheme.activeBlue,
                        AppTheme.errorRed,
                        Colors.purple,
                        Colors.teal,
                      ])
                        GestureDetector(
                          onTap: () => setState(() => color = c),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: c,
                            child: color == c
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              // Attachments
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Anexar fotos'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.activeBlue,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Câmera'),
                  ),
                  const SizedBox(width: 8),
                  Text('${attachments.length} anexos',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 6),
              if (attachments.isNotEmpty)
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemCount: attachments.length,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: File(attachments[i]).existsSync()
                              ? Image.file(File(attachments[i]),
                                  width: 70, height: 70, fit: BoxFit.cover)
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.2),
                                  child: const Icon(Icons.image_not_supported)),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: InkWell(
                            onTap: () =>
                                setState(() => attachments.removeAt(i)),
                            child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    size: 12, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 1.2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final t = title.text.trim();
                    final c = content.text.trim();
                    final data = <String, dynamic>{
                      'title': t,
                      'content': c,
                      'emoji': emoji,
                      'color': color?.toARGB32(),
                      'tags': tags,
                      'attachments': attachments,
                    };
                    if (widget.note == null) {
                      final baseDate = widget.targetDate ?? DateTime.now();
                      final now = DateTime.now();
                      final createdAt = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          now.hour,
                          now.minute,
                          now.second,
                          now.millisecond);
                      data['createdAt'] = createdAt.toIso8601String();
                      data['updatedAt'] = data['createdAt'];
                      await NotesStorage.add(data);
                    } else {
                      await NotesStorage.update(widget.note!['id'], data);
                    }
                    if (!mounted) return;
                    _close(true);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.activeBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> files = await picker.pickMultiImage(imageQuality: 90);
      if (files.isEmpty) return;
      final dir = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${dir.path}/notes');
      if (!notesDir.existsSync()) notesDir.createSync(recursive: true);
      for (final f in files) {
        final String name =
            'img_${DateTime.now().millisecondsSinceEpoch}_${attachments.length}.jpg';
        final String dest = '${notesDir.path}/$name';
        await File(f.path).copy(dest);
        attachments.add(dest);
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (file == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${dir.path}/notes');
      if (!notesDir.existsSync()) notesDir.createSync(recursive: true);
      final String name =
          'cam_${DateTime.now().millisecondsSinceEpoch}_${attachments.length}.jpg';
      final String dest = '${notesDir.path}/$name';
      await File(file.path).copy(dest);
      attachments.add(dest);
      if (mounted) setState(() {});
    } catch (_) {}
  }
}

extension _ColorToArgb on Color {
  int toARGB32() => value;
}
