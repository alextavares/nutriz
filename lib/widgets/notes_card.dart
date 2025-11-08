import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import '../core/haptic_helper.dart';
import '../services/analytics_service.dart';
import '../l10n/generated/app_localizations.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH, vertical: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () {
                  AnalyticsService.track('notes_view_all_click');
                  onViewAll();
                },
                child: Text(
                  AppLocalizations.of(context)!.notesViewAll,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Note Display/Input Card
          InkWell(
            onTap: () async {
              await HapticHelper.light();
              onAddNote();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading) ...[
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ] else if (hasNote) ...[
                    Text(
                      lastNote!.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Text(
                      'Add your notes here...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Quick Mood Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MoodButton(emoji: '😊', label: 'Great', onTap: () async {
                        await HapticHelper.light();
                        AnalyticsService.track('notes_mood_great');
                        onAddNote();
                      }),
                      _MoodButton(emoji: '😐', label: 'Okay', onTap: () async {
                        await HapticHelper.light();
                        AnalyticsService.track('notes_mood_okay');
                        onAddNote();
                      }),
                      _MoodButton(emoji: '😔', label: 'Low', onTap: () async {
                        await HapticHelper.light();
                        AnalyticsService.track('notes_mood_low');
                        onAddNote();
                      }),
                      _MoodButton(emoji: '💪', label: 'Energized', onTap: () async {
                        await HapticHelper.light();
                        AnalyticsService.track('notes_mood_energized');
                        onAddNote();
                      }),
                      _MoodButton(emoji: '😴', label: 'Tired', onTap: () async {
                        await HapticHelper.light();
                        AnalyticsService.track('notes_mood_tired');
                        onAddNote();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons Grid
          Row(
            children: [
              // Add Button
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await HapticHelper.medium();
                    AnalyticsService.track('notes_add_click');
                    onAddNote();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 28,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Accomplishments Button
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await HapticHelper.medium();
                    AnalyticsService.track('notes_accomplishments_click');
                    onViewAll();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '🏆',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accompli...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if ((noteCount ?? 0) > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppLocalizations.of(context)!.notesToday}: $noteCount ${(noteCount ?? 0) > 1 ? AppLocalizations.of(context)!.notesNotesPlural : AppLocalizations.of(context)!.notesNotesSingular}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




