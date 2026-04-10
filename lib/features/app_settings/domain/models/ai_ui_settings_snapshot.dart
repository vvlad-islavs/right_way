import 'package:right_way/core/core.dart';

/// Состояние блока «ИИ» на экране настроек после чтения из хранилища и нормализации модели.
class AiUiSettingsSnapshot {
  const AiUiSettingsSnapshot({
    required this.provider,
    required this.model,
    required this.apiKey,
  });

  final AiProvider provider;
  final String model;
  final String apiKey;
}
