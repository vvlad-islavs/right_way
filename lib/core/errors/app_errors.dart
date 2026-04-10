/// Ошибка домена: [uiMessage] для Snackbar, [logMessage] для подробного лога.
class AppException implements Exception {
  /// Задает пару сообщений для UI и логов.
  const AppException({required this.uiMessage, required this.logMessage});

  final String uiMessage;
  final String logMessage;

  /// Возвращает [logMessage] для печати и отладки.
  @override
  String toString() => logMessage;
}

/// Готовые тексты и фабрики [AppException]: UI коротко, лог развернуто.
class AppErrors {
  /// Закрытый конструктор: только статические члены.
  AppErrors._();

  /// Общий текст, если не задано свое сообщение для Snackbar.
  static const String genericUi = 'Что-то пошло не так. Попробуй ещё раз.';

  /// Нет сохраненного API-ключа для провайдера [providerTitle].
  static AppException missingApiKey(String providerTitle) => AppException(
    uiMessage: 'Укажи API ключ для $providerTitle в настройках.',
    logMessage: 'Missing API key: providerTitle=$providerTitle',
  );

  /// В DI не зарегистрирован источник для провайдера [providerTitle] ([providerId]).
  static AppException noRemoteSource(String providerTitle, String providerId) => AppException(
    uiMessage: 'Не найден источник для $providerTitle.',
    logMessage: 'No remote source registered: providerId=$providerId',
  );

  /// План с идентификатором [planId] отсутствует в локальной базе.
  static AppException planNotFound(int planId) =>
      AppException(uiMessage: 'План не найден.', logMessage: 'Plan not found: id=$planId');

  /// Пустое имя плана при сохранении.
  static AppException emptyPlanName() => AppException(
    uiMessage: 'Введи название плана, так он сохранится в списке.',
    logMessage: 'Validation: empty planName',
  );

  /// Некорректное числовое значение поля тела.
  static AppException invalidBodyFieldValue() =>
      AppException(uiMessage: 'Некорректное значение.', logMessage: 'Validation: invalid numeric body field');

  /// Ошибка записи в локальное хранилище.
  static AppException failedSaveLocalData() =>
      AppException(uiMessage: 'Не удалось обновить локальное значение', logMessage: 'LocalDB: failed to update');

  /// JSON от ИИ не соответствует ожидаемой структуре плана; [reason] и [payload] в лог.
  static AppException invalidAiPlanStructure({required String reason, Object? payload}) {
    final payloadStr = payload == null ? '' : payload.toString();
    final preview = payloadStr.length > 500 ? '${payloadStr.substring(0, 500)}...' : payloadStr;
    return AppException(
      uiMessage: 'Ответ ИИ не похож на план: неверный формат.',
      logMessage: 'Invalid AI plan structure: $reason. payload=$preview',
    );
  }

  /// При склейке ответов Groq в JSON нет списка `plan`.
  static AppException groqChunkMissingPlan({required Object json}) => AppException(
    uiMessage: 'Модель вернула ответ без списка дней.',
    logMessage: 'Groq chunk merge: missing or invalid "plan". json=$json',
  );

  /// Ответ [providerTitle] не распарсился как JSON; [error] в лог.
  static AppException invalidModelJson(String providerTitle, {Object? error}) => AppException(
    uiMessage: 'Модель вернула некорректный JSON. Попробуй ещё раз или смени модель.',
    logMessage: 'Invalid JSON from provider=$providerTitle error=$error',
  );

  /// Текст UI: лимиты Gemini для ключа равны нулю.
  static const String geminiFreeTierZeroUi =
      'Нет лимитов Gemini для этого ключа (free tier = 0). Нужен другой ключ или биллинг.';

  /// Текст UI: превышены лимиты запросов к Gemini.
  static const String geminiRateLimitedUi = 'Gemini временно недоступен из-за лимитов. Попробуй позже.';

  /// Сетевой или серверный сбой Gemini; подробности в [logDetails].
  static AppException geminiRequestFailed({required String logDetails}) => AppException(
    uiMessage: 'Не удалось обратиться к Gemini. Проверь сеть и ключ.',
    logMessage: 'Gemini request failed: $logDetails',
  );
}
