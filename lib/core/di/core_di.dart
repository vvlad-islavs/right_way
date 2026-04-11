import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:right_way/core/ai/ai.dart';
import 'package:right_way/core/errors/errors.dart';
import 'package:right_way/core/l10n/locale_controller.dart';
import 'package:right_way/core/logging/logging.dart';
import 'package:right_way/core/network/network.dart';
import 'package:right_way/core/storage/storage.dart';
import 'package:right_way/core/theme/theme.dart';
import 'package:right_way/features/features.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GetIt di = GetIt.instance;

class CoreDi {
  static Future<void> init({required ObjectBoxStore objectBox}) async {
    await _registerCore(objectBox: objectBox);
    FeaturesDi.register(di);
  }

  static Future<void> _registerCore({required ObjectBoxStore objectBox}) async {
    final prefs = await SharedPreferences.getInstance();
    di.registerSingleton<SharedPreferences>(prefs);
    di.registerSingleton<ObjectBoxStore>(objectBox);
    di.registerSingleton<LocaleController>(LocaleController(prefs));
    di.registerLazySingleton<AppThemeController>(() => AppThemeController(di<SharedPreferences>()));
    di.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
    di.registerLazySingleton<AiSettingsStore>(() => AiSettingsStore(di<FlutterSecureStorage>()));
    di.registerLazySingleton<LogService>(() {
      if (di.isRegistered<Talker>()) return TalkerLogService(di<Talker>());
      return ConsoleLogService();
    });
    di.registerLazySingleton<ErrorReporter>(() => StreamErrorReporter(log: di<LogService>()));
    di.registerLazySingleton<Dio>(() {
      final dio = Dio();
      dio.interceptors.add(DioRetryInterceptor(dio: dio, log: di<LogService>()));
      return dio;
    });
    di.registerLazySingleton<ApiClient>(() => DioApiClient(di<Dio>()));
  }
}
