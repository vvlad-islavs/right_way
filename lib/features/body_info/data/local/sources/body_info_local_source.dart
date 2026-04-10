import 'package:right_way/features/body_info/domain/domain.dart';

/// Локальное хранилище профиля тела (рост, вес, возраст).
abstract interface class BodyInfoLocalSource {
  /// См. [BodyInfoRepo.getProfile].
  Future<BodyProfile> getProfile();

  /// См. [BodyInfoRepo.saveField].
  Future<BodyProfile> saveField(BodyField field, num value);
}

