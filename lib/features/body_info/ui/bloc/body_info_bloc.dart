import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/body_info.dart';

class BodyInfoBloc extends Bloc<BodyInfoEvent, BodyInfoState> {
  BodyInfoBloc({
    required BodyProfileUseCase bodyProfile,
    required ErrorReporter errors,
    required AppTelemetry telemetry,
  })  : _bodyProfile = bodyProfile,
        _errors = errors,
        _telemetry = telemetry,
        super(BodyInfoState.initial()) {
    on<BodyInfoStarted>(_onStarted);
    on<BodyInfoSave>(_onSave);
  }

  final BodyProfileUseCase _bodyProfile;
  final ErrorReporter _errors;
  final AppTelemetry _telemetry;

  Future<void> _onStarted(BodyInfoStarted event, Emitter<BodyInfoState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
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
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onSave(BodyInfoSave event, Emitter<BodyInfoState> emit) async {

    final normalized = event.raw.trim().replaceAll(',', '.');
    final parsed = num.tryParse(normalized);
    if (parsed == null) {
      final err = AppErrors.invalidBodyFieldValue();
      _errors.reportMessage(uiMessage: err.uiMessage, logMessage: err.logMessage);
      return;
    } 

    try {
      emit(state.copyWith(isLoading: true));

      final profile = await _bodyProfile.saveField(field: event.field, value: parsed);
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          heightText: profile.heightCm.toStringAsFixed(0),
          weightText: profile.weightKg.toStringAsFixed(1),
          ageText: profile.age.toString(),
        ),
      );
      unawaited(_telemetry.logBodySaved(field: event.field.name));
    } catch (_) {
      final err = AppErrors.failedSaveLocalData();
      _errors.reportMessage(uiMessage: err.uiMessage, logMessage: err.logMessage);
      unawaited(_telemetry.logBodySaveFailed(field: event.field.name));
    }
  }
}
