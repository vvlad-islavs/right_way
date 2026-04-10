import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

/// Удаленный расчет плана питания для конкретного [AiProvider].
abstract interface class NutritionSettingsRemoteSource {
  /// Провайдер, который реализует этот источник.
  AiProvider get provider;

  /// Идентификаторы моделей, доступные для выбора в UI.
  List<String> get supportedModels;

  /// Запрос к API провайдера: [settings], [apiKey] и [model].
  Future<NutritionPlanResult> calculate(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  });
}

