import 'package:get_it/get_it.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/data/data.dart';
import 'package:right_way/features/app_settings/domain/domain.dart';
import 'package:right_way/features/app_settings/ui/ui.dart';

class AppSettingsDi {
  static void register(GetIt di) {
    di.registerLazySingleton<AppSettingsRepository>(() => AppSettingsRepositoryImpl(di<AiSettingsStore>()));
    di.registerLazySingleton<AppSettingsUseCase>(
      () => AppSettingsUseCase(di<AppSettingsRepository>(), di<ErrorReporter>()),
    );
    di.registerFactory<AppSettingsCubit>(
      () => AppSettingsCubit(
        settingsUsecase: di<AppSettingsUseCase>(),
        errors: di<ErrorReporter>(),
        telemetry: di<AppTelemetry>(),
      )..selectProvider(AiProvider.groq),
    );
  }
}
