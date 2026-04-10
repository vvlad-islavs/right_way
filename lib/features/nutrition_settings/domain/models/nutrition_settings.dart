class NutritionSettings {
  const NutritionSettings({
    required this.days,
    required this.excludedFoods,
    required this.notes,
  });

  final int days;
  final List<String> excludedFoods;
  final String notes;
}

