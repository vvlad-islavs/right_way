import 'dart:developer' as developer;

/// Сервис логирования: единая точка для info, warn и error в приложении.
abstract interface class LogService {
  /// Информационное сообщение, опционально с тегом [tag] для фильтрации в консоли.
  void info(String message, {String? tag});

  /// Предупреждение с опциональной ошибкой и стеком.
  void warn(String message, {String? tag, Object? error, StackTrace? stackTrace});

  /// Ошибка с опциональной причиной и стеком.
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace});
}

/// [LogService], пишущий в консоль через dart:developer (developer.log).
class ConsoleLogService implements LogService {
  /// Уровень INFO в developer.log, имя канала из [tag].
  @override
  void info(String message, {String? tag}) {
    developer.log(
      message,
      name: _name(tag),
      level: 800, // INFO
    );
  }

  /// Уровень WARNING в developer.log.
  @override
  void warn(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name(tag),
      level: 900, // WARNING
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Уровень SEVERE в developer.log.
  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name(tag),
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Имя логгера: префикс `right_way` и опционально суффикс из [tag].
  String _name(String? tag) {
    final t = tag?.trim();
    if (t == null || t.isEmpty) return 'right_way';
    return 'right_way.$t';
  }
}

