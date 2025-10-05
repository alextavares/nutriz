
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    },
  );
}

Future<void> pumpGolden(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) async {
  await tester.pumpWidgetBuilder(
    wrapWithSizer(child),
    surfaceSize: size,
  );
  await tester.pumpAndSettle();
}

// Ensure google_fonts doesn't throw late in golden tests
Future<void> ensureGoldenFontsLoaded() async {
  // Ensure google_fonts uses local assets, not network fetching.
  GoogleFonts.config.allowRuntimeFetching = false;
}
