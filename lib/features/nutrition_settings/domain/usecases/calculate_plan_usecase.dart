import 'package:right_way/features/nutrition_settings/domain/domain.dart';
import 'package:right_way/core/core.dart';

class CalculatePlanUseCase {
  CalculatePlanUseCase(this._repo, this._errors);

  final NutritionSettingsRepo _repo;
  final ErrorReporter _errors;

  Future<NutritionPlanResult> call(NutritionSettings settings) async {
    try {
      return await _repo.calculate(settings);
    } catch (e, st) {
      _errors.report(e, st);
      rethrow;
    }
  }
}

