import 'ai_provider.dart';

/// Единый список моделей для UI настроек и для remote-источников расчёта плана.
List<String> supportedAiModels(AiProvider provider) {
  return switch (provider) {
    AiProvider.gemini => const [
        'gemini-2.0-flash-lite',
        'gemini-2.0-flash',
        'gemini-2.0-pro',
      ],
    AiProvider.openAi => const [
        'gpt-4.1-mini',
        'gpt-4.1',
        'gpt-4o-mini',
      ],
    AiProvider.groq => const [
        'llama-3.3-70b-versatile',
        'llama-3.1-8b-instant',
        'qwen/qwen3-32b',
      ],
  };
}
