import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/data/local/mappers/mappers.dart';
import 'package:right_way/features/today_plan/data/local/models/models.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

/// [TodayPlanLocalSource] на ObjectBox: планы, дни и приемы в транзакциях.
class ObjectBoxTodayPlanLocalSource implements TodayPlanLocalSource {
  /// Подключает боксы планов, дней и приемов из [store].
  ObjectBoxTodayPlanLocalSource(ObjectBoxStore store)
      : _store = store.store,
        _planBox = store.store.box<PlanDto>(),
        _dayBox = store.store.box<DayDto>(),
        _mealBox = store.store.box<MealDto>();

  final Store _store;
  final Box<PlanDto> _planBox;
  final Box<DayDto> _dayBox;
  final Box<MealDto> _mealBox;

  /// Единственный активный план, иначе самый новый по [createdAtMs]; null если планов нет.
  PlanDto? _resolvedPlanDto() {
    final all = _planBox.getAll();
    if (all.isEmpty) return null;
    final marked = all.where((p) => p.isActive).toList();
    if (marked.length == 1) return marked.first;
    all.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return all.first;
  }

  /// См. [TodayPlanLocalSource.persistFromAiResponse].
  @override
  Future<int> persistFromAiResponse(Map<String, dynamic> rawJson, String planName) async {
    final meta = _asStringKeyedMap(rawJson['meta']);
    final goal = meta?['goal']?.toString() ?? '';
    final metaDays = (meta?['days'] as num?)?.toInt() ?? 0;
    final excluded = meta?['excludedFoods'];
    final excludedJson = jsonEncode(
      excluded is List ? excluded.map((e) => e.toString()).toList() : <String>[],
    );

    final planList = rawJson['plan'];
    if (planList is! List<dynamic>) {
      throw AppErrors.invalidAiPlanStructure(reason: 'field "plan" is not a list', payload: rawJson);
    }
    if (planList.isEmpty) {
      throw AppErrors.invalidAiPlanStructure(reason: 'field "plan" is empty', payload: rawJson);
    }

    var validDayCount = 0;
    for (final e in planList) {
      if (_asStringKeyedMap(e) != null) validDayCount++;
    }
    if (validDayCount == 0) {
      throw AppErrors.invalidAiPlanStructure(reason: 'no valid day objects in plan', payload: rawJson);
    }

    final anchorWeekday = DateTime.now().weekday;
    final name = planName.trim().isEmpty ? 'План' : planName.trim();

    late int newPlanId;
    _store.runInTransaction(TxMode.write, () {
      final plan = PlanDto(
        name: name,
        isActive: false,
        metaDays: metaDays,
        goal: goal,
        excludedFoodsJson: excludedJson,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      _planBox.put(plan);
      newPlanId = plan.id;

      final dayDtos = <DayDto>[];
      var i = 0;
      for (final e in planList) {
        final dayMap = _asStringKeyedMap(e);
        if (dayMap == null) continue;
        i++;
        var dayIndex = (dayMap['day'] as num?)?.toInt() ?? i;
        if (dayIndex < 1) dayIndex = i;
        final weekDay = ((anchorWeekday - 1) + (dayIndex - 1)) % 7 + 1;

        final dn = _asStringKeyedMap(dayMap['dayNutrition']);
        final dayDto = DayDto(
          weekDay: weekDay,
          dayIndex: dayIndex,
          dayKcal: _asDouble(dn?['kcal']),
          dayProteinG: _asDouble(dn?['protein_g']),
          dayFatG: _asDouble(dn?['fat_g']),
          dayCarbsG: _asDouble(dn?['carbs_g']),
        );
        dayDto.plan.target = plan;
        _dayBox.put(dayDto);
        dayDtos.add(dayDto);

        final meals = dayMap['meals'];
        if (meals is List<dynamic>) {
          for (final m in meals) {
            final mm = _asStringKeyedMap(m);
            if (mm == null) continue;
            final nutrition = _asStringKeyedMap(mm['nutrition']);
            final mealDto = MealDto(
              mealType: mm['type']?.toString() ?? '',
              title: mm['title']?.toString() ?? '',
              ingredientsJson: jsonEncode(mm['ingredients'] ?? []),
              stepsJson: jsonEncode(mm['steps'] ?? []),
              kcal: _asDouble(nutrition?['kcal']),
              proteinG: _asDouble(nutrition?['protein_g']),
              fatG: _asDouble(nutrition?['fat_g']),
              carbsG: _asDouble(nutrition?['carbs_g']),
            );
            mealDto.day.target = dayDto;
            _mealBox.put(mealDto);
          }
        }
      }

      plan.dayIdsCsv = dayDtos.map((d) => d.id).join(',');
      _planBox.put(plan);
    });
    return newPlanId;
  }

  /// См. [TodayPlanLocalSource.loadActivePlanDayForWeekday].
  @override
  Future<DayEntity?> loadActivePlanDayForWeekday(int weekDay) async {
    final plan = _resolvedPlanDto();
    if (plan == null) return null;
    final match = plan.days.where((d) => d.weekDay == weekDay).toList()
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    if (match.isEmpty) return null;
    return match.first.toEntity();
  }

  /// См. [TodayPlanLocalSource.loadActivePlanAllDaysSorted].
  @override
  Future<List<DayEntity>> loadActivePlanAllDaysSorted() async {
    final plan = _resolvedPlanDto();
    if (plan == null) return [];
    final list = plan.days.toList()..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return list.map((d) => d.toEntity()).toList();
  }

  /// См. [TodayPlanLocalSource.listPlans].
  @override
  Future<List<PlanSummary>> listPlans() async {
    final all = _planBox.getAll();
    all.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return all
        .map(
          (p) => PlanSummary(
            id: p.id,
            name: p.name.trim().isEmpty ? 'План #${p.id}' : p.name.trim(),
            createdAtMs: p.createdAtMs,
            isActive: p.isActive,
          ),
        )
        .toList();
  }

  /// См. [TodayPlanLocalSource.setActivePlanId].
  @override
  Future<void> setActivePlanId(int planId) async {
    final snapshot = _planBox.getAll();
    if (!snapshot.any((p) => p.id == planId)) {
      throw AppErrors.planNotFound(planId);
    }
    _store.runInTransaction(TxMode.write, () {
      final all = _planBox.getAll();
      for (final p in all) {
        final next = p.id == planId;
        if (p.isActive != next) {
          p.isActive = next;
          _planBox.put(p);
        }
      }
    });
  }

  /// См. [TodayPlanLocalSource.resolvedActivePlanTitle].
  @override
  Future<String?> resolvedActivePlanTitle() async {
    final p = _resolvedPlanDto();
    if (p == null) return null;
    final n = p.name.trim();
    return n.isEmpty ? 'План #${p.id}' : n;
  }

  /// См. [TodayPlanLocalSource.deletePlan].
  @override
  Future<void> deletePlan(int planId) async {
    final existing = _planBox.get(planId);
    if (existing == null) {
      throw AppErrors.planNotFound(planId);
    }
    _store.runInTransaction(TxMode.write, () {
      final plan = _planBox.get(planId);
      if (plan == null) return;
      for (final day in plan.days.toList()) {
        for (final meal in day.meals.toList()) {
          _mealBox.remove(meal.id);
        }
        _dayBox.remove(day.id);
      }
      _planBox.remove(planId);
    });
  }
}

/// Приводит [v] к `Map<String, dynamic>` или null.
Map<String, dynamic>? _asStringKeyedMap(Object? v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val));
  }
  return null;
}

/// Безопасное извлечение [double] из числа или строки.
double _asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
