import 'package:get_it/get_it.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';

class NutritionSettingsDi {
  static void register(GetIt di) {
    di
      ..registerLazySingleton<NutritionSettingsRemoteSource>(
        () => NutritionSettingsRemoteSourceImpl(di<ApiClient>()),
      )
      ..registerLazySingleton<NutritionSettingsRepo>(
        () => NutritionSettingsRepoImpl(di<NutritionSettingsRemoteSource>()),
      )
      ..registerLazySingleton<CalculatePlanUseCase>(
        () => CalculatePlanUseCase(di<NutritionSettingsRepo>(), di<ErrorReporter>()),
      )
      ..registerFactory<NutritionSettingsBloc>(
        () => NutritionSettingsBloc(calculatePlan: di<CalculatePlanUseCase>()),
      );
  }
}

