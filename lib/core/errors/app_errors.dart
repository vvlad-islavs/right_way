/// Domain-level failures with a short [uiMessage] for SnackBars and a verbose [logMessage] for logs.
class AppException implements Exception {
  const AppException({required this.uiMessage, required this.logMessage});

  final String uiMessage;
  final String logMessage;

  @override
  String toString() => logMessage;
}

/// Catalog of user-facing strings and [AppException] factories (UI = кратко, log = полно).
class AppErrors {
  AppErrors._();

  static const String genericUi = 'Что-то пошло не так. Попробуй ещё раз.';

  static AppException missingApiKey(String providerTitle) => AppException(
    uiMessage: 'Укажи API ключ для $providerTitle в настройках.',
    logMessage: 'Missing API key: providerTitle=$providerTitle',
  );

  static AppException noRemoteSource(String providerTitle, String providerId) => AppException(
    uiMessage: 'Не найден источник для $providerTitle.',
    logMessage: 'No remote source registered: providerId=$providerId',
  );

  static AppException planNotFound(int planId) =>
      AppException(uiMessage: 'План не найден.', logMessage: 'Plan not found: id=$planId');

  static AppException emptyPlanName() => AppException(
    uiMessage: 'Введи название плана — так он сохранится в списке.',
    logMessage: 'Validation: empty planName',
  );

  static AppException invalidBodyFieldValue() =>
      AppException(uiMessage: 'Некорректное значение.', logMessage: 'Validation: invalid numeric body field');

  static AppException failedSaveLocalData() =>
      AppException(uiMessage: 'Не удалось обновить локальное значение', logMessage: 'LocalDB: failed to update');

  static AppException invalidAiPlanStructure({required String reason, Object? payload}) {
    final payloadStr = payload == null ? '' : payload.toString();
    final preview = payloadStr.length > 500 ? '${payloadStr.substring(0, 500)}…' : payloadStr;
    return AppException(
      uiMessage: 'Ответ ИИ не похож на план: неверный формат.',
      logMessage: 'Invalid AI plan structure: $reason. payload=$preview',
    );
  }

  static AppException groqChunkMissingPlan({required Object json}) => AppException(
    uiMessage: 'Модель вернула ответ без списка дней.',
    logMessage: 'Groq chunk merge: missing or invalid "plan". json=$json',
  );

  static AppException invalidModelJson(String providerTitle, {Object? error}) => AppException(
    uiMessage: 'Модель вернула некорректный JSON. Попробуй ещё раз или смени модель.',
    logMessage: 'Invalid JSON from provider=$providerTitle error=$error',
  );

  static const String geminiFreeTierZeroUi =
      'Нет лимитов Gemini для этого ключа (free tier = 0). Нужен другой ключ или биллинг.';

  static const String geminiRateLimitedUi = 'Gemini временно недоступен из‑за лимитов. Попробуй позже.';

  static AppException geminiRequestFailed({required String logDetails}) => AppException(
    uiMessage: 'Не удалось обратиться к Gemini. Проверь сеть и ключ.',
    logMessage: 'Gemini request failed: $logDetails',
  );
}
