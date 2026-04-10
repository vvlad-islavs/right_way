sealed class NutritionSettingsEvent {
  const NutritionSettingsEvent();

  const factory NutritionSettingsEvent.setDays(int days) = NutritionSettingsSetDays;
  const factory NutritionSettingsEvent.setExcluded(String raw) = NutritionSettingsSetExcluded;
  const factory NutritionSettingsEvent.setNotes(String notes) = NutritionSettingsSetNotes;
  const factory NutritionSettingsEvent.calculate() = NutritionSettingsCalculate;
}

final class NutritionSettingsSetDays extends NutritionSettingsEvent {
  const NutritionSettingsSetDays(this.days);
  final int days;
}

final class NutritionSettingsSetExcluded extends NutritionSettingsEvent {
  const NutritionSettingsSetExcluded(this.raw);
  final String raw;
}

final class NutritionSettingsSetNotes extends NutritionSettingsEvent {
  const NutritionSettingsSetNotes(this.notes);
  final String notes;
}

final class NutritionSettingsCalculate extends NutritionSettingsEvent {
  const NutritionSettingsCalculate();
}

