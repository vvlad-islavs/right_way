import '../models/body_field.dart';
import '../models/body_profile.dart';

abstract interface class BodyInfoRepo {
  Future<BodyProfile> getProfile();
  Future<BodyProfile> saveField(BodyField field, num value);
}
