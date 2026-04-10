import 'package:get_it/get_it.dart';
import 'package:right_way/features/body_info/body_info.dart';
import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';
import 'package:right_way/features/progress/progress.dart';
import 'package:right_way/features/today_plan/today_plan.dart';

class FeaturesDi {
  static void register(GetIt di) {
    BodyInfoDi.register(di);
    NutritionSettingsDi.register(di);
    TodayPlanDi.register(di);
    ProgressDi.register(di);
  }
}

