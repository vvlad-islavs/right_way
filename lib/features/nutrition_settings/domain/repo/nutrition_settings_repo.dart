import '../models/nutrition_plan_result.dart';
import '../models/nutrition_settings.dart';

abstract interface class NutritionSettingsRepo {
  Future<NutritionPlanResult> calculate(NutritionSettings settings);
}
