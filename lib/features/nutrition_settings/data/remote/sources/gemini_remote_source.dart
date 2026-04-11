import 'package:dio/dio.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';

import 'nutrition_plan_prompt_text.dart';
import 'nutrition_settings_remote_source.dart';

/// [NutritionSettingsRemoteSource] для Google Gemini: структурированный JSON по схеме плана.
/// * Не используется, тк Gemini не дает триал периода, оставляен как пример возможной реализации
class GeminiRemoteSource implements NutritionSettingsRemoteSource {
  /// Первый аргумент: HTTP-клиент Dio; [log] для диагностических сообщений.
  GeminiRemoteSource(this._dio, {required LogService log}) : _log = log;

  final Dio _dio;
  final LogService _log;

  /// Всегда [AiProvider.gemini].
  @override
  AiProvider get provider => AiProvider.gemini;

  /// Список из [supportedAiModels] для Gemini.
  @override
  List<String> get supportedModels => supportedAiModels(provider);

  /// Запрос generateContent со схемой ответа; при пустом [apiKey] бросает [AppErrors.missingApiKey].
  @override
  Future<NutritionPlanResult> calculate(
    NutritionSettings settings, {
    required String apiKey,
    required String model,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw AppErrors.missingApiKey(AiProvider.gemini.title);
    }

    final prompt = _prompt(settings);
    final schema = GeminiHelpers.nutritionPlanSchema();

    try {
      _log.info('Gemini request: model=$model', tag: 'nutrition');
      final json = await _generateStructuredJson(prompt: prompt, schema: schema, apiKey: key, model: model);
      return NutritionPlanResult(rawJson: json);
    } on DioException catch (e) {
      throw DioErrorMapper.forAiProvider(e, provider: AiProvider.gemini);
    } on FormatException catch (e) {
      throw AppErrors.invalidModelJson(AiProvider.gemini.title, error: e);
    }
  }

  /// Один вызов API: [prompt], [schema], ключ и [model]; возвращает распарсенный JSON-объект.
  Future<Map<String, dynamic>> _generateStructuredJson({
    required String prompt,
    required Map<String, dynamic> schema,
    required String apiKey,
    required String model,
  }) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
      {'key': apiKey},
    );

    final response = await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: <String, dynamic>{
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': <String, dynamic>{
          'temperature': 0.2,
          'topP': 0.9,
          'maxOutputTokens': 2048,
          'responseMimeType': 'application/json',
          'responseSchema': schema,
        },
      },
      options: Options(headers: const {'Content-Type': 'application/json'}),
    );

    final jsonText = GeminiHelpers.extractCandidateText(response.data);
    return GeminiHelpers.decodeJsonObject(jsonText);
  }

  /// Текст промпта из полей [settings] для модели Gemini.
  String _prompt(NutritionSettings settings) {
    final excluded = settings.excludedFoods.isEmpty
        ? 'нет'
        : settings.excludedFoods.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
    final notes = settings.notes.trim().isEmpty ? 'нет' : settings.notes.trim();

    return GeminiHelpers.nutritionPlanPrompt(
      days: settings.days,
      goal: NutritionPlanPromptText.goalPhrase(settings.goal),
      excludedFoods: excluded,
      notes: notes,
    );
  }
}
