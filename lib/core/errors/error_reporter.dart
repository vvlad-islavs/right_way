import 'dart:async';

import 'package:right_way/core/logging/logging.dart';

import 'app_errors.dart';

class AppError {
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
  final Object? cause;
  final StackTrace? stackTrace;
}

abstract interface class ErrorReporter {
  Stream<AppError> get stream;

  void report(
    Object error,
    StackTrace stackTrace, {
    String? uiMessage,
    String? logMessage,
  });

  void reportMessage({required String uiMessage, String? logMessage});
}

/// Дублирует ошибку в [LogService] (полный текст) и в стрим (краткий UI + debug в подписи к логу).
class StreamErrorReporter implements ErrorReporter {
  StreamErrorReporter({required LogService log}) : _log = log;

  final _controller = StreamController<AppError>.broadcast();
  final LogService _log;

  @override
  Stream<AppError> get stream => _controller.stream.asBroadcastStream();

  @override
  void report(
    Object error,
    StackTrace stackTrace, {
    String? uiMessage,
    String? logMessage,
  }) {
    final ui = (uiMessage == null || uiMessage.trim().isEmpty) ? AppErrors.genericUi : uiMessage.trim();
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

  @override
  void reportMessage({required String uiMessage, String? logMessage}) {
    final ui = uiMessage.trim().isEmpty ? AppErrors.genericUi : uiMessage.trim();
    final logMsg =
        (logMessage == null || logMessage.trim().isEmpty) ? 'reportMessage: $ui' : logMessage.trim();
    _log.error(logMsg, tag: 'error_reporter');
    _controller.add(AppError(uiMessage: ui, debugMessage: logMsg));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
