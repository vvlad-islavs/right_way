import 'package:right_way/features/body_info/data/local/sources/sources.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

/// [BodyInfoRepo], делегирующий хранение в [BodyInfoLocalSource].
class BodyInfoRepoImpl implements BodyInfoRepo {
  /// Источник данных профиля тела.
  BodyInfoRepoImpl(this._local);

  final BodyInfoLocalSource _local;

  /// Делегирует [BodyInfoLocalSource.getProfile].
  @override
  Future<BodyProfile> getProfile() => _local.getProfile();

  /// Делегирует [BodyInfoLocalSource.saveField].
  @override
  Future<BodyProfile> saveField(BodyField field, num value) => _local.saveField(field, value);
}
