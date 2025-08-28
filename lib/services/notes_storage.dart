import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotesStorage {
  static const String _kNotes = 'notes_v1';

  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotes);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNotes, jsonEncode(notes));
  }

  static Future<void> add(Map<String, dynamic> note) async {
    final notes = await getAll();
    final withId = Map<String, dynamic>.from(note);
    withId['id'] = withId['id'] ?? DateTime.now().millisecondsSinceEpoch;
    withId['createdAt'] = withId['createdAt'] ?? DateTime.now().toIso8601String();
    withId['updatedAt'] = withId['updatedAt'] ?? withId['createdAt'];
    notes.add(withId);
    await _save(notes);
  }

  static Future<void> update(dynamic id, Map<String, dynamic> patch) async {
    final notes = await getAll();
    final i = notes.indexWhere((n) => n['id'] == id);
    if (i >= 0) {
      final m = Map<String, dynamic>.from(notes[i]);
      m.addAll(patch);
      m['updatedAt'] = DateTime.now().toIso8601String();
      notes[i] = m;
      await _save(notes);
    }
  }

  static Future<void> remove(dynamic id) async {
    final notes = await getAll();
    notes.removeWhere((n) => n['id'] == id);
    await _save(notes);
  }
}

