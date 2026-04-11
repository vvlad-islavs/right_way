import 'package:dio/dio.dart';
import 'package:right_way/core/ai/ai.dart';
import 'package:right_way/core/errors/app_errors.dart';
import 'package:right_way/core/l10n/l10n_scope.dart';

import 'provider_response_parse.dart';

class DioErrorMapper {
  DioErrorMapper._();

  /// Maps HTTP/Dio failures to [AppException] using short UI and a detailed log line.
  static AppException forAiProvider(
    DioException e, {
    required AiProvider provider,
  }) {
    final l10n = appL10n();
    final status = e.response?.statusCode;
    final title = provider.title;
    final data = e.response?.data;
    final apiMsg = switch (provider) {
      AiProvider.gemini => extractGeminiApiErrorMessage(data),
      AiProvider.openAi || AiProvider.groq => extractOpenAiStyleApiErrorMessage(data),
    };
    final apiCode = switch (provider) {
      AiProvider.openAi || AiProvider.groq => extractOpenAiStyleApiErrorCode(data),
      AiProvider.gemini => null,
    };

    if (provider == AiProvider.gemini && status == 429) {
      final msg = apiMsg ?? '';
      final isFreeTierZero = msg.contains('limit: 0') || msg.contains('free_tier');
      return AppException(
        uiMessage: isFreeTierZero ? AppErrors.geminiFreeTierZeroUi : AppErrors.geminiRateLimitedUi,
        logMessage: _fullLog(
          provider: provider,
          e: e,
          status: status,
          apiMessage: apiMsg,
          note: 'Gemini 429',
        ),
      );
    }

    if (status == 400) {
      final decommissioned = apiCode == 'model_decommissioned' ||
          (apiMsg?.toLowerCase().contains('decommissioned') ?? false) ||
          (apiMsg?.toLowerCase().contains('no longer supported') ?? false);
      final ui = decommissioned
          ? l10n.errorAiBadRequestDecommissioned(title)
          : l10n.errorAiBadRequestGeneric(title);
      return AppException(
        uiMessage: ui,
        logMessage: _fullLog(
          provider: provider,
          e: e,
          status: status,
          apiMessage: apiMsg,
          apiCode: apiCode,
        ),
      );
    }

    final ui = switch (status) {
      401 || 403 => l10n.errorAiAuth(title),
      429 => l10n.errorAiRateLimit(title),
      _ when status != null && status >= 500 => l10n.errorAiServer(title),
      _ => l10n.errorAiNetwork(title),
    };

    return AppException(
      uiMessage: ui,
      logMessage: _fullLog(provider: provider, e: e, status: status, apiMessage: apiMsg, apiCode: apiCode),
    );
  }

  /// When provider is unknown (e.g. use case fallback).
  static AppException fallback(DioException e) {
    final data = e.response?.data;
    return AppException(
      uiMessage: appL10n().errorGeneric,
      logMessage: _fullLog(
        provider: null,
        e: e,
        status: e.response?.statusCode,
        apiMessage:
            extractOpenAiStyleApiErrorMessage(data) ?? extractGeminiApiErrorMessage(data),
        apiCode: extractOpenAiStyleApiErrorCode(data),
      ),
    );
  }

  static String _dioBriefMessage(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      return 'HTTP ${e.response?.statusCode ?? "?"}';
    }
    return e.message ?? e.toString();
  }

  static String _fullLog({
    required DioException e,
    required int? status,
    required String? apiMessage,
    AiProvider? provider,
    String? note,
    String? apiCode,
  }) {
    final buf = StringBuffer();
    if (note != null) buf.write('$note; ');
    if (provider != null) buf.write('provider=${provider.id}; ');
    buf.write('dioType=${e.type}; status=$status; dioMessage=${_dioBriefMessage(e)}; ');
    if (apiCode != null && apiCode.isNotEmpty) buf.write('apiCode=$apiCode; ');
    if (apiMessage != null && apiMessage.isNotEmpty) buf.write('apiMessage="$apiMessage"; ');
    buf.write('data=${e.response?.data}');
    return buf.toString();
  }
}
