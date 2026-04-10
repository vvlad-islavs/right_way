import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/domain/domain.dart';
import 'package:right_way/features/nutrition_settings/ui/bloc/nutrition_settings_event.dart';
import 'package:right_way/features/nutrition_settings/ui/bloc/nutrition_settings_state.dart';

class NutritionSettingsBloc extends Bloc<NutritionSettingsEvent, NutritionSettingsState> {
  NutritionSettingsBloc({
    required CalculatePlanUseCase calculatePlan,
    required ErrorReporter errors,
  })  : _calculatePlan = calculatePlan,
        _errors = errors,
        super(NutritionSettingsState.initial()) {
    on<NutritionSettingsSetDays>((e, emit) => emit(state.copyWith(days: e.days)));
    on<NutritionSettingsSetExcluded>((e, emit) => emit(state.copyWith(excludedRaw: e.raw)));
    on<NutritionSettingsSetNotes>((e, emit) => emit(state.copyWith(notes: e.notes)));
    on<NutritionSettingsSetGoal>((e, emit) => emit(state.copyWith(goal: e.goal)));
    on<NutritionSettingsSetPlanName>((e, emit) => emit(state.copyWith(planName: e.name)));
    on<NutritionSettingsCalculate>(_onCalculate);
  }

  final CalculatePlanUseCase _calculatePlan;
  final ErrorReporter _errors;

  Future<void> _onCalculate(NutritionSettingsCalculate event, Emitter<NutritionSettingsState> emit) async {
    if (state.planName.trim().isEmpty) {
      final err = AppErrors.emptyPlanName();
      _errors.reportMessage(uiMessage: err.uiMessage, logMessage: err.logMessage);
      return;
    }

    final excluded = state.excludedRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    try {
      emit(state.copyWith(isLoading: true, result: null));
      final result = await _calculatePlan.call(
        NutritionSettings(
          days: state.days,
          excludedFoods: excluded,
          notes: state.notes,
          goal: state.goal,
          planName: state.planName.trim(),
        ),
      );
      emit(state.copyWith(isLoading: false, result: result));
    } catch (_) {
      emit(state.copyWith(isLoading: false, result: null));
    }
  }
}
