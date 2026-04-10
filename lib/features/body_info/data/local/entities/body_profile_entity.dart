import 'package:objectbox/objectbox.dart';

@Entity()
class BodyProfileDto {
  BodyProfileDto({
    this.id = 0,
    required this.heightCm,
    required this.weightKg,
    required this.age,
  });

  @Id()
  int id;
  double heightCm;
  double weightKg;
  int age;
}

