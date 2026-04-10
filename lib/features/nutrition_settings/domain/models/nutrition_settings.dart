enum NutritionGoal {
  weightLoss,
  muscleGain,
  health,
}

class NutritionSettings {
  const NutritionSettings({
    required this.days,
    required this.excludedFoods,
    required this.notes,
    required this.goal,
    required this.planName,
  });

  final int days;
  final List<String> excludedFoods;
  final String notes;
  final NutritionGoal goal;
  final String planName;
}

