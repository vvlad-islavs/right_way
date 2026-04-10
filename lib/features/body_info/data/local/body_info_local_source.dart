import 'package:right_way/features/body_info/domain/domain.dart';

abstract interface class BodyInfoLocalSource {
  Future<BodyProfile> getProfile();
  Future<BodyProfile> saveField(BodyField field, num value);
}

