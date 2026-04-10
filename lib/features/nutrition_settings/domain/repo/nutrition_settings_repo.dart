import 'package:right_way/features/nutrition_settings/domain/domain.dart';

abstract interface class NutritionSettingsRepo {
  Future<NutritionPlanResult> calculate(NutritionSettings settings);
}

