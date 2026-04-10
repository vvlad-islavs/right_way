import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/domain/domain.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._store);

  final AiSettingsStore _store;

  String _resolvedModel(AiProvider provider, String? stored) {
    final models = supportedAiModels(provider);
    if (stored != null && models.contains(stored)) return stored;
    return models.first;
  }

  Future<AiUiSettingsSnapshot> _snapshotFor(AiProvider provider) async {
    final apiKey = await _store.getApiKey(provider);
    final modelRaw = await _store.getSelectedModel(provider);
    return AiUiSettingsSnapshot(
      provider: provider,
      model: _resolvedModel(provider, modelRaw),
      apiKey: apiKey ?? '',
    );
  }

  @override
  Future<AiUiSettingsSnapshot> getAiSettings() async {
    final provider = await _store.getSelectedProvider();
    return _snapshotFor(provider);
  }

  @override
  Future<AiUiSettingsSnapshot> applyProviderSelection(AiProvider provider) async {
    await _store.setSelectedProvider(provider);
    return _snapshotFor(provider);
  }

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

  @override
  Future<void> persistSelectedModel(AiProvider provider, String model) async {
    await _store.setSelectedModel(provider, model.trim());
  }
}
