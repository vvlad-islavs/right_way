import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';
import 'package:right_way/features/today_plan/ui/bloc/bloc.dart';

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

  String _goalLabel(NutritionGoal goal) {
    return switch (goal) {
      NutritionGoal.weightLoss => 'Похудение',
      NutritionGoal.muscleGain => 'Масса',
      NutritionGoal.health => 'Здоровье',
    };
  }

  void _handleExcludedChanged(String value) {
    if (_excludedFocusNode.hasFocus) _excludedFocusNode.unfocus();
    context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setExcluded(value.trim()));
  }

  void _handleNotesChanged(String value) {
    if (_notesFocusNode.hasFocus) _notesFocusNode.unfocus();
    context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setNotes(value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки плана')),
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
                      Text('Дней в плане: ${state.days}', style: Theme.of(context).textTheme.titleMedium),
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
                    decoration: const InputDecoration(labelText: 'Цель', border: OutlineInputBorder()),
                    items: NutritionGoal.values
                        .map((g) => DropdownMenuItem(value: g, child: Text(_goalLabel(g))))
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
                    decoration: const InputDecoration(
                      labelText: 'Название плана',
                      hintText: 'Как назвать этот план в списке',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Исключить продукты (через запятую)',
                      border: OutlineInputBorder(),
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
                child: state.isLoading ? const CircularProgressIndicator() : const Text('Рассчитать'),
              ),
              // if (state.result != null) ...[
              //   const Gap(16),
              //   Card(
              //     child: Padding(padding: const EdgeInsets.all(12), child: Text('Ответ API: ${state.result!.rawJson}')),
              //   ),
              // ],
            ],
          );
        },
      ),
    );
  }
}
