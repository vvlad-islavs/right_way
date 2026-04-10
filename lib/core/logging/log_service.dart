import 'dart:developer' as developer;

abstract interface class LogService {
  void info(String message, {String? tag});
  void warn(String message, {String? tag, Object? error, StackTrace? stackTrace});
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace});
}

class ConsoleLogService implements LogService {
  @override
  void info(String message, {String? tag}) {
    developer.log(
      message,
      name: _name(tag),
      level: 800, // INFO
    );
  }

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

  String _name(String? tag) {
    final t = tag?.trim();
    if (t == null || t.isEmpty) return 'right_way';
    return 'right_way.$t';
  }
}

