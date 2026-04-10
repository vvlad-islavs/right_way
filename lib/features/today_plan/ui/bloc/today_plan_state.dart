import 'package:right_way/features/today_plan/domain/domain.dart';

enum TodayPlanLoadStatus { loading, empty, ready, loadFailed }

class TodayPlanState {
  const TodayPlanState({
    required this.status,
    this.segmentIndex = 0,
    this.todayDay,
    this.allDays = const [],
    this.activePlanTitle,
  });

  final TodayPlanLoadStatus status;
  final int segmentIndex;
  final DayEntity? todayDay;
  final List<DayEntity> allDays;
  final String? activePlanTitle;

  TodayPlanState copyWith({
    TodayPlanLoadStatus? status,
    int? segmentIndex,
    DayEntity? todayDay,
    List<DayEntity>? allDays,
    String? activePlanTitle,
  }) {
    return TodayPlanState(
      status: status ?? this.status,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      todayDay: todayDay ?? this.todayDay,
      allDays: allDays ?? this.allDays,
      activePlanTitle: activePlanTitle ?? this.activePlanTitle,
    );
  }
}
