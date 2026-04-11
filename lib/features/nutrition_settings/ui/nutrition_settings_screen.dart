import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';
import 'package:right_way/features/today_plan/ui/bloc/bloc.dart';
import 'package:right_way/l10n/generated/app_localizations.dart';

@RoutePage()
class NutritionSettingsScreen extends StatelessWidget {
  const NutritionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<NutritionSettingsBloc>(),
      child: BlocListener<NutritionSettingsBloc, NutritionSettingsState>(
        listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
        listener: (context, state) {
          if (state.result != null) {
            AutoTabsRouter.of(context).setActiveIndex(2);
            context.read<TodayPlanCubit>().load();
          }
        },
        child: const _NutritionSettingsView(),
      ),
    );
  }
}

class _NutritionSettingsView extends StatefulWidget {
  const _NutritionSettingsView();

  @override
  State<_NutritionSettingsView> createState() => _NutritionSettingsViewState();
}

class _NutritionSettingsViewState extends State<_NutritionSettingsView> {
  final _planNameController = TextEditingController();
  final _excludedController = TextEditingController();
  final _notesController = TextEditingController();
  final _notesFocusNode = FocusNode();
  final _excludedFocusNode = FocusNode();

  @override
  void initState() {
    final blocInitState = context.read<NutritionSettingsBloc>().state;
    _planNameController.text = blocInitState.planName;
    _excludedController.text = blocInitState.excludedRaw;
    _notesController.text = blocInitState.notes;
    super.initState();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _excludedController.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    _excludedFocusNode.dispose();
    super.dispose();
  }

  String _goalLabel(AppLocalizations l10n, NutritionGoal goal) {
    return switch (goal) {
      NutritionGoal.weightLoss => l10n.goalWeightLoss,
      NutritionGoal.muscleGain => l10n.goalMuscleGain,
      NutritionGoal.health => l10n.goalHealth,
    };
  }

  void _handleExcludedChanged(String value) {
    if (_excludedFocusNode.hasFocus) _excludedFocusNode.unfocus();
    context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setExcluded(value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutritionPlanTitle)),
      body: BlocBuilder<NutritionSettingsBloc, NutritionSettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.nutritionDaysInPlan(state.days), style: Theme.of(context).textTheme.titleMedium),
                      Slider(
                        value: state.days.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '${state.days}',
                        onChanged: state.isLoading
                            ? null
                            : (v) =>
                                  context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setDays(v.toInt())),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<NutritionGoal>(
                    initialValue: state.goal,
                    decoration: InputDecoration(labelText: l10n.nutritionGoalLabel, border: const OutlineInputBorder()),
                    items: NutritionGoal.values
                        .map((g) => DropdownMenuItem(value: g, child: Text(_goalLabel(l10n, g))))
                        .toList(growable: false),
                    onChanged: state.isLoading
                        ? null
                        : (v) {
                            if (v == null) return;
                            context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setGoal(v));
                          },
                  ),
                ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _planNameController,
                    enabled: !state.isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.nutritionPlanName,
                      hintText: l10n.nutritionPlanNameHint,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) => context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setPlanName(v)),
                  ),
                ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _excludedController,
                    focusNode: _excludedFocusNode,
                    decoration: InputDecoration(
                      labelText: l10n.nutritionExcludedProducts,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (v) => _handleExcludedChanged(v),
                    onEditingComplete: () => _handleExcludedChanged(_excludedController.text),
                    onTapOutside: (_) => _handleExcludedChanged(_excludedController.text),
                  ),
                ),
              ),

              const Gap(24),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<NutritionSettingsBloc>().add(const NutritionSettingsEvent.calculate()),
                child: state.isLoading ? const CircularProgressIndicator() : Text(l10n.nutritionCalculate),
              ),
            ],
          );
        },
      ),
    );
  }
}
