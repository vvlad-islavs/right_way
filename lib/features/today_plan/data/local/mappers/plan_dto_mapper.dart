import 'dart:convert';

import 'package:right_way/features/today_plan/data/local/models/models.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';

import 'day_dto_mapper.dart';


extension PlanDtoMapper on PlanDto {
  PlanEntity toEntity() {
    final sortedDays = days.toList()..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    final dayEntities = sortedDays.map((d) => d.toEntity()).toList();

    List<int> ids;
    if (dayIdsCsv.isNotEmpty) {
      ids = dayIdsCsv.split(',').map((s) => int.tryParse(s.trim()) ?? 0).where((id) => id > 0).toList();
    } else {
      ids = sortedDays.map((d) => d.id).toList();
    }

    List<String> excluded;
    try {
      final list = jsonDecode(excludedFoodsJson) as List<dynamic>? ?? [];
      excluded = list.map((e) => e.toString()).toList();
    } catch (_) {
      excluded = [];
    }

    return PlanEntity(
      id: id,
      name: name,
      isActive: isActive,
      dayIds: ids,
      metaDays: metaDays,
      goal: goal,
      excludedFoods: excluded,
      createdAtMs: createdAtMs,
      days: dayEntities,
    );
  }
}
