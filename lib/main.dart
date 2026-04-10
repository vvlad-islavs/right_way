import 'dart:async';

import 'package:flutter/material.dart';
import 'package:right_way/app/app.dart';
import 'package:right_way/app/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    final initializer = AppInitializer();
    await initializer.init();
    runApp(App(appInitializer: initializer));
  }, (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
  });
}
