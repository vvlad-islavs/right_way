import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/domain/domain.dart';

class AppSettingsUseCase {
  AppSettingsUseCase(this._repo, this._errors);

  final AppSettingsRepository _repo;
  final ErrorReporter _errors;

  Future<AiUiSettingsSnapshot> getAiSettings() =>
      ErrorHandling.reportAndRethrow(_errors, () => _repo.getAiSettings());

  Future<AiUiSettingsSnapshot> applyProviderSelection(AiProvider provider) =>
      ErrorHandling.reportAndRethrow(_errors, () => _repo.applyProviderSelection(provider));

  Future<void> persistSelectedModel(AiProvider provider, String model) =>
      ErrorHandling.reportAndRethrow(_errors, () => _repo.persistSelectedModel(provider, model));

  Future<AiUiSettingsSnapshot> saveAiSettings({
    required AiProvider provider,
    required String apiKey,
    required String model,
  }) =>
      ErrorHandling.reportAndRethrow(_errors, () async {
        await _repo.persistApiKeyAndModel(provider: provider, apiKey: apiKey, model: model);
        return _repo.getAiSettings();
      });
}
