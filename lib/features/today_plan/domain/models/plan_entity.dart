import 'package:right_way/features/today_plan/domain/models/day_entity.dart';

class PlanEntity {
  const PlanEntity({
    required this.id,
    required this.name,
    required this.isActive,
    required this.dayIds,
    required this.metaDays,
    required this.goal,
    required this.excludedFoods,
    required this.createdAtMs,
    required this.days,
  });

  final int id;
  final String name;
  final bool isActive;
  final List<int> dayIds;
  final int metaDays;
  final String goal;
  final List<String> excludedFoods;
  final int createdAtMs;
  final List<DayEntity> days;
}
