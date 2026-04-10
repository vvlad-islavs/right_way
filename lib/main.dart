import 'dart:async';

import 'package:flutter/material.dart';
import 'package:right_way/app/app.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final initializer = AppInitializer();
      await initializer.init();
      runApp(App(appInitializer: initializer));
    },
    (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace));
    },
  );
}
