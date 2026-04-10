import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:right_way/core/errors/errors.dart';
import 'package:right_way/core/network/network.dart';
import 'package:right_way/core/storage/storage.dart';
import 'package:right_way/features/features.dart';

final GetIt di = GetIt.instance;

class CoreDi {
  static Future<void> init({required ObjectBoxStore objectBox}) async {
    _registerCore(objectBox: objectBox);
    FeaturesDi.register(di);
  }

  static void _registerCore({required ObjectBoxStore objectBox}) {
    di.registerSingleton<ObjectBoxStore>(objectBox);
    di.registerLazySingleton<ErrorReporter>(() => StreamErrorReporter());
    di.registerLazySingleton<Dio>(() => Dio());
    di.registerLazySingleton<ApiClient>(() => DioApiClient(di<Dio>()));
  }
}

