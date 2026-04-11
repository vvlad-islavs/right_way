import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/domain/domain.dart';

import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({
    required AppSettingsUseCase settingsUsecase,
    required ErrorReporter errors,
    required AppTelemetry telemetry,
  }) : _errors = errors,
       _useCase = settingsUsecase,
       _telemetry = telemetry,
       super(const AppSettingsState.loading()) {
    load();
  }

  final AppSettingsUseCase _useCase;
  final ErrorReporter _errors;
  final AppTelemetry _telemetry;

  Future<void> load() async {
    emit(const AppSettingsState.loading());
    try {
      final snap = await _useCase.getAiSettings();
      emit(AppSettingsState(status: AppSettingsLoadStatus.ready, snapshot: snap));
    } catch (_) {
      emit(const AppSettingsState(status: AppSettingsLoadStatus.failure));
    }
  }

  Future<void> selectProvider(AiProvider provider) async {
    final snap = state.snapshot;
    if (snap?.provider == provider) return;
    emit(state.copyWith(providerSwitching: true, clearFeedback: true));
    try {
      final next = await _useCase.applyProviderSelection(provider);
      emit(state.copyWith(status: AppSettingsLoadStatus.ready, snapshot: next, providerSwitching: false));
      unawaited(_telemetry.logAiProviderChanged(provider.id));
    } catch (_) {
      emit(state.copyWith(providerSwitching: false));
    }
  }

  Future<void> selectModel(String model) async {
    final snap = state.snapshot;
    if (snap == null) return;
    final m = model.trim();
    try {
      await _useCase.persistSelectedModel(snap.provider, m);
      emit(
        state.copyWith(
          snapshot: AiUiSettingsSnapshot(provider: snap.provider, model: m, apiKey: snap.apiKey),
          clearFeedback: true,
        ),
      );
    } catch (_) {
      final err = AppErrors.failedSaveLocalData();
      _errors.reportMessage(uiMessage: err.uiMessage, logMessage: err.logMessage);
    }
  }

  Future<void> save(String apiKeyText) async {
    final snap = state.snapshot;
    if (snap == null) return;
    try {
      final refreshed = await _useCase.saveAiSettings(provider: snap.provider, apiKey: apiKeyText, model: snap.model);
      emit(AppSettingsState(status: AppSettingsLoadStatus.ready, snapshot: refreshed, feedback: 'Сохранено'));
      unawaited(_telemetry.logAiSettingsSaved(snap.provider.id));
    } catch (_) {
      final err = AppErrors.failedSaveLocalData();
      _errors.reportMessage(uiMessage: err.uiMessage, logMessage: err.logMessage);
    }
  }

  void clearFeedback() {
    if (state.feedback != null) {
      emit(state.copyWith(clearFeedback: true));
    }
  }
}
