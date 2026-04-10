import 'package:right_way/features/today_plan/domain/models/meal_entity.dart';
import 'package:right_way/features/today_plan/domain/models/nutrition_totals_entity.dart';

class DayEntity {
  const DayEntity({
    required this.id,
    required this.weekDay,
    required this.dayIndex,
    required this.planId,
    required this.meals,
    this.dayNutrition,
  });

  final int id;
  final int weekDay;
  final int dayIndex;
  final int planId;
  final List<MealEntity> meals;
  final NutritionTotalsEntity? dayNutrition;
}
