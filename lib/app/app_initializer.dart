import 'package:right_way/core/core.dart';

class AppInitializer {
  late final AppRouter router;
  late final ObjectBoxStore objectBox;

  Future<void> init() async {
    objectBox = await ObjectBoxStore.create();
    await CoreDi.init(objectBox: objectBox);
    router = AppRouter();
  }
}

