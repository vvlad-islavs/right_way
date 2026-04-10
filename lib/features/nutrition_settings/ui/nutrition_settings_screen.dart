import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/nutrition_settings/nutrition_settings.dart';

@RoutePage()
class NutritionSettingsScreen extends StatefulWidget {
  const NutritionSettingsScreen({super.key});

  @override
  State<NutritionSettingsScreen> createState() => _NutritionSettingsScreenState();
}

class _NutritionSettingsScreenState extends State<NutritionSettingsScreen> {
  late final StreamSubscription<AppError> _sub;

  @override
  void initState() {
    super.initState();
    _sub = di<ErrorReporter>().stream.listen((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<NutritionSettingsBloc>(),
      child: const _NutritionSettingsView(),
    );
  }
}

class _NutritionSettingsView extends StatelessWidget {
  const _NutritionSettingsView();

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
                        onChanged: state.isLoading ? null : (v) => context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setDays(v.toInt())),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Исключить продукты (через запятую)',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: state.excludedRaw),
                    onChanged: (v) => context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setExcluded(v)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Доп. параметры / заметки',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    controller: TextEditingController(text: state.notes),
                    onChanged: (v) => context.read<NutritionSettingsBloc>().add(NutritionSettingsEvent.setNotes(v)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.isLoading ? null : () => context.read<NutritionSettingsBloc>().add(const NutritionSettingsEvent.calculate()),
                child: state.isLoading ? const CircularProgressIndicator() : const Text('Рассчитать'),
              ),
              if (state.result != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Ответ API: ${state.result!.rawJson}'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

