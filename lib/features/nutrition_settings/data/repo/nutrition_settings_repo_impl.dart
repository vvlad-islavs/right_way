import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/data/remote/remote.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

/// [NutritionSettingsRepo]: выбирает [NutritionSettingsRemoteSource] по провайдеру из [AiSettingsStore],
/// вызывает расчет и сохраняет ответ ИИ через [TodayPlanLocalSource].
class NutritionSettingsRepoImpl implements NutritionSettingsRepo {
  /// Первый аргумент: все зарегистрированные [NutritionSettingsRemoteSource] по провайдерам.
  NutritionSettingsRepoImpl(this._remotes, this._settingsStore, this._todayPlanLocal);

  final List<NutritionSettingsRemoteSource> _remotes;
  final AiSettingsStore _settingsStore;
  final TodayPlanLocalSource _todayPlanLocal;

  /// См. [NutritionSettingsRepo.calculate]: сеть, затем [TodayPlanLocalSource.persistFromAiResponse].
  @override
  Future<NutritionPlanResult> calculate(NutritionSettings settings) async {
    final provider = await _settingsStore.getSelectedProvider();
    final source = _remotes
        .where((s) => s.provider == provider)
        .cast<NutritionSettingsRemoteSource?>()
        .firstWhere((e) => e != null, orElse: () => null);
    if (source == null) {
      throw AppErrors.noRemoteSource(provider.title, provider.id);
    }

    final apiKey = await _settingsStore.getApiKey(provider);
    final model =
        await _settingsStore.getSelectedModel(provider) ??
        (source.supportedModels.isNotEmpty ? source.supportedModels.first : '');

    final result = await source.calculate(settings, apiKey: apiKey ?? '', model: model);
    await _todayPlanLocal.persistFromAiResponse(result.rawJson, settings.planName);
    return result;
  }
}
