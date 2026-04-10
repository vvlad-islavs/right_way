import 'package:right_way/features/body_info/data/local/entities/entities.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

extension BodyProfileDtoMapper on BodyProfileDto {
  BodyProfile toEntity() => BodyProfile(heightCm: heightCm, weightKg: weightKg, age: age);
}
