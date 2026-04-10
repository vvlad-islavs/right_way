import 'package:dio/dio.dart';
import 'package:right_way/core/network/dio_error_mapper.dart';

import 'app_errors.dart';
import 'error_reporter.dart';

/// Обёртка над [ErrorReporter]: краткий UI в стрим, полный текст в [LogService] через репортёр.
class ErrorHandling {
  ErrorHandling._();

  /// Выполняет [action]; при ошибке шлёт в [errors] (UI + лог) и пробрасывает исключение дальше.
  static Future<T> reportAndRethrow<T>(
    ErrorReporter errors,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } catch (e, st) {
      reportCaught(errors, e, st);
      rethrow;
    }
  }

  static void reportCaught(ErrorReporter errors, Object e, StackTrace st) {
    if (e is AppException) {
      errors.report(e, st, uiMessage: e.uiMessage, logMessage: e.logMessage);
    } else if (e is DioException) {
      final app = DioErrorMapper.fallback(e);
      errors.report(e, st, uiMessage: app.uiMessage, logMessage: app.logMessage);
    } else {
      errors.report(e, st);
    }
  }
}
