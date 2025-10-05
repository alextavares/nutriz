import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_export.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/custom_error_widget.dart';

// Permite definir a rota inicial via --dart-define=INITIAL_ROUTE="/sua-rota"
const String kInitialRouteOverride = String.fromEnvironment('INITIAL_ROUTE');
// Permite selecionar um preset de tema via --dart-define=THEME_PRESET="yazio"
const String kThemePreset = String.fromEnvironment('THEME_PRESET');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts runtime downloads in offline environments.
  GoogleFonts.config.allowRuntimeFetching = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      final String? preset = kThemePreset.isNotEmpty ? kThemePreset : null;
      return MaterialApp(
        title: 'nutritracker',
        theme: AppTheme.lightThemeForPreset(preset),
        darkTheme: AppTheme.darkThemeForPreset(preset),
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: kInitialRouteOverride.isNotEmpty
            ? kInitialRouteOverride
            : AppRoutes.initial,
      );
    });
  }
}
