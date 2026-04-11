import 'dart:async';

import 'package:right_way/core/logging/logging.dart';
import 'package:right_way/core/l10n/l10n_scope.dart';

/// Нормализованная ошибка для UI (кратко) и для логов (подробно).
class AppError {
  /// [uiMessage] для интерфейса; [debugMessage], [cause] и [stackTrace] для диагностики.
  const AppError({
    required this.uiMessage,
    this.debugMessage,
    this.cause,
    this.stackTrace,
  });

  /// Краткий текст для SnackBar / диалога.
  final String uiMessage;

  /// Подробности для логов (полный контекст).
  final String? debugMessage;

  /// Исходное исключение, если было.
  final Object? cause;

  /// Стек исходной ошибки, если был передан.
  final StackTrace? stackTrace;
}

/// Публикация ошибок: подписка через [stream] и явные вызовы [report] / [reportMessage].
abstract interface class ErrorReporter {
  /// Поток ошибок для Snackbar, диалогов и глобального обработчика.
  Stream<AppError> get stream;

  /// Зафиксировать исключение [error] со стеком; [uiMessage] для пользователя, [logMessage] в лог.
  void report(
    Object error,
    StackTrace stackTrace, {
    String? uiMessage,
    String? logMessage,
  });

  /// Сообщение без объекта-исключения, только текст для UI и опционально для лога.
  void reportMessage({required String uiMessage, String? logMessage});
}

/// [ErrorReporter]: пишет в [LogService] и дублирует событие в широковещательный [stream].
class StreamErrorReporter implements ErrorReporter {
  /// [log] получает полные сообщения об ошибках.
  StreamErrorReporter({required LogService log}) : _log = log;

  final _controller = StreamController<AppError>.broadcast();
  final LogService _log;

  /// Поток из внутреннего broadcast-контроллера (повторный broadcast для подписчиков).
  @override
  Stream<AppError> get stream => _controller.stream.asBroadcastStream();

  /// Логирует [logMessage] или текст [error], публикует [AppError] в [stream].
  @override
  void report(
    Object error,
    StackTrace stackTrace, {
    String? uiMessage,
    String? logMessage,
  }) {
    final ui = (uiMessage == null || uiMessage.trim().isEmpty) ? appL10n().errorGeneric : uiMessage.trim();
    final logMsg = (logMessage == null || logMessage.trim().isEmpty)
        ? 'Unhandled error: ${error.toString()}'
        : logMessage.trim();
    _log.error(
      logMsg,
      tag: 'error_reporter',
      error: error,
      stackTrace: stackTrace,
    );
    _controller.add(
      AppError(
        uiMessage: ui,
        debugMessage: logMsg,
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }

  /// Без исключения: лог и событие только по строкам [uiMessage] и [logMessage].
  @override
  void reportMessage({required String uiMessage, String? logMessage}) {
    final ui = uiMessage.trim().isEmpty ? appL10n().errorGeneric : uiMessage.trim();
    final logMsg =
        (logMessage == null || logMessage.trim().isEmpty) ? 'reportMessage: $ui' : logMessage.trim();
    _log.error(logMsg, tag: 'error_reporter');
    _controller.add(AppError(uiMessage: ui, debugMessage: logMsg));
  }

  /// Закрывает [stream], после вызова подписки не получают событий.
  Future<void> dispose() async {
    await _controller.close();
  }
}
