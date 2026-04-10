import 'package:right_way/features/nutrition_settings/domain/domain.dart';

/// Shared OpenAI-chat-style instructions for Groq / OpenAI (same JSON shape).
class NutritionPlanPromptText {
  NutritionPlanPromptText._();

  static const jsonShapeLine =
      '{meta:{days:int,goal:"weightLoss|muscleGain|health",excludedFoods:string[]},plan:[{day:int,meals:[{type:"breakfast|lunch|dinner|snack",title:string,ingredients:[{name:string,amount:number,unit:"g|ml"}],steps:string[],nutrition:{kcal:number,protein_g:number,fat_g:number,carbs_g:number}}],dayNutrition:{kcal:number,protein_g:number,fat_g:number,carbs_g:number}}]}';

  static String goalPhrase(NutritionGoal goal) => switch (goal) {
        NutritionGoal.weightLoss => 'похудение (дефицит калорий)',
        NutritionGoal.muscleGain => 'набор массы (профицит калорий, высокий белок)',
        NutritionGoal.health => 'здоровье/поддержание (сбалансированно)',
      };

  static String buildGroqStylePrompt({
    required int days,
    required NutritionGoal goal,
    required String excludedFoods,
    required String notes,
  }) {
    return [
      'Return ONLY a single valid JSON object (no markdown, no code fences) with the following shape:',
      jsonShapeLine,
      '',
      'Days: $days',
      'Goal: ${goalPhrase(goal)}',
      'Excluded foods: $excludedFoods',
      'Notes: $notes',
    ].join('\n');
  }

  static String buildOpenAiStylePrompt({
    required int days,
    required NutritionGoal goal,
    required String excludedFoods,
    required String notes,
  }) {
    return [
      'Return ONLY a single valid JSON object (no markdown, no code fences).',
      'JSON shape:',
      jsonShapeLine,
      '',
      'Days: $days',
      'Goal: ${goalPhrase(goal)}',
      'Excluded foods: $excludedFoods',
      'Notes: $notes',
    ].join('\n');
  }
}
