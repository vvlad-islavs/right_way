import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';
import 'package:right_way/features/today_plan/ui/bloc/today_plan_state.dart';

class TodayPlanCubit extends Cubit<TodayPlanState> {
  TodayPlanCubit(this._useCase, this._errors)
      : super(
          const TodayPlanState(status: TodayPlanLoadStatus.loading),
        ) {
    load();
  }

  final TodayPlanUseCase _useCase;
  final ErrorReporter _errors;

  void setSegment(int index) {
    final i = index.clamp(0, 1);
    if (i == state.segmentIndex) return;
    emit(state.copyWith(segmentIndex: i));
  }

  Future<List<PlanSummary>> listPlans() => _useCase.listPlans();

  Future<void> selectActivePlan(int planId) async {
    try {
      await _useCase.setActivePlanAsActive(planId);
      await load();
    } catch (e, st) {
      ErrorHandling.reportCaught(_errors, e, st);
    }
  }

  Future<void> deletePlan(int planId) async {
    try {
      await _useCase.deletePlan(planId);
      await load();
    } catch (e, st) {
      ErrorHandling.reportCaught(_errors, e, st);
    }
  }

  Future<void> load() async {
    final seg = state.segmentIndex;
    emit(TodayPlanState(status: TodayPlanLoadStatus.loading, segmentIndex: seg));
    try {
      final today = await _useCase.loadToday();
      final all = await _useCase.loadActivePlanAllDays();
      final title = await _useCase.activePlanTitle();

      if (all.isEmpty) {
        emit(
          TodayPlanState(
            status: TodayPlanLoadStatus.empty,
            segmentIndex: seg,
            activePlanTitle: title,
          ),
        );
        return;
      }

      emit(
        TodayPlanState(
          status: TodayPlanLoadStatus.ready,
          segmentIndex: seg,
          todayDay: today,
          allDays: all,
          activePlanTitle: title,
        ),
      );
    } catch (e, st) {
      ErrorHandling.reportCaught(_errors, e, st);
      emit(
        TodayPlanState(
          status: TodayPlanLoadStatus.loadFailed,
          segmentIndex: seg,
        ),
      );
    }
  }
}
