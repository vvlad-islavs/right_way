import 'package:right_way/core/core.dart';

import '../models/ai_ui_settings_snapshot.dart';

abstract class AppSettingsRepository {
  Future<AiUiSettingsSnapshot> getAiSettings();

  /// Сохраняет выбранного провайдера и возвращает ключ + модель для него.
  Future<AiUiSettingsSnapshot> applyProviderSelection(AiProvider provider);

  Future<void> persistApiKeyAndModel({
    required AiProvider provider,
    required String apiKey,
    required String model,
  });

  Future<void> persistSelectedModel(AiProvider provider, String model);
}
