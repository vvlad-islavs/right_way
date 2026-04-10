import 'dart:convert';

import 'package:right_way/features/today_plan/data/local/models/models.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

extension MealDtoMapper on MealDto {
  MealEntity toEntity() {
    final ingList = jsonDecode(ingredientsJson) as List<dynamic>? ?? [];
    final ingredients = ingList.map((e) {
      final m = e as Map<String, dynamic>;
      return IngredientEntity(
        name: m['name']?.toString() ?? '',
        amount: _asDouble(m['amount']),
        unit: m['unit']?.toString() ?? '',
      );
    }).toList();

    final stepList = jsonDecode(stepsJson) as List<dynamic>? ?? [];
    final steps = stepList.map((e) => e.toString()).toList();

    return MealEntity(
      type: mealType,
      title: title,
      ingredients: ingredients,
      steps: steps,
      nutrition: NutritionTotalsEntity(
        kcal: kcal,
        proteinG: proteinG,
        fatG: fatG,
        carbsG: carbsG,
      ),
    );
  }
}

double _asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
