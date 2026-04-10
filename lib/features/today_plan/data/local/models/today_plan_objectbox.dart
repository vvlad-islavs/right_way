import 'package:objectbox/objectbox.dart';

@Entity()
class PlanDto {
  PlanDto({
    this.id = 0,
    this.name = '',
    this.isActive = false,
    this.metaDays = 0,
    this.goal = '',
    this.excludedFoodsJson = '[]',
    this.dayIdsCsv = '',
    this.createdAtMs = 0,
  });

  @Id()
  int id;
  String name;
  bool isActive;
  int metaDays;
  String goal;
  String excludedFoodsJson;
  String dayIdsCsv;
  int createdAtMs;

  @Backlink('plan')
  final days = ToMany<DayDto>();
}

@Entity()
class DayDto {
  DayDto({
    this.id = 0,
    this.weekDay = 1,
    this.dayIndex = 1,
    this.dayKcal = 0,
    this.dayProteinG = 0,
    this.dayFatG = 0,
    this.dayCarbsG = 0,
  });

  @Id()
  int id;
  int weekDay;
  int dayIndex;
  double dayKcal;
  double dayProteinG;
  double dayFatG;
  double dayCarbsG;

  final plan = ToOne<PlanDto>();

  @Backlink('day')
  final meals = ToMany<MealDto>();
}

@Entity()
class MealDto {
  MealDto({
    this.id = 0,
    this.mealType = '',
    this.title = '',
    this.ingredientsJson = '[]',
    this.stepsJson = '[]',
    this.kcal = 0,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
  });

  @Id()
  int id;
  String mealType;
  String title;
  String ingredientsJson;
  String stepsJson;
  double kcal;
  double proteinG;
  double fatG;
  double carbsG;

  final day = ToOne<DayDto>();
}
