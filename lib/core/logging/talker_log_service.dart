import 'package:right_way/core/logging/log_service.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// [LogService] на базе Talker: удобно для отладки и экрана логов в приложении.
class TalkerLogService implements LogService {
  /// [talker] получает все сообщения этого сервиса.
  TalkerLogService(this._talker);

  final Talker _talker;

  /// Сообщение с префиксом тега при непустом [tag].
  @override
  void info(String message, {String? tag}) {
    _talker.info(_withTag(message, tag));
  }

  /// Предупреждение Talker с тегом в тексте.
  @override
  void warn(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _talker.warning(_withTag(message, tag), error, stackTrace);
  }

  /// Ошибка Talker с тегом в тексте.
  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _talker.error(_withTag(message, tag), error, stackTrace);
  }

  /// Возвращает [message] или `[tag] message`, если [tag] не пустой.
  String _withTag(String message, String? tag) {
    final t = tag?.trim();
    if (t == null || t.isEmpty) return message;
    return '[$t] $message';
  }
}

