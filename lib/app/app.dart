import 'package:flutter/material.dart';
import 'package:right_way/app/app_initializer.dart';
import 'package:right_way/core/core.dart';

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

  @override
  void initState() {
    super.initState();
    _router = widget.appInitializer.router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Right Way',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router.config(),
    );
  }
}

