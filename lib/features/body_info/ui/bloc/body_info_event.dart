import 'package:right_way/features/body_info/domain/domain.dart';

sealed class BodyInfoEvent {
  const BodyInfoEvent();

  const factory BodyInfoEvent.started() = BodyInfoStarted;

  const factory BodyInfoEvent.changeHeightCm(String value) = BodyInfoChangeHeightCm;
  const factory BodyInfoEvent.changeWeightKg(String value) = BodyInfoChangeWeightKg;
  const factory BodyInfoEvent.changeAge(String value) = BodyInfoChangeAge;

  const factory BodyInfoEvent.save(BodyField field) = BodyInfoSave;
}

final class BodyInfoStarted extends BodyInfoEvent {
  const BodyInfoStarted();
}

final class BodyInfoChangeHeightCm extends BodyInfoEvent {
  const BodyInfoChangeHeightCm(this.value);
  final String value;
}

final class BodyInfoChangeWeightKg extends BodyInfoEvent {
  const BodyInfoChangeWeightKg(this.value);
  final String value;
}

final class BodyInfoChangeAge extends BodyInfoEvent {
  const BodyInfoChangeAge(this.value);
  final String value;
}

final class BodyInfoSave extends BodyInfoEvent {
  const BodyInfoSave(this.field);
  final BodyField field;
}

