import 'package:flutter/material.dart';

class NotesCard extends StatelessWidget {
  final VoidCallback onAddNote;
  final int noteCount;

  const NotesCard({
    super.key,
    required this.onAddNote,
    this.noteCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F9FF), Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EEFF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B7FFF).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                    RotatedBox(
                      quarterTurns: -1,
                      child: Text('😊', style: TextStyle(fontSize: 32)),
                    ),
                    RotatedBox(
                      quarterTurns: 1,
                      child: Text('📝', style: TextStyle(fontSize: 28)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Como foi seu dia?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre suas refeições, humor e conquistas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onAddNote,
                  icon: const Icon(Icons.edit_note, size: 20),
                  label: const Text(
                    'Adicionar Nota',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (noteCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Hoje: $noteCount nota${noteCount > 1 ? 's' : ''}',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}




