import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:right_way/app/app.dart';
import 'package:right_way/core/telemetry/telemetry_bootstrap.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');

      final initializer = AppInitializer();
      await initializer.init();
      runApp(App(appInitializer: initializer));
    },
    (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace));
      TelemetryBootstrap.reportFatalIfReady(error, stackTrace);
    },
  );
}
