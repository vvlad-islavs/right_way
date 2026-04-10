import 'package:right_way/features/body_info/body_info.dart';

class BodyInfoRepoImpl implements BodyInfoRepo {
  BodyInfoRepoImpl(this._local);

  final BodyInfoLocalSource _local;

  @override
  Future<BodyProfile> getProfile() => _local.getProfile();

  @override
  Future<BodyProfile> saveField(BodyField field, num value) => _local.saveField(field, value);
}

