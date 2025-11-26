import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:nutriz/presentation/recipe_browser/recipe_browser.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> _settle(WidgetTester tester) async {
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Free users see PRO overlays on premium recipes', (tester) async {
    await HttpOverrides.runZoned(() async {
      SharedPreferences.setMockInitialValues({'premium_status': false});

      await tester
          .pumpWidget(Sizer(builder: (context, orientation, deviceType) {
        return const MaterialApp(
          locale: Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecipeBrowser(),
        );
      }));
      await _settle(tester);

      expect(find.text('Somente PRO'), findsWidgets);
      expect(find.text('Receita PRO'), findsWidgets);
    }, createHttpClient: (_) => MockHttpClient());
  });

  testWidgets('Premium users não veem bloqueios nas receitas', (tester) async {
    await HttpOverrides.runZoned(() async {
      SharedPreferences.setMockInitialValues({'premium_status': true});

      await tester
          .pumpWidget(Sizer(builder: (context, orientation, deviceType) {
        return const MaterialApp(
          locale: Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecipeBrowser(),
        );
      }));
      await _settle(tester);

      expect(find.text('Somente PRO'), findsNothing);
      expect(find.text('Receita PRO'), findsNothing);
    }, createHttpClient: (_) => MockHttpClient());
  });
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 400;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.value(<int>[]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
