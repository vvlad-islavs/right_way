import 'package:objectbox/objectbox.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/data/local/entities/entities.dart';
import 'package:right_way/features/body_info/data/local/mappers/mappers.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

import 'body_info_local_source.dart';

/// [BodyInfoLocalSource] на ObjectBox: одна строка профиля, дубликаты приводятся к одной записи.
class ObjectBoxBodyInfoLocalSource implements BodyInfoLocalSource {
  /// [store] должен содержать бокс [BodyProfileDto].
  ObjectBoxBodyInfoLocalSource(ObjectBoxStore store) : _box = store.store.box<BodyProfileDto>();

  final Box<BodyProfileDto> _box;

  /// Первая запись профиля из бокса или null, если таблица пустая.
  BodyProfileDto? _getSingleton() {
    final q = _box.query().build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  /// См. [BodyInfoLocalSource.getProfile]; при отсутствии строки создает значения по умолчанию.
  @override
  Future<BodyProfile> getProfile() async {
    _ensureSingleProfileRow();
    final dto = _getSingleton() ?? BodyProfileDto(heightCm: 170, weightKg: 70, age: 30);
    if (dto.id == 0) {
      _box.put(dto); // assigns ID
    }
    return dto.toEntity();
  }

  /// См. [BodyInfoLocalSource.saveField]; обновляет или создает единственную строку DTO.
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

  /// При нескольких строках профиля оставляет запись с максимальным id, остальные удаляет.
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
