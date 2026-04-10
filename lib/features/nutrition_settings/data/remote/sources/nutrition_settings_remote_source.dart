import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

abstract interface class NutritionSettingsRemoteSource {
  AiProvider get provider;

  List<String> get supportedModels;

  Future<NutritionPlanResult> calculate(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  });
}

