import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutritracker/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Use offline fonts from assets for hermetic golden tests.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Avoid google_fonts usage inside ThemeData during tests to prevent network/asset dependency.
  AppTheme.enableTestFonts();
  // Disable Streak Overview NUX in tests/goldens to keep them hermetic.
  SharedPreferences.setMockInitialValues({'streak_overview_nux_seen': true});
  await loadAppFonts();
  return GoldenToolkit.runWithConfiguration(
    () async { await testMain(); },
    config: GoldenToolkitConfiguration(enableRealShadows: true),
  );
}
