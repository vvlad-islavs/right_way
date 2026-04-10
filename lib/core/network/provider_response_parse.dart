/// Parses `error.message` from OpenAI-compatible JSON error bodies (Groq, OpenAI).
String? extractOpenAiStyleApiErrorMessage(dynamic data) {
  if (data is Map) {
    final err = data['error'];
    if (err is Map) {
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
  }
  return null;
}

/// Parses `error.code` (e.g. `model_decommissioned`) from OpenAI-compatible JSON (Groq, OpenAI).
String? extractOpenAiStyleApiErrorCode(dynamic data) {
  if (data is Map) {
    final err = data['error'];
    if (err is Map) {
      final c = err['code'];
      if (c is String && c.isNotEmpty) return c;
    }
  }
  return null;
}

/// Parses Gemini REST `error.message` from response JSON.
String? extractGeminiApiErrorMessage(dynamic data) {
  if (data is Map) {
    final err = data['error'];
    if (err is Map) {
      final m = err['message'];
      if (m is String) return m;
    }
  }
  return null;
}
