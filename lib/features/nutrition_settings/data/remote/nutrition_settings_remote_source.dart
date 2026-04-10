import 'package:right_way/features/nutrition_settings/domain/domain.dart';

abstract interface class NutritionSettingsRemoteSource {
  Future<NutritionPlanResult> calculate(NutritionSettings settings);
}

