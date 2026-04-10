import 'package:right_way/features/nutrition_settings/domain/domain.dart';

class NutritionSettingsState {
  const NutritionSettingsState({
    required this.days,
    required this.excludedRaw,
    required this.notes,
    required this.isLoading,
    required this.result,
  });

  factory NutritionSettingsState.initial() => const NutritionSettingsState(
        days: 7,
        excludedRaw: '',
        notes: '',
        isLoading: false,
        result: null,
      );

  final int days;
  final String excludedRaw;
  final String notes;
  final bool isLoading;
  final NutritionPlanResult? result;

  NutritionSettingsState copyWith({
    int? days,
    String? excludedRaw,
    String? notes,
    bool? isLoading,
    NutritionPlanResult? result,
  }) {
    return NutritionSettingsState(
      days: days ?? this.days,
      excludedRaw: excludedRaw ?? this.excludedRaw,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
    );
  }
}

