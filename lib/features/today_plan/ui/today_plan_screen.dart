import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';
import 'package:right_way/features/today_plan/ui/bloc/bloc.dart';
import 'package:right_way/features/today_plan/ui/today_plan_formatting.dart';

class _PlansBottomSheet extends StatefulWidget {
  const _PlansBottomSheet({
    required this.cubit,
    required this.initialPlans,
  });

  final TodayPlanCubit cubit;
  final List<PlanSummary> initialPlans;

  @override
  State<_PlansBottomSheet> createState() => _PlansBottomSheetState();
}

class _PlansBottomSheetState extends State<_PlansBottomSheet> {
  late List<PlanSummary> _plans;

  @override
  void initState() {
    super.initState();
    _plans = List<PlanSummary>.from(widget.initialPlans);
  }

  Future<void> _reload() async {
    final next = await widget.cubit.listPlans();
    if (!mounted) return;
    setState(() => _plans = next);
    if (_plans.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete(PlanSummary p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.todayPlanDeleteDialogTitle),
          content: Text(l10n.todayPlanDeleteDialogBody(p.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.todayPlanCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.todayPlanDelete),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    await widget.cubit.deletePlan(p.id);
    if (!mounted) return;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.todayPlanMyPlans, style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          Text(
            l10n.todayPlanPickerHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Gap(14),
          for (var i = 0; i < _plans.length; i++) ...[
            if (i > 0) const Gap(10),
            _PlanSheetTile(
              plan: _plans[i],
              scheme: scheme,
              onSelect: () {
                Navigator.of(context).pop();
                widget.cubit.selectActivePlan(_plans[i].id);
              },
              onDelete: () => _confirmDelete(_plans[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanSheetTile extends StatelessWidget {
  const _PlanSheetTile({
    required this.plan,
    required this.scheme,
    required this.onSelect,
    required this.onDelete,
  });

  final PlanSummary plan;
  final ColorScheme scheme;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    if (plan.isActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.check_circle_rounded, color: scheme.primary, size: 22),
                      )
                    else
                      const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: Theme.of(context).textTheme.titleSmall),
                          const Gap(2),
                          Text(
                            '${formatPlanDate(context, plan.createdAtMs)}${plan.isActive ? l10n.todayPlanActiveSuffix : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.todayPlanDeleteTooltip,
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TodayPlanView();
  }
}

class _TodayPlanView extends StatelessWidget {
  const _TodayPlanView();

  Future<void> _openPlanPicker(BuildContext context) async {
    final cubit = context.read<TodayPlanCubit>();
    final plans = await cubit.listPlans();
    if (!context.mounted) return;
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.todayPlanNoSavedPlansSnack)),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return _PlansBottomSheet(cubit: cubit, initialPlans: plans);
      },
    );
  }

  void _openDaySheet(BuildContext screenContext, DayEntity day) {
    final router = screenContext.router;
    showModalBottomSheet<void>(
      context: screenContext,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            final sh = Theme.of(sheetContext).colorScheme;
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: sh.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.todayPlanSheetDayTitle(day.dayIndex, weekdayShort(l10n, day.weekDay)),
                          style: Theme.of(sheetContext).textTheme.titleLarge,
                        ),
                        if (day.dayNutrition != null) ...[
                          const Gap(8),
                          Text(
                            l10n.todayPlanSheetDayMacros(
                              day.dayNutrition!.kcal.round(),
                              day.dayNutrition!.proteinG.round(),
                              day.dayNutrition!.fatG.round(),
                              day.dayNutrition!.carbsG.round(),
                            ),
                            style: Theme.of(sheetContext).textTheme.titleSmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Gap(16),
                for (final meal in day.meals) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${mealTypeLabel(l10n, meal.type)} — ${meal.title}'),
                    subtitle: Text(
                      l10n.todayPlanMealSubtitle(
                        meal.nutrition.kcal.round(),
                        meal.nutrition.proteinG.round(),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final recipe = formatRecipe(meal, l10n);
                      Navigator.of(sheetContext).pop();
                      router.push(RecipeRoute(title: meal.title, recipe: recipe));
                    },
                  ),
                  const Divider(height: 1),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayPlanCubit, TodayPlanState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final title = state.activePlanTitle;

        Widget body;
        switch (state.status) {
          case TodayPlanLoadStatus.loading:
            body = const Center(child: CircularProgressIndicator());
            break;
          case TodayPlanLoadStatus.loadFailed:
            body = RefreshIndicator(
              onRefresh: () => context.read<TodayPlanCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    l10n.todayPlanLoadFailed,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
            break;
          case TodayPlanLoadStatus.empty:
            body = RefreshIndicator(
              onRefresh: () => context.read<TodayPlanCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    l10n.todayPlanEmpty,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
            break;
          case TodayPlanLoadStatus.ready:
            final soft = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Material(
                    color: soft,
                    borderRadius: BorderRadius.circular(22),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SegmentedButton<int>(
                        segments: [
                          ButtonSegment(
                            value: 0,
                            label: Text(l10n.todayPlanSegmentToday),
                            icon: const Icon(Icons.today_outlined),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text(l10n.todayPlanSegmentFull),
                            icon: const Icon(Icons.calendar_view_week_outlined),
                          ),
                        ],
                        selected: {state.segmentIndex},
                        onSelectionChanged: (s) => context.read<TodayPlanCubit>().setSegment(s.first),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: state.segmentIndex == 0
                      ? _TodaySegment(
                          day: state.todayDay,
                          onOpenRecipe: (meal) {
                            final recipe = formatRecipe(meal, l10n);
                            context.router.push(RecipeRoute(title: meal.title, recipe: recipe));
                          },
                        )
                      : _FullPlanSegment(
                          days: state.allDays,
                          onDayTap: (d) => _openDaySheet(context, d),
                        ),
                ),
              ],
            );
            break;
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.todayPlanAppBarTitle),
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TextButton.icon(
                  onPressed: () => _openPlanPicker(context),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                  label: Text(l10n.todayPlanPlansButton),
                ),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}

class _TodaySegment extends StatelessWidget {
  const _TodaySegment({
    required this.day,
    required this.onOpenRecipe,
  });

  final DayEntity? day;
  final void Function(MealEntity meal) onOpenRecipe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (day == null) {
      return RefreshIndicator(
        onRefresh: () => context.read<TodayPlanCubit>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.todayPlanNoTodayMatch,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    final d = day!;
    final children = <Widget>[
      if (d.dayNutrition != null)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.todayPlanDayTotals(
                d.dayNutrition!.kcal.round(),
                d.dayNutrition!.proteinG.round(),
                d.dayNutrition!.fatG.round(),
                d.dayNutrition!.carbsG.round(),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ...d.meals.map(
        (meal) => Card(
          child: ListTile(
            title: Text('${mealTypeLabel(l10n, meal.type)} — ${meal.title}'),
            subtitle: Text(
              l10n.todayPlanMealSubtitle(
                meal.nutrition.kcal.round(),
                meal.nutrition.proteinG.round(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpenRecipe(meal),
          ),
        ),
      ),
    ];

    return RefreshIndicator(
      onRefresh: () => context.read<TodayPlanCubit>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        separatorBuilder: (context, index) => const Gap(12),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

class _FullPlanSegment extends StatelessWidget {
  const _FullPlanSegment({
    required this.days,
    required this.onDayTap,
  });

  final List<DayEntity> days;
  final void Function(DayEntity day) onDayTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<TodayPlanCubit>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        separatorBuilder: (context, index) => const Gap(8),
        itemBuilder: (context, index) {
          final l10n = context.l10n;
          final d = days[index];
          final mealsCount = d.meals.length;
          final kcal = d.dayNutrition?.kcal.round() ?? 0;
          final kcalPart = kcal > 0 ? l10n.todayPlanKcalApprox(kcal) : '';
          return Card(
            child: ListTile(
              title: Text(l10n.todayPlanDayRowTitle(d.dayIndex, weekdayShort(l10n, d.weekDay))),
              subtitle: Text(l10n.todayPlanDayRowSubtitle(mealsCount, kcalPart)),
              trailing: const Icon(Icons.expand_more),
              onTap: () => onDayTap(d),
            ),
          );
        },
      ),
    );
  }
}
