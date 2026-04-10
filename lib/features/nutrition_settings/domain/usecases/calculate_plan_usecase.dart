import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

class CalculatePlanUseCase {
  CalculatePlanUseCase(this._repo, this._errors);

  final NutritionSettingsRepo _repo;
  final ErrorReporter _errors;

  Future<NutritionPlanResult> call(NutritionSettings settings) =>
      ErrorHandling.reportAndRethrow(_errors, () => _repo.calculate(settings));
}
