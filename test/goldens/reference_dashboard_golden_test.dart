import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutritracker/presentation/dashboard/reference_dashboard_mock.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });

  testGoldens('ReferenceDashboardMock - composed', (tester) async {
    await pumpGolden(
      tester,
      const ReferenceDashboardMock(),
    );
    await screenMatchesGolden(tester, 'reference_dashboard_mock');
  });
}

