import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';
import 'package:right_way/features/today_plan/ui/bloc/bloc.dart';
import 'package:right_way/features/today_plan/ui/today_plan_formatting.dart';

String _formatPlanDate(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$day.$m.${d.year}';
}

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
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить план?'),
        content: Text('«${p.name}» и все его дни будут удалены безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.cubit.deletePlan(p.id);
    if (!mounted) return;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Мои планы', style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          Text(
            'Нажми на план, чтобы сделать его активным. Корзина — удалить.',
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
                            '${_formatPlanDate(plan.createdAtMs)}${plan.isActive ? ' · активен' : ''}',
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
            tooltip: 'Удалить',
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
    return BlocProvider(
      create: (_) => di<TodayPlanCubit>(),
      child: const _TodayPlanView(),
    );
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
        const SnackBar(content: Text('Сохранённых планов пока нет. Создай план на вкладке «Питание».')),
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
                          'День ${day.dayIndex} · ${weekdayShortRu(day.weekDay)}',
                          style: Theme.of(sheetContext).textTheme.titleLarge,
                        ),
                        if (day.dayNutrition != null) ...[
                          const Gap(8),
                          Text(
                            '${day.dayNutrition!.kcal.round()} ккал · Б ${day.dayNutrition!.proteinG.round()} г · '
                            'Ж ${day.dayNutrition!.fatG.round()} г · У ${day.dayNutrition!.carbsG.round()} г',
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
                    title: Text('${mealTypeRu(meal.type)} — ${meal.title}'),
                    subtitle: Text(
                      '${meal.nutrition.kcal.round()} ккал · Б ${meal.nutrition.proteinG.round()} г',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final recipe = formatRecipe(meal);
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
                    'Не удалось загрузить план. Потяни вниз, чтобы обновить.',
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
                    'Пока нет сохранённых планов или в плане нет дней. '
                    'Создай план на вкладке «Питание» и при необходимости выбери активный план.',
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
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Сегодня'), icon: Icon(Icons.today_outlined)),
                          ButtonSegment(
                            value: 1,
                            label: Text('Весь план'),
                            icon: Icon(Icons.calendar_view_week_outlined),
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
                            final recipe = formatRecipe(meal);
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
                const Text('План'),
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
                  label: const Text('Планы'),
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
    if (day == null) {
      return RefreshIndicator(
        onRefresh: () => context.read<TodayPlanCubit>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'В активном плане нет дня, совпадающего с сегодняшним по схеме недели. '
              'Открой «Весь план» или выбери другой активный план.',
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
              'За день: ${d.dayNutrition!.kcal.round()} ккал · '
              'Б ${d.dayNutrition!.proteinG.round()} г · '
              'Ж ${d.dayNutrition!.fatG.round()} г · '
              'У ${d.dayNutrition!.carbsG.round()} г',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ...d.meals.map(
        (meal) => Card(
          child: ListTile(
            title: Text('${mealTypeRu(meal.type)} — ${meal.title}'),
            subtitle: Text(
              '${meal.nutrition.kcal.round()} ккал · Б ${meal.nutrition.proteinG.round()} г',
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
          final d = days[index];
          final mealsCount = d.meals.length;
          final kcal = d.dayNutrition?.kcal.round() ?? 0;
          return Card(
            child: ListTile(
              title: Text('День ${d.dayIndex} · ${weekdayShortRu(d.weekDay)}'),
              subtitle: Text('$mealsCount приёмов пищи${kcal > 0 ? ' · ~$kcal ккал' : ''}'),
              trailing: const Icon(Icons.expand_more),
              onTap: () => onDayTap(d),
            ),
          );
        },
      ),
    );
  }
}
