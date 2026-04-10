import 'package:right_way/features/app_settings/domain/domain.dart';

enum AppSettingsLoadStatus { loading, ready, failure }

class AppSettingsState {
  const AppSettingsState({
    required this.status,
    this.snapshot,
    this.providerSwitching = false,
    this.feedback,
  });

  const AppSettingsState.loading() : this(status: AppSettingsLoadStatus.loading);

  final AppSettingsLoadStatus status;
  final AiUiSettingsSnapshot? snapshot;
  final bool providerSwitching;

  /// Одноразовое сообщение для SnackBar (после показа сбрасывается через [copyWith]).
  final String? feedback;

  AppSettingsState copyWith({
    AppSettingsLoadStatus? status,
    AiUiSettingsSnapshot? snapshot,
    bool? providerSwitching,
    String? feedback,
    bool clearFeedback = false,
  }) {
    return AppSettingsState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      providerSwitching: providerSwitching ?? this.providerSwitching,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}
