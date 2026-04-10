import 'dart:convert';

class GeminiHelpers {
  GeminiHelpers._();

  static String nutritionPlanPrompt({
    required int days,
    required String goal,
    required String excludedFoods,
    required String notes,
  }) {
    return [
      'You are a nutrition planner. Create a meal plan.',
      '',
      'Constraints:',
      '- Language of dish names: Russian.',
      '- Units: grams (g), milliliters (ml).',
      '- For each ingredient provide amount in grams/ml.',
      '- Avoid excluded foods strictly (also avoid obvious derivatives).',
      '- Keep recipes realistic and easy to cook at home.',
      '- Keep steps short: 3-6 steps per meal.',
      '- Provide 3 meals + 1 snack per day (breakfast, lunch, dinner, snack).',
      '',
      'User parameters:',
      '- Days: $days',
      '- Goal: $goal',
      '- Excluded foods: $excludedFoods',
      '- Notes/preferences: $notes',
      '',
      'Output requirements:',
      '- Output EXACTLY one JSON object that matches the schema.',
      '- Each day must include multiple meals; each meal must include full ingredient list with quantities.',
      '- Do not include any text outside JSON.',
    ].join('\n');
  }

  static Map<String, dynamic> nutritionPlanSchema() {
    return <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'meta': <String, dynamic>{
          'type': 'object',
          'properties': <String, dynamic>{
            'days': {'type': 'integer'},
            'goal': {
              'type': 'string',
              'enum': ['weightLoss', 'muscleGain', 'health'],
            },
            'excludedFoods': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['days', 'goal', 'excludedFoods'],
        },
        'plan': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'day': {'type': 'integer'},
              'meals': <String, dynamic>{
                'type': 'array',
                'items': <String, dynamic>{
                  'type': 'object',
                  'properties': <String, dynamic>{
                    'type': {
                      'type': 'string',
                      'enum': ['breakfast', 'lunch', 'dinner', 'snack'],
                    },
                    'title': {'type': 'string'},
                    'ingredients': <String, dynamic>{
                      'type': 'array',
                      'items': <String, dynamic>{
                        'type': 'object',
                        'properties': <String, dynamic>{
                          'name': {'type': 'string'},
                          'amount': {'type': 'number'},
                          'unit': {
                            'type': 'string',
                            'enum': ['g', 'ml'],
                          },
                          'note': {'type': 'string'},
                        },
                        'required': ['name', 'amount', 'unit'],
                      },
                    },
                    'steps': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                    'nutrition': <String, dynamic>{
                      'type': 'object',
                      'properties': <String, dynamic>{
                        'kcal': {'type': 'number'},
                        'protein_g': {'type': 'number'},
                        'fat_g': {'type': 'number'},
                        'carbs_g': {'type': 'number'},
                      },
                      'required': ['kcal', 'protein_g', 'fat_g', 'carbs_g'],
                    },
                  },
                  'required': ['type', 'title', 'ingredients', 'steps', 'nutrition'],
                },
              },
              'dayNutrition': <String, dynamic>{
                'type': 'object',
                'properties': <String, dynamic>{
                  'kcal': {'type': 'number'},
                  'protein_g': {'type': 'number'},
                  'fat_g': {'type': 'number'},
                  'carbs_g': {'type': 'number'},
                },
                'required': ['kcal', 'protein_g', 'fat_g', 'carbs_g'],
              },
            },
            'required': ['day', 'meals', 'dayNutrition'],
          },
        },
      },
      'required': ['meta', 'plan'],
    };
  }

  static String extractCandidateText(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Empty Gemini response');

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const FormatException('Gemini response: candidates[] missing');
    }

    final content = (candidates.first as Map?)?['content'];
    final parts = (content as Map?)?['parts'];

    String? firstText;
    if (parts is List && parts.isNotEmpty) {
      final firstPart = parts.first;
      if (firstPart is Map) {
        final text = firstPart['text'];
        if (text is String) firstText = text;
      }
    }

    final text = (firstText ?? '').trim();
    if (text.isEmpty) {
      throw const FormatException('Gemini response text is empty');
    }
    return text;
  }

  static Map<String, dynamic> decodeJsonObject(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw FormatException('Gemini returned non-object JSON: ${decoded.runtimeType}');
  }
}
