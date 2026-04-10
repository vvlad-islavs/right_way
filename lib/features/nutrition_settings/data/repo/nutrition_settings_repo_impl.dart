import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';

class NutritionSettingsRepoImpl implements NutritionSettingsRepo {
  NutritionSettingsRepoImpl(this._remote);

  final NutritionSettingsRemoteSource _remote;

  @override
  Future<NutritionPlanResult> calculate(NutritionSettings settings) => _remote.calculate(settings);
}

