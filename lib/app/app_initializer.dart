import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:right_way/core/core.dart';

class AppInitializer {
  late final AppRouter router;
  late final ObjectBoxStore objectBox;
  late final Talker talker;

  Future<void> init() async {
    talker = TalkerFlutter.init();
    di.registerSingleton<Talker>(talker);
    Bloc.observer = TalkerBlocObserver(talker: talker);
    objectBox = await ObjectBoxStore.create();
    await CoreDi.init(objectBox: objectBox);
    await TelemetryBootstrap.init(talker, enableTalker: true, enable: false);
    TelemetryBootstrap.wireErrorReporter();
    await AdMobBootstrap.init(talker, enable: true);
    router = AppRouter();
  }
}
