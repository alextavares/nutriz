import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutritracker/services/fasting_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('start and getActive persist active session', () async {
    final start = DateTime.now().subtract(const Duration(hours: 2));
    await FastingStorage.start(
      method: '16:8',
      start: start,
      target: const Duration(hours: 16),
    );
    final active = await FastingStorage.getActive();
    expect(active, isNotNull);
    expect(active!.method, '16:8');
    // Allow small drift in parsing
    expect(active.start.difference(start).inSeconds.abs() <= 1, true);
    expect(active.target.inHours, 16);
  });

  test('stopNow records history with today key and duration', () async {
    final start = DateTime.now().subtract(const Duration(hours: 5, minutes: 30));
    await FastingStorage.start(
      method: '18:6',
      start: start,
      target: const Duration(hours: 18),
    );
    final dur = await FastingStorage.stopNow();
    expect(dur, isNotNull);
    // ~5h30m (allow small deviation)
    expect((dur!.inMinutes - 330).abs() <= 2, true);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('fasting_history_v1');
    expect(raw, isNotNull);
    final map = jsonDecode(raw!);
    // Build today's key
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final key = '${now.year}-${two(now.month)}-${two(now.day)}';
    expect(map[key], isNotNull);
    final entry = map[key] as Map<String, dynamic>;
    expect((entry['duration_secs'] as num).toInt() > 0, true);
    expect(entry['method'], '18:6');
  });

  test('getHistoryInRange returns items within range sorted', () async {
    final prefs = await SharedPreferences.getInstance();
    // Seed three days: D-2, D-1, D
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final d2 = now.subtract(const Duration(days: 2));
    final d1 = now.subtract(const Duration(days: 1));
    final d0 = now;
    final hist = {
      '${d2.year}-${two(d2.month)}-${two(d2.day)}': {
        'duration_secs': 8 * 3600,
        'method': '16:8',
      },
      '${d1.year}-${two(d1.month)}-${two(d1.day)}': {
        'duration_secs': 12 * 3600,
        'method': '18:6',
      },
      '${d0.year}-${two(d0.month)}-${two(d0.day)}': {
        'duration_secs': 16 * 3600,
        'method': '20:4',
      },
    };
    await prefs.setString('fasting_history_v1', jsonEncode(hist));

    final list = await FastingStorage.getHistoryInRange(d1, d0);
    expect(list.length, 2);
    expect(list.first.date.isAtSameMomentAs(DateTime(d1.year, d1.month, d1.day)), true);
    expect(list.last.date.isAtSameMomentAs(DateTime(d0.year, d0.month, d0.day)), true);
  });

  test('getCurrentStreak counts consecutive days meeting threshold', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final d0 = now; // today >= threshold
    final d1 = now.subtract(const Duration(days: 1)); // yesterday >= threshold
    final d2 = now.subtract(const Duration(days: 2)); // 2 days ago < threshold
    final hist = {
      '${d0.year}-${two(d0.month)}-${two(d0.day)}': {
        'duration_secs': 14 * 3600,
        'method': '16:8',
      },
      '${d1.year}-${two(d1.month)}-${two(d1.day)}': {
        'duration_secs': 13 * 3600,
        'method': '16:8',
      },
      '${d2.year}-${two(d2.month)}-${two(d2.day)}': {
        'duration_secs': 6 * 3600,
        'method': 'skip',
      },
    };
    await prefs.setString('fasting_history_v1', jsonEncode(hist));

    final streak = await FastingStorage.getCurrentStreak(threshold: const Duration(hours: 12));
    expect(streak, 2);
  });

  test('custom target persistence works', () async {
    final fallback = await FastingStorage.getCustomTarget();
    expect(fallback.inHours, 14); // default fallback
    await FastingStorage.setCustomTarget(const Duration(hours: 19, minutes: 30));
    final saved = await FastingStorage.getCustomTarget();
    expect(saved.inHours, 19);
    expect(saved.inMinutes % 60, 30);
  });
}

