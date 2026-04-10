import 'package:right_way/features/body_info/domain/domain.dart';

class BodyInfoState {
  const BodyInfoState({
    required this.isLoading,
    required this.profile,
    required this.heightText,
    required this.weightText,
    required this.ageText,
    required this.lastSavedField,
  });

  factory BodyInfoState.initial() => const BodyInfoState(
        isLoading: true,
        profile: null,
        heightText: '',
        weightText: '',
        ageText: '',
        lastSavedField: null,
      );

  final bool isLoading;
  final BodyProfile? profile;
  final String heightText;
  final String weightText;
  final String ageText;
  final BodyField? lastSavedField;

  BodyInfoState copyWith({
    bool? isLoading,
    BodyProfile? profile,
    String? heightText,
    String? weightText,
    String? ageText,
    BodyField? lastSavedField,
  }) {
    return BodyInfoState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      heightText: heightText ?? this.heightText,
      weightText: weightText ?? this.weightText,
      ageText: ageText ?? this.ageText,
      lastSavedField: lastSavedField,
    );
  }
}

