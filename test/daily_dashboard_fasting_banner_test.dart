import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:nutriz/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 1));
    final muteUntil = now.add(const Duration(hours: 4));
    String two(int v) => v.toString().padLeft(2, '0');
    SharedPreferences.setMockInitialValues({
      // Active fasting session
      'fasting_active_v1': true,
      'fasting_start_iso_v1': start.toIso8601String(),
      'fasting_method_v1': '16:8',
      'fasting_target_secs_v1': 16 * 3600,
      // Mute until in the future
      'fasting_mute_until_iso_v1': muteUntil.toIso8601String(),
      // Eating schedule so banner shows schedule labels too
      'fast_start_eat_hour_v1': 12,
      'fast_start_eat_min_v1': 0,
      'fast_stop_eat_hour_v1': 20,
      'fast_stop_eat_min_v1': 0,
      // Ensure banner not dismissed today
      'fasting_banner_dismissed_on': '1970-01-01',
    });
  });

  testWidgets('shows fasting mute banner when active fast is muted', (tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(home: DailyTrackingDashboard());
        },
      ),
    );
    // Allow async init (loading prefs/storage) to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify banner text fragments are present
    expect(find.textContaining('Jejum em andamento'), findsOneWidget);
    expect(find.textContaining('silenciado'), findsOneWidget);
    // Expect schedule labels present when eating times exist
    expect(find.textContaining('Romper:'), findsOneWidget);
    expect(find.textContaining('Iniciar:'), findsOneWidget);
  });
}

