import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/l10n/generated/app_localizations.dart';

import 'app_initializer.dart';

class App extends StatefulWidget {
  const App({required this.appInitializer, super.key});

  final AppInitializer appInitializer;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _router;
  late final AppThemeController _theme;
  late final LocaleController _locale;

  @override
  void initState() {
    super.initState();
    _router = widget.appInitializer.router;
    _theme = di<AppThemeController>();
    _locale = di<LocaleController>();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_theme, _locale]),
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: appL10n().appTitle,
          locale: _locale.locale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (device, supported) {
            if (device == null) return supported.first;
            for (final l in supported) {
              if (l.languageCode == device.languageCode) return l;
            }
            return supported.first;
          },
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: _theme.mode,
          routerConfig: _router.config(navigatorObservers: () => [TelemetryNavigatorObserver(di<AppTelemetry>())]),
        );
      },
    );
  }
}
