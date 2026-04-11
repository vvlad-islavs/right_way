import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

import 'app_initializer.dart';

class App extends StatefulWidget {
  const App({
    required this.appInitializer,
    super.key,
  });

  final AppInitializer appInitializer;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _router;
  late final AppThemeController _theme;

  @override
  void initState() {
    super.initState();
    _router = widget.appInitializer.router;
    _theme = di<AppThemeController>();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Right Way',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: _theme.mode,
          routerConfig: _router.config(),
        );
      },
    );
  }
}
