import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

import 'nutrition_plan_prompt_text.dart';
import 'nutrition_settings_remote_source.dart';

/// [NutritionSettingsRemoteSource] для OpenAI: chat completions с форматом json_object.
class OpenAiRemoteSource implements NutritionSettingsRemoteSource {
  /// Первый аргумент: HTTP-клиент Dio; [log] пишет строку перед запросом.
  OpenAiRemoteSource(this._dio, {required LogService log}) : _log = log;

  final Dio _dio;
  final LogService _log;

  /// Всегда [AiProvider.openAi].
  @override
  AiProvider get provider => AiProvider.openAi;

  /// Список из [supportedAiModels] для OpenAI.
  @override
  List<String> get supportedModels => supportedAiModels(provider);

  /// Chat completions с `response_format: json_object`; пустой [apiKey] дает [AppErrors.missingApiKey].
  @override
  Future<NutritionPlanResult> calculate(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw AppErrors.missingApiKey(AiProvider.openAi.title);
    }

    final prompt = _prompt(settings);

    try {
      _log.info('OpenAI request: model=$model', tag: 'nutrition');
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        data: <String, dynamic>{
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.2,
          'max_tokens': 2000,
          'response_format': {'type': 'json_object'},
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
        ),
      );

      final jsonText = _extractChatCompletionText(response.data);
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) return NutritionPlanResult(rawJson: decoded);
      if (decoded is Map) return NutritionPlanResult(rawJson: decoded.cast<String, dynamic>());
      throw const FormatException('OpenAI returned non-object JSON');
    } on FormatException catch (e) {
      throw AppErrors.invalidModelJson(AiProvider.openAi.title, error: e);
    } on DioException catch (e) {
      throw DioErrorMapper.forAiProvider(e, provider: AiProvider.openAi);
    }
  }

  /// Строка JSON из `choices[0].message.content` ответа OpenAI.
  String _extractChatCompletionText(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Empty OpenAI response');

    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final c0 = choices.first;
      if (c0 is Map) {
        final message = c0['message'];
        if (message is Map) {
          final content = message['content'];
          if (content is String && content.trim().isNotEmpty) return content.trim();
        }
      }
    }
    throw const FormatException('OpenAI chat response text missing');
  }

  /// Промпт в стиле OpenAI из [settings].
  String _prompt(NutritionSettings settings) {
    final excluded = settings.excludedFoods.isEmpty
        ? 'нет'
        : settings.excludedFoods.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
    final notes = settings.notes.trim().isEmpty ? 'нет' : settings.notes.trim();
    return NutritionPlanPromptText.buildOpenAiStylePrompt(
      days: settings.days,
      goal: settings.goal,
      excludedFoods: excluded,
      notes: notes,
    );
  }
}
