import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/domain/domain.dart';

/// [AppSettingsRepository] поверх [AiSettingsStore]: валидация модели по списку поддерживаемых.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  /// Хранилище ключей, моделей и выбранного провайдера.
  AppSettingsRepositoryImpl(this._store);

  final AiSettingsStore _store;

  /// Модель из [stored], если она входит в [supportedAiModels], иначе первая из списка.
  String _resolvedModel(AiProvider provider, String? stored) {
    final models = supportedAiModels(provider);
    if (stored != null && models.contains(stored)) return stored;
    return models.first;
  }

  /// Снимок настроек для одного [provider] с подставленной моделью по умолчанию.
  Future<AiUiSettingsSnapshot> _snapshotFor(AiProvider provider) async {
    final apiKey = await _store.getApiKey(provider);
    final modelRaw = await _store.getSelectedModel(provider);
    return AiUiSettingsSnapshot(
      provider: provider,
      model: _resolvedModel(provider, modelRaw),
      apiKey: apiKey ?? '',
    );
  }

  /// См. [AppSettingsRepository.getAiSettings].
  @override
  Future<AiUiSettingsSnapshot> getAiSettings() async {
    final provider = await _store.getSelectedProvider();
    return _snapshotFor(provider);
  }

  /// См. [AppSettingsRepository.applyProviderSelection].
  @override
  Future<AiUiSettingsSnapshot> applyProviderSelection(AiProvider provider) async {
    await _store.setSelectedProvider(provider);
    return _snapshotFor(provider);
  }

  /// См. [AppSettingsRepository.persistApiKeyAndModel].
  @override
  Future<void> persistApiKeyAndModel({
    required AiProvider provider,
    required String apiKey,
    required String model,
  }) async {
    await _store.setApiKey(provider, apiKey);
    final models = supportedAiModels(provider);
    final m = models.contains(model) ? model : models.first;
    await _store.setSelectedModel(provider, m);
  }

  /// См. [AppSettingsRepository.persistSelectedModel].
  @override
  Future<void> persistSelectedModel(AiProvider provider, String model) async {
    await _store.setSelectedModel(provider, model.trim());
  }
}
