import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/data/data.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';
import 'package:right_way/features/nutrition_settings/ui/ui.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

class NutritionSettingsDi {
  static void register(GetIt di) {
    di
      ..registerLazySingleton<List<NutritionSettingsRemoteSource>>(
        () => [
          GeminiRemoteSource(di<Dio>(), log: di<LogService>()),
          OpenAiRemoteSource(di<Dio>(), log: di<LogService>()),
          GroqRemoteSource(di<Dio>(), log: di<LogService>()),
        ],
      )
      ..registerLazySingleton<NutritionSettingsRepo>(
        () => NutritionSettingsRepoImpl(
          di<List<NutritionSettingsRemoteSource>>(),
          di<AiSettingsStore>(),
          di<TodayPlanLocalSource>(),
        ),
      )
      ..registerLazySingleton<CalculatePlanUseCase>(
        () => CalculatePlanUseCase(di<NutritionSettingsRepo>(), di<ErrorReporter>()),
      )
      ..registerFactory<NutritionSettingsBloc>(
        () => NutritionSettingsBloc(
          calculatePlan: di<CalculatePlanUseCase>(),
          errors: di<ErrorReporter>(),
        ),
      );
  }
}
