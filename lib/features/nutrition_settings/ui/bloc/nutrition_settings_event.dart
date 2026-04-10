import 'package:right_way/features/nutrition_settings/domain/domain.dart';

sealed class NutritionSettingsEvent {
  const NutritionSettingsEvent();

  const factory NutritionSettingsEvent.setDays(int days) = NutritionSettingsSetDays;
  const factory NutritionSettingsEvent.setExcluded(String raw) = NutritionSettingsSetExcluded;
  const factory NutritionSettingsEvent.setNotes(String notes) = NutritionSettingsSetNotes;
  const factory NutritionSettingsEvent.setGoal(NutritionGoal goal) = NutritionSettingsSetGoal;
  const factory NutritionSettingsEvent.setPlanName(String name) = NutritionSettingsSetPlanName;
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

final class NutritionSettingsSetGoal extends NutritionSettingsEvent {
  const NutritionSettingsSetGoal(this.goal);
  final NutritionGoal goal;
}

final class NutritionSettingsSetPlanName extends NutritionSettingsEvent {
  const NutritionSettingsSetPlanName(this.name);
  final String name;
}

final class NutritionSettingsCalculate extends NutritionSettingsEvent {
  const NutritionSettingsCalculate();
}

