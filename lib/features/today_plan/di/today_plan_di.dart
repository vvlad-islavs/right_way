import 'package:get_it/get_it.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/data/data.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';
import 'package:right_way/features/today_plan/ui/ui.dart';

class TodayPlanDi {
  static void register(GetIt di) {
    di
      ..registerLazySingleton<TodayPlanLocalSource>(
        () => ObjectBoxTodayPlanLocalSource(di<ObjectBoxStore>()),
      )
      ..registerLazySingleton<TodayPlanUseCase>(
        () => TodayPlanUseCase(di<TodayPlanLocalSource>()),
      )
      ..registerFactory<TodayPlanCubit>(
        () => TodayPlanCubit(di<TodayPlanUseCase>(), di<ErrorReporter>()),
      );
  }
}
