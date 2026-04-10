import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/data/remote/nutrition_settings_remote_source.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

class NutritionSettingsRemoteSourceImpl implements NutritionSettingsRemoteSource {
  NutritionSettingsRemoteSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<NutritionPlanResult> calculate(NutritionSettings settings) async {
    final json = await _api.postJson(
      '/nutrition/plan',
      body: {
        'days': settings.days,
        'excluded': settings.excludedFoods,
        'notes': settings.notes,
      },
    );

    return NutritionPlanResult(rawJson: json);
  }
}

