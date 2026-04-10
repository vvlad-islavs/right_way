import 'package:right_way/features/today_plan/domain/domain.dart';

class TodayPlanUseCase {
  TodayPlanUseCase(this._local);

  final TodayPlanLocalSource _local;

  Future<DayEntity?> loadToday() {
    final wd = DateTime.now().weekday;
    return _local.loadActivePlanDayForWeekday(wd);
  }

  Future<List<DayEntity>> loadActivePlanAllDays() => _local.loadActivePlanAllDaysSorted();

  Future<String?> activePlanTitle() => _local.resolvedActivePlanTitle();

  Future<List<PlanSummary>> listPlans() => _local.listPlans();

  Future<void> setActivePlanAsActive(int planId) => _local.setActivePlanId(planId);

  Future<void> deletePlan(int planId) => _local.deletePlan(planId);
}
