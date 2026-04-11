import 'package:right_way/core/l10n/l10n_scope.dart';

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
  static String get genericUi => appL10n().errorGeneric;

  /// Нет сохраненного API-ключа для провайдера [providerTitle].
  static AppException missingApiKey(String providerTitle) => AppException(
    uiMessage: appL10n().errorMissingApiKey(providerTitle),
    logMessage: 'Missing API key: providerTitle=$providerTitle',
  );

  /// В DI не зарегистрирован источник для провайдера [providerTitle] ([providerId]).
  static AppException noRemoteSource(String providerTitle, String providerId) => AppException(
    uiMessage: appL10n().errorNoRemoteSource(providerTitle),
    logMessage: 'No remote source registered: providerId=$providerId',
  );

  /// План с идентификатором [planId] отсутствует в локальной базе.
  static AppException planNotFound(int planId) =>
      AppException(uiMessage: appL10n().errorPlanNotFound, logMessage: 'Plan not found: id=$planId');

  /// Пустое имя плана при сохранении.
  static AppException emptyPlanName() => AppException(
    uiMessage: appL10n().errorEmptyPlanName,
    logMessage: 'Validation: empty planName',
  );

  /// Некорректное числовое значение поля тела.
  static AppException invalidBodyFieldValue() =>
      AppException(uiMessage: appL10n().errorInvalidBody, logMessage: 'Validation: invalid numeric body field');

  /// Ошибка записи в локальное хранилище.
  static AppException failedSaveLocalData() =>
      AppException(uiMessage: appL10n().errorFailedSaveLocal, logMessage: 'LocalDB: failed to update');

  /// JSON от ИИ не соответствует ожидаемой структуре плана; [reason] и [payload] в лог.
  static AppException invalidAiPlanStructure({required String reason, Object? payload}) {
    final payloadStr = payload == null ? '' : payload.toString();
    final preview = payloadStr.length > 500 ? '${payloadStr.substring(0, 500)}...' : payloadStr;
    return AppException(
      uiMessage: appL10n().errorInvalidAiPlan,
      logMessage: 'Invalid AI plan structure: $reason. payload=$preview',
    );
  }

  /// При склейке ответов Groq в JSON нет списка `plan`.
  static AppException groqChunkMissingPlan({required Object json}) => AppException(
    uiMessage: appL10n().errorGroqMissingPlan,
    logMessage: 'Groq chunk merge: missing or invalid "plan". json=$json',
  );

  /// Ответ [providerTitle] не распарсился как JSON; [error] в лог.
  static AppException invalidModelJson(String providerTitle, {Object? error}) => AppException(
    uiMessage: appL10n().errorInvalidModelJson,
    logMessage: 'Invalid JSON from provider=$providerTitle error=$error',
  );

  /// Текст UI: лимиты Gemini для ключа равны нулю.
  static String get geminiFreeTierZeroUi => appL10n().errorGeminiFreeTier;

  /// Текст UI: превышены лимиты запросов к Gemini.
  static String get geminiRateLimitedUi => appL10n().errorGeminiRateLimit;

  /// Сетевой или серверный сбой Gemini; подробности в [logDetails].
  static AppException geminiRequestFailed({required String logDetails}) => AppException(
    uiMessage: appL10n().errorGeminiRequestFailed,
    logMessage: 'Gemini request failed: $logDetails',
  );
}
