import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

import 'nutrition_plan_prompt_text.dart';
import 'nutrition_settings_remote_source.dart';

/// [NutritionSettingsRemoteSource] для Groq: при длинном плане режет запросы на части и склеивает JSON.
class GroqRemoteSource implements NutritionSettingsRemoteSource {
  /// Первый аргумент: HTTP-клиент Dio; [log] для журнала запросов по частям.
  GroqRemoteSource(this._dio, {required LogService log}) : _log = log;

  final Dio _dio;
  final LogService _log;

  /// Всегда [AiProvider.groq].
  @override
  AiProvider get provider => AiProvider.groq;

  /// Список из [supportedAiModels] для Groq.
  @override
  List<String> get supportedModels => supportedAiModels(provider);

  /// Один запрос при коротком плане; иначе параллельные куски по дням и слияние поля `plan`.
  @override
  Future<NutritionPlanResult> calculate(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw AppErrors.missingApiKey(AiProvider.groq.title);
    }

    const chunkDays = 2;
    if (settings.days <= chunkDays) {
      final data = await _requestPlan(settings, apiKey: key, model: model);
      return NutritionPlanResult(rawJson: data);
    }

    final totalDays = settings.days;
    final chunks = <({int offset, int days, NutritionSettings settings})>[];
    var offset = 0;
    while (offset < totalDays) {
      final take = (totalDays - offset) >= chunkDays ? chunkDays : (totalDays - offset);
      chunks.add((
        offset: offset,
        days: take,
        settings: NutritionSettings(
          days: take,
          excludedFoods: settings.excludedFoods,
          notes: settings.notes,
          goal: settings.goal,
          planName: settings.planName,
        ),
      ));
      offset += take;
    }

    _log.info('Groq parallel chunks: ${chunks.length} (days=$totalDays)', tag: 'nutrition');

    final results = await Future.wait(
      chunks.map((c) async {
        _log.info('Groq chunk request: days=${c.days} offset=${c.offset} model=$model', tag: 'nutrition');
        final json = await _requestPlan(c.settings, apiKey: key, model: model);
        return (offset: c.offset, json: json);
      }),
    );

    results.sort((a, b) => a.offset.compareTo(b.offset));

    final mergedPlan = <Map<String, dynamic>>[];
    for (final r in results) {
      final plan = r.json['plan'];
      if (plan is! List) {
        throw AppErrors.groqChunkMissingPlan(json: r.json);
      }

      for (final item in plan) {
        if (item is! Map) continue;
        final mapped = item.cast<String, dynamic>();
        final day = mapped['day'];
        if (day is int) {
          mapped['day'] = day + r.offset;
        }
        mergedPlan.add(mapped);
      }
    }

    return NutritionPlanResult(
      rawJson: {
        'meta': {'days': settings.days, 'goal': settings.goal.name, 'excludedFoods': settings.excludedFoods},
        'plan': mergedPlan,
      },
    );
  }

  /// Один POST к Groq для [settings] с заданным [apiKey] и [model].
  Future<Map<String, dynamic>> _requestPlan(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  }) async {
    final prompt = _prompt(settings);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.groq.com/openai/v1/chat/completions',
        data: <String, dynamic>{
          'model': model,
          'temperature': 0.2,
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        },
        options: Options(headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'}),
      );

      final rawText = _extractText(response.data);
      final jsonText = _extractJsonObjectText(rawText);
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      throw const FormatException('Groq returned non-object JSON');
    } on FormatException catch (e) {
      throw AppErrors.invalidModelJson(AiProvider.groq.title, error: e);
    } on DioException catch (e) {
      throw DioErrorMapper.forAiProvider(e, provider: AiProvider.groq);
    }
  }

  /// Выделяет первый JSON-объект верхнего уровня из произвольного текста модели.
  String _extractJsonObjectText(String text) {
    final start = text.indexOf('{');
    if (start == -1) return text.trim();

    var depth = 0;
    var inString = false;
    var escape = false;

    for (var i = start; i < text.length; i++) {
      final ch = text.codeUnitAt(i);

      if (escape) {
        escape = false;
        continue;
      }
      if (ch == 0x5C /* \ */) {
        if (inString) escape = true;
        continue;
      }
      if (ch == 0x22 /* " */) {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == 0x7B /* { */) depth++;
      if (ch == 0x7D /* } */) depth--;
      if (depth == 0) {
        return text.substring(start, i + 1).trim();
      }
    }

    return text.substring(start).trim();
  }

  /// Текст ответа из `choices[0].message.content` тела Groq.
  String _extractText(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Empty Groq response');
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
    throw const FormatException('Groq response text missing');
  }

  /// Промпт в стиле Groq из [settings].
  String _prompt(NutritionSettings settings) {
    final excluded = settings.excludedFoods.isEmpty
        ? 'нет'
        : settings.excludedFoods.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
    final notes = settings.notes.trim().isEmpty ? 'нет' : settings.notes.trim();

    return NutritionPlanPromptText.buildGroqStylePrompt(
      days: settings.days,
      goal: settings.goal,
      excludedFoods: excluded,
      notes: notes,
    );
  }
}
