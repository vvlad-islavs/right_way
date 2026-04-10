enum AiProvider {
  gemini,
  openAi,
  groq,
}

extension AiProviderX on AiProvider {
  String get id => switch (this) {
    AiProvider.gemini => 'gemini',
    AiProvider.openAi => 'openai',
    AiProvider.groq => 'groq',
  };

  String get title => switch (this) {
    AiProvider.gemini => 'Google Gemini',
    AiProvider.openAi => 'OpenAI',
    AiProvider.groq => 'Groq',
  };

  static AiProvider? tryParse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'gemini' => AiProvider.gemini,
      'openai' => AiProvider.openAi,
      'groq' => AiProvider.groq,
      _ => null,
    };
  }
}

