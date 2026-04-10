import 'package:right_way/features/today_plan/domain/models/ingredient_entity.dart';
import 'package:right_way/features/today_plan/domain/models/nutrition_totals_entity.dart';

class MealEntity {
  const MealEntity({
    required this.type,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
  });

  final String type;
  final String title;
  final List<IngredientEntity> ingredients;
  final List<String> steps;
  final NutritionTotalsEntity nutrition;
}
