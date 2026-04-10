import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/body_info.dart';

class BodyInfoBloc extends Bloc<BodyInfoEvent, BodyInfoState> {
  BodyInfoBloc({
    required BodyProfileUseCase bodyProfile,
    required ErrorReporter errors,
  })  : _bodyProfile = bodyProfile,
        _errors = errors,
        super(BodyInfoState.initial()) {
    on<BodyInfoStarted>(_onStarted);
    on<BodyInfoChangeHeightCm>((e, emit) => emit(state.copyWith(heightText: e.value, lastSavedField: null)));
    on<BodyInfoChangeWeightKg>((e, emit) => emit(state.copyWith(weightText: e.value, lastSavedField: null)));
    on<BodyInfoChangeAge>((e, emit) => emit(state.copyWith(ageText: e.value, lastSavedField: null)));
    on<BodyInfoSave>(_onSave);
  }

  final BodyProfileUseCase _bodyProfile;
  final ErrorReporter _errors;

  Future<void> _onStarted(BodyInfoStarted event, Emitter<BodyInfoState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, lastSavedField: null));
      final profile = await _bodyProfile.get();
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          heightText: profile.heightCm.toStringAsFixed(0),
          weightText: profile.weightKg.toStringAsFixed(1),
          ageText: profile.age.toString(),
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false, lastSavedField: null));
    }
  }

  Future<void> _onSave(BodyInfoSave event, Emitter<BodyInfoState> emit) async {
    num? parsed;
    switch (event.field) {
      case BodyField.heightCm:
        parsed = num.tryParse(state.heightText.replaceAll(',', '.'));
      case BodyField.weightKg:
        parsed = num.tryParse(state.weightText.replaceAll(',', '.'));
      case BodyField.age:
        parsed = num.tryParse(state.ageText);
    }
    if (parsed == null) {
      _errors.reportMessage('Некорректное значение');
      return;
    }

    try {
      final profile = await _bodyProfile.saveField(field: event.field, value: parsed);
      emit(state.copyWith(profile: profile, lastSavedField: event.field));
    } catch (_) {
      emit(state.copyWith(lastSavedField: null));
    }
  }
}

