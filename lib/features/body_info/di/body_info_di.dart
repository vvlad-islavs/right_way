import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/body_info.dart';

class BodyInfoDi {
  static void register(GetIt di) {
    di
      ..registerLazySingleton<Box<BodyProfileEntity>>(
        () => di<ObjectBoxStore>().store.box<BodyProfileEntity>(),
      )
      ..registerLazySingleton<BodyInfoLocalSource>(
        () => ObjectBoxBodyInfoLocalSource(di<Box<BodyProfileEntity>>()),
      )
      ..registerLazySingleton<BodyInfoRepo>(
        () => BodyInfoRepoImpl(di<BodyInfoLocalSource>()),
      )
      ..registerLazySingleton<BodyProfileUseCase>(
        () => BodyProfileUseCase(di<BodyInfoRepo>(), di<ErrorReporter>()),
      )
      ..registerFactory<BodyInfoBloc>(
        () => BodyInfoBloc(
          bodyProfile: di<BodyProfileUseCase>(),
          errors: di<ErrorReporter>(),
        )..add(const BodyInfoEvent.started()),
      );
  }
}

