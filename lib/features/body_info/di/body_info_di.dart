import 'package:get_it/get_it.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/data/data.dart';
import 'package:right_way/features/body_info/domain/domain.dart';
import 'package:right_way/features/body_info/ui/ui.dart';

class BodyInfoDi {
  static void register(GetIt di) {
    di
      ..registerLazySingleton<BodyInfoLocalSource>(
        () => ObjectBoxBodyInfoLocalSource(di<ObjectBoxStore>()),
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
