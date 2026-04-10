import 'package:get_it/get_it.dart';
import 'package:right_way/features/app_settings/di/di.dart';
import 'package:right_way/features/body_info/di/di.dart';
import 'package:right_way/features/nutrition_settings/di/di.dart';
import 'package:right_way/features/today_plan/di/di.dart';

class FeaturesDi {
  static void register(GetIt di) {
    AppSettingsDi.register(di);
    BodyInfoDi.register(di);
    TodayPlanDi.register(di);
    NutritionSettingsDi.register(di);
  }
}
