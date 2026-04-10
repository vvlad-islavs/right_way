import 'package:right_way/features/today_plan/domain/domain.dart';

abstract interface class TodayPlanLocalSource {
  Future<void> persistFromAiResponse(Map<String, dynamic> rawJson, String planName);

  Future<DayEntity?> loadActivePlanDayForWeekday(int weekDay);

  Future<List<DayEntity>> loadActivePlanAllDaysSorted();

  Future<List<PlanSummary>> listPlans();

  Future<void> setActivePlanId(int planId);

  Future<String?> resolvedActivePlanTitle();

  Future<void> deletePlan(int planId);
}
