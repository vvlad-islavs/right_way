import 'package:objectbox/objectbox.dart';
import 'package:right_way/features/body_info/body_info.dart';

class ObjectBoxBodyInfoLocalSource implements BodyInfoLocalSource {
  ObjectBoxBodyInfoLocalSource(this._box);

  final Box<BodyProfileEntity> _box;

  @override
  Future<BodyProfile> getProfile() async {
    final entity = _box.get(1) ?? BodyProfileEntity(heightCm: 170, weightKg: 70, age: 30)..id = 1;
    if (entity.id == 0) {
      entity.id = 1;
    }
    _box.put(entity);
    return BodyProfile(
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      age: entity.age,
    );
  }

  @override
  Future<BodyProfile> saveField(BodyField field, num value) async {
    final entity = _box.get(1) ?? BodyProfileEntity(heightCm: 170, weightKg: 70, age: 30)..id = 1;
    switch (field) {
      case BodyField.heightCm:
        entity.heightCm = value.toDouble();
      case BodyField.weightKg:
        entity.weightKg = value.toDouble();
      case BodyField.age:
        entity.age = value.toInt();
    }
    entity.id = 1;
    _box.put(entity);
    return BodyProfile(heightCm: entity.heightCm, weightKg: entity.weightKg, age: entity.age);
  }
}

