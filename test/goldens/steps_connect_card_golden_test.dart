import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutriz/presentation/activity/widgets/steps_connect_card_widget.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });

  testGoldens('StepsConnectCard - default', (tester) async {
    await pumpGolden(
      tester,
      StepsConnectCardWidget(
        onConnect: () {},
        onManual: () {},
      ),
    );
    await screenMatchesGolden(tester, 'steps_connect_card');
  });
}

