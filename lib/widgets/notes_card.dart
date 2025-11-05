import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import '../services/analytics_service.dart';

class NoteSummary {
  final String id;
  final String text;
  final DateTime createdAt;
  const NoteSummary({required this.id, required this.text, required this.createdAt});
}

class NotesCard extends StatelessWidget {
  final NoteSummary? lastNote;
  final bool isLoading;
  final String? abVariant; // "A" ou "B"; se nulo, resolve via flag local
  final VoidCallback onAddNote;
  final VoidCallback onViewAll;
  final VoidCallback? onImpression; // dispara no post-frame

  // Back-compat: alguns chamadores antigos passam apenas onAddNote + noteCount
  final int? noteCount;

  const NotesCard({
    super.key,
    required this.onAddNote,
    this.onViewAll = _noop,
    this.lastNote,
    this.isLoading = false,
    this.abVariant,
    this.onImpression,
    this.noteCount,
  });

  static void _noop() {}

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return 'ontem';
  }

  Future<String> _variant() async {
    if (abVariant == 'A' || abVariant == 'B') return abVariant!;
    final prefs = await SharedPreferences.getInstance();
    var v = prefs.getString('notes_ab_variant');
    if (v != 'A' && v != 'B') {
      v = (DateTime.now().microsecond % 2 == 0) ? 'A' : 'B';
      await prefs.setString('notes_ab_variant', v);
    }
    return v!;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onImpression?.call();
      AnalyticsService.track('notes_card_impression');
    });

    final hasNote = lastNote != null && !isLoading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH, vertical: AppDimensions.xs),
      child: NutrizCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.mood, color: Theme.of(context).colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasNote ? 'Sua última nota' : 'Como você está hoje?',
                        style: AppTextStyles.h2(context).copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      if (!hasNote) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Registre humor, refeições e aprendizados.',
                          style: AppTextStyles.body2(context),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AnalyticsService.track('notes_view_all_click');
                    onViewAll();
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isLoading) ...[
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ] else if (hasNote) ...[
              Text(
                lastNote!.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body1(context),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _relativeTime(lastNote!.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ] else ...[
              Text('Sem registros ainda.', style: AppTextStyles.body2(context)),
            ],

            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _variant(),
              builder: (context, snap) {
                final v = (snap.data == 'B') ? 'Escrever meu dia' : 'Registrar agora';
                return Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: v,
                        icon: Icons.edit_note,
                        onPressed: () {
                          AnalyticsService.track('notes_add_click', {'variant': snap.data ?? 'A'});
                          onAddNote();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            if ((noteCount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Hoje: $noteCount nota${(noteCount ?? 0) > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}




