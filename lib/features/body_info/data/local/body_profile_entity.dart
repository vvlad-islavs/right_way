import 'package:objectbox/objectbox.dart';

@Entity()
class BodyProfileEntity {
  BodyProfileEntity({
    this.id = 0,
    required this.heightCm,
    required this.weightKg,
    required this.age,
  });

  int id;
  double heightCm;
  double weightKg;
  int age;
}

