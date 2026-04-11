import 'package:right_way/features/today_plan/domain/domain.dart';

/// Локальное хранение планов питания и приемов: разбор ответа ИИ, активный план, список и удаление.
abstract interface class TodayPlanLocalSource {
  /// Разобрать [rawJson] от ИИ, создать новый план с именем [planName] и связанные дни и приемы.
  /// Возвращает id сохраненного плана в ObjectBox.
  Future<int> persistFromAiResponse(Map<String, dynamic> rawJson, String planName);

  /// День активного плана для календарного дня недели [weekDay] (1 понедельник ... 7 воскресенье).
  Future<DayEntity?> loadActivePlanDayForWeekday(int weekDay);

  /// Все дни активного плана по возрастанию индекса дня.
  Future<List<DayEntity>> loadActivePlanAllDaysSorted();

  /// Список сохраненных планов для экрана выбора.
  Future<List<PlanSummary>> listPlans();

  /// Сделать план с [planId] активным, остальные неактивными.
  Future<void> setActivePlanId(int planId);

  /// Отображаемое имя активного плана или null, если планов нет.
  Future<String?> resolvedActivePlanTitle();

  /// Удалить план и все связанные дни и приемы.
  Future<void> deletePlan(int planId);
}
