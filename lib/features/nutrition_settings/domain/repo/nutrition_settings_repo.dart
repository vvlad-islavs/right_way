import '../models/nutrition_plan_result.dart';
import '../models/nutrition_settings.dart';

/// Расчет плана питания через выбранного в настройках провайдера ИИ и сохранение результата локально.
abstract interface class NutritionSettingsRepo {
  /// Построить план по [settings] (сеть, затем запись плана в локальное хранилище внутри реализации).
  Future<NutritionPlanResult> calculate(NutritionSettings settings);
}
