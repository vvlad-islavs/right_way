import 'package:right_way/features/body_info/domain/domain.dart';

sealed class BodyInfoEvent {
  const BodyInfoEvent();

  const factory BodyInfoEvent.started() = BodyInfoStarted;

  /// [raw] — текущая строка из [TextEditingController] на момент сохранения.
  const factory BodyInfoEvent.save({required BodyField field, required String raw}) = BodyInfoSave;
}

final class BodyInfoStarted extends BodyInfoEvent {
  const BodyInfoStarted();
}

final class BodyInfoSave extends BodyInfoEvent {
  const BodyInfoSave({required this.field, required this.raw});
  final BodyField field;
  final String raw;
}

