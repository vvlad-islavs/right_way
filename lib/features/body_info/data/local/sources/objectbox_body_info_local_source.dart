import 'package:objectbox/objectbox.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/data/local/entities/entities.dart';
import 'package:right_way/features/body_info/data/local/mappers/mappers.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

import 'body_info_local_source.dart';

class ObjectBoxBodyInfoLocalSource implements BodyInfoLocalSource {
  ObjectBoxBodyInfoLocalSource(ObjectBoxStore store) : _box = store.store.box<BodyProfileDto>();

  final Box<BodyProfileDto> _box;

  BodyProfileDto? _getSingleton() {
    final q = _box.query().build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<BodyProfile> getProfile() async {
    _ensureSingleProfileRow();
    final dto = _getSingleton() ?? BodyProfileDto(heightCm: 170, weightKg: 70, age: 30);
    if (dto.id == 0) {
      _box.put(dto); // assigns ID
    }
    return dto.toEntity();
  }

  @override
  Future<BodyProfile> saveField(BodyField field, num value) async {
    final dto = _getSingleton() ?? BodyProfileDto(heightCm: 170, weightKg: 70, age: 30);
    switch (field) {
      case BodyField.heightCm:
        dto.heightCm = value.toDouble();
      case BodyField.weightKg:
        dto.weightKg = value.toDouble();
      case BodyField.age:
        dto.age = value.toInt();
    }
    _box.put(dto);
    return dto.toEntity();
  }

  /// If duplicates exist (e.g. race), keep the row with max id and remove the rest.
  void _ensureSingleProfileRow() {
    final all = _box.getAll();
    if (all.length <= 1) return;
    all.sort((a, b) => a.id.compareTo(b.id));
    final keep = all.last;
    for (final p in all) {
      if (p.id != keep.id) {
        _box.remove(p.id);
      }
    }
  }
}
