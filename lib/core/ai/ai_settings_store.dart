import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ai_provider.dart';

class AiSettingsStore {
  AiSettingsStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _selectedProviderKey = 'ai.selectedProvider';
  static const _selectedModelKeyPrefix = 'ai.selectedModel.';
  static const _apiKeyPrefix = 'ai.apiKey.';

  Future<AiProvider> getSelectedProvider({AiProvider fallback = AiProvider.gemini}) async {
    final raw = await _storage.read(key: _selectedProviderKey);
    return AiProviderX.tryParse(raw) ?? fallback;
  }

  Future<void> setSelectedProvider(AiProvider provider) async {
    await _storage.write(key: _selectedProviderKey, value: provider.id);
  }

  Future<String?> getSelectedModel(AiProvider provider) async {
    return _storage.read(key: '$_selectedModelKeyPrefix${provider.id}');
  }

  Future<void> setSelectedModel(AiProvider provider, String model) async {
    await _storage.write(key: '$_selectedModelKeyPrefix${provider.id}', value: model);
  }

  Future<String?> getApiKey(AiProvider provider) async {
    return _storage.read(key: '$_apiKeyPrefix${provider.id}');
  }

  Future<void> setApiKey(AiProvider provider, String apiKey) async {
    final v = apiKey.trim();
    if (v.isEmpty) {
      await _storage.delete(key: '$_apiKeyPrefix${provider.id}');
      return;
    }
    await _storage.write(key: '$_apiKeyPrefix${provider.id}', value: v);
  }
}
