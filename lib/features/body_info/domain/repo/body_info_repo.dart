import '../models/body_field.dart';
import '../models/body_profile.dart';

/// Репозиторий антропометрии: чтение и сохранение полей профиля тела.
abstract interface class BodyInfoRepo {
  /// Загрузить профиль (значения по умолчанию, если еще не сохраняли).
  Future<BodyProfile> getProfile();

  /// Сохранить одно поле [field] со значением [value].
  Future<BodyProfile> saveField(BodyField field, num value);
}
