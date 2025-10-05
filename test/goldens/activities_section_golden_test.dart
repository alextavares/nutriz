import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nutritracker/presentation/activity/widgets/activities_section_widget.dart';
import 'helpers.dart';

void main() {
  setUpAll(() async {
    await ensureGoldenFontsLoaded();
  });

  testGoldens('ActivitiesSection - with steps card', (tester) async {
    await pumpGolden(
      tester,
      ActivitiesSectionWidget(
        onConnect: () {},
        onManual: () {},
        onMore: () {},
      ),
    );
    await screenMatchesGolden(tester, 'activities_section_steps');
  });
}

