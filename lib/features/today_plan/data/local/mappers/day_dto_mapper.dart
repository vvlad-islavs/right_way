import 'package:right_way/features/today_plan/data/local/models/models.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

import 'meal_dto_mapper.dart';

extension DayDtoMapper on DayDto {
  DayEntity toEntity() {
    final mealEntities = meals.map((m) => m.toEntity()).toList();
    final planId = plan.targetId;

    NutritionTotalsEntity? dayNutrition;
    if (dayKcal > 0 || dayProteinG > 0 || dayFatG > 0 || dayCarbsG > 0) {
      dayNutrition = NutritionTotalsEntity(kcal: dayKcal, proteinG: dayProteinG, fatG: dayFatG, carbsG: dayCarbsG);
    }

    return DayEntity(
      id: id,
      weekDay: weekDay,
      dayIndex: dayIndex,
      planId: planId,
      meals: mealEntities,
      dayNutrition: dayNutrition,
    );
  }
}
