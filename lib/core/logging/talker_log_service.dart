import 'package:right_way/core/logging/log_service.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerLogService implements LogService {
  TalkerLogService(this._talker);

  final Talker _talker;

  @override
  void info(String message, {String? tag}) {
    _talker.info(_withTag(message, tag));
  }

  @override
  void warn(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _talker.warning(_withTag(message, tag), error, stackTrace);
  }

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _talker.error(_withTag(message, tag), error, stackTrace);
  }

  String _withTag(String message, String? tag) {
    final t = tag?.trim();
    if (t == null || t.isEmpty) return message;
    return '[$t] $message';
  }
}

