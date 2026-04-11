import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/app_settings/ui/bloc/app_settings_cubit.dart';
import 'package:right_way/features/app_settings/ui/bloc/app_settings_state.dart';

@RoutePage()
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di<AppSettingsCubit>(), child: const _AppSettingsScaffold());
  }
}

class _AppSettingsScaffold extends StatefulWidget {
  const _AppSettingsScaffold();

  @override
  State<_AppSettingsScaffold> createState() => _AppSettingsScaffoldState();
}

class _AppSettingsScaffoldState extends State<_AppSettingsScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          return switch (state.status) {
            AppSettingsLoadStatus.loading => const Center(child: CircularProgressIndicator()),
            AppSettingsLoadStatus.failure => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Не удалось загрузить настройки.'),
                    const Gap(16),
                    FilledButton(
                      onPressed: () => context.read<AppSettingsCubit>().load(),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
            AppSettingsLoadStatus.ready => const _AppSettingsLoadedBody(),
          };
        },
      ),
    );
  }
}

class _AppSettingsLoadedBody extends StatefulWidget {
  const _AppSettingsLoadedBody();

  @override
  State<_AppSettingsLoadedBody> createState() => _AppSettingsLoadedBodyState();
}

class _AppSettingsLoadedBodyState extends State<_AppSettingsLoadedBody> {
  late final TextEditingController _apiKeyCtrl;

  @override
  void initState() {
    super.initState();
    final snap = context.read<AppSettingsCubit>().state.snapshot!;
    _apiKeyCtrl = TextEditingController(text: snap.apiKey);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppSettingsCubit, AppSettingsState>(
      listenWhen: (prev, curr) {
        final apiChanged = prev.snapshot?.apiKey != curr.snapshot?.apiKey;
        final feedback = curr.feedback != null;
        return (curr.status == AppSettingsLoadStatus.ready && apiChanged) || feedback;
      },
      listener: (context, state) {
        final snap = state.snapshot;
        if (snap != null && _apiKeyCtrl.text != snap.apiKey) {
          _apiKeyCtrl.text = snap.apiKey;
        }
        final msg = state.feedback;
        if (msg != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          context.read<AppSettingsCubit>().clearFeedback();
        }
      },
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        buildWhen: (p, c) =>
            p.snapshot != c.snapshot || p.providerSwitching != c.providerSwitching || p.status != c.status,
        builder: (context, state) {
          final snap = state.snapshot!;
          final switching = state.providerSwitching;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Right Way', style: Theme.of(context).textTheme.titleLarge),
                            const Gap(4),
                            Text(
                              'Правильное питание и здоровый образ жизни',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              ListenableBuilder(
                listenable: di<AppThemeController>(),
                builder: (context, _) {
                  final themeCtrl = di<AppThemeController>();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Оформление', style: Theme.of(context).textTheme.titleMedium),
                          const Gap(6),
                          Text(
                            'Тема интерфейса',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const Gap(14),
                          SegmentedButton<ThemeMode>(
                            expandedInsets: const EdgeInsets.symmetric(horizontal: 2),
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text('Система'),
                                icon: Icon(Icons.brightness_auto_rounded, size: 18),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text('Свет'),
                                icon: Icon(Icons.light_mode_outlined, size: 18),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text('Тьма'),
                                icon: Icon(Icons.dark_mode_outlined, size: 18),
                              ),
                            ],
                            selected: {themeCtrl.mode},
                            onSelectionChanged: (s) => themeCtrl.setMode(s.first),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Gap(12),
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(12),
              //     child: Stack(
              //       alignment: Alignment.center,
              //       children: [
              //         Opacity(
              //           opacity: switching ? 0.45 : 1,
              //           child: IgnorePointer(
              //             ignoring: switching,
              //             child: DropdownButtonFormField<AiProvider>(
              //               key: ValueKey('provider:${snap.provider.id}'),
              //               initialValue: snap.provider,
              //               decoration: const InputDecoration(labelText: 'Провайдер', border: OutlineInputBorder()),
              //               items: AiProvider.values
              //                   .map((p) => DropdownMenuItem(value: p, child: Text(p.title)))
              //                   .toList(growable: false),
              //               onChanged: switching
              //                   ? null
              //                   : (v) {
              //                       if (v == null) return;
              //                       context.read<AppSettingsCubit>().selectProvider(v);
              //                     },
              //             ),
              //           ),
              //         ),
              //         if (switching)
              //           const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
              //       ],
              //     ),
              //   ),
              // ),
              // const Gap(12),
              Builder(
                builder: (context) {
                  final models = supportedAiModels(snap.provider);
                  final selectedModel = models.contains(snap.model) ? snap.model : models.first;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('model:${snap.provider.id}:$selectedModel'),
                        initialValue: selectedModel,
                        decoration: const InputDecoration(labelText: 'Модель', border: OutlineInputBorder()),
                        items: models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(growable: false),
                        onChanged: switching
                            ? null
                            : (v) {
                                if (v == null) return;
                                context.read<AppSettingsCubit>().selectModel(v.trim());
                              },
                      ),
                    ),
                  );
                },
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _ObscuringApiKeyField(controller: _apiKeyCtrl),
                ),
              ),
              const Gap(16),
              FilledButton(
                onPressed: switching ? null : () => context.read<AppSettingsCubit>().save(_apiKeyCtrl.text),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ObscuringApiKeyField extends StatefulWidget {
  const _ObscuringApiKeyField({required this.controller});

  final TextEditingController controller;

  @override
  State<_ObscuringApiKeyField> createState() => _ObscuringApiKeyFieldState();
}

class _ObscuringApiKeyFieldState extends State<_ObscuringApiKeyField> {
  late final ValueNotifier<bool> _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = ValueNotifier(true);
  }

  @override
  void dispose() {
    _obscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscure,
      builder: (context, obscure, _) {
        return TextField(
          controller: widget.controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'API ключ',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () => _obscure.value = !_obscure.value,
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              tooltip: obscure ? 'Показать' : 'Скрыть',
            ),
          ),
        );
      },
    );
  }
}
