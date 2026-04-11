import 'package:right_way/features/nutrition_settings/domain/domain.dart';

class NutritionSettingsState {
  const NutritionSettingsState({
    required this.days,
    required this.excludedRaw,
    required this.notes,
    required this.goal,
    required this.planName,
    required this.isLoading,
    required this.result,
  });

  factory NutritionSettingsState.initial() => const NutritionSettingsState(
        days: 7,
        excludedRaw: '',
        notes: '',
        goal: NutritionGoal.health,
        planName: '',
        isLoading: false,
        result: null,
      );

  final int days;
  final String excludedRaw;
  final String notes;
  final NutritionGoal goal;
  final String planName;
  final bool isLoading;
  final NutritionPlanResult? result;

  NutritionSettingsState copyWith({
    int? days,
    String? excludedRaw,
    String? notes,
    NutritionGoal? goal,
    String? planName,
    bool? isLoading,
    NutritionPlanResult? result,
  }) {
    return NutritionSettingsState(
      days: days ?? this.days,
      excludedRaw: excludedRaw ?? this.excludedRaw,
      notes: notes ?? this.notes,
      goal: goal ?? this.goal,
      planName: planName ?? this.planName,
      isLoading: isLoading ?? this.isLoading,
      result: result
    );
  }
}

