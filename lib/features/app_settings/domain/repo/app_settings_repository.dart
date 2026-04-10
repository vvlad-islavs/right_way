import 'package:right_way/core/core.dart';

import '../models/ai_ui_settings_snapshot.dart';

/// Доступ к настройкам ИИ: провайдер, ключ API и выбранная модель.
abstract class AppSettingsRepository {
  /// Текущий снимок настроек (провайдер, модель, ключ из хранилища).
  Future<AiUiSettingsSnapshot> getAiSettings();

  /// Записать выбранного [provider] и вернуть актуальный снимок (ключ и модель для него).
  Future<AiUiSettingsSnapshot> applyProviderSelection(AiProvider provider);

  /// Сохранить ключ и модель для указанного [provider].
  Future<void> persistApiKeyAndModel({
    required AiProvider provider,
    required String apiKey,
    required String model,
  });

  /// Обновить только модель для [provider].
  Future<void> persistSelectedModel(AiProvider provider, String model);
}
