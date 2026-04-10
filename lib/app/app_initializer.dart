import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    di.registerSingleton<SharedPreferences>(prefs);
    objectBox = await ObjectBoxStore.create();
    await CoreDi.init(objectBox: objectBox);
    router = AppRouter();
  }
}

