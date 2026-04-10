import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/body_info.dart';

@RoutePage()
class BodyInfoScreen extends StatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  State<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends State<BodyInfoScreen> {
  late final Stream<AppError> _errors;
  late final StreamSubscription<AppError> _sub;

  @override
  void initState() {
    super.initState();
    _errors = di<ErrorReporter>().stream;
    _sub = _errors.listen((e) {
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
      create: (_) => di<BodyInfoBloc>(),
      child: const _BodyInfoView(),
    );
  }
}

class _BodyInfoView extends StatelessWidget {
  const _BodyInfoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тело')),
      body: BlocBuilder<BodyInfoBloc, BodyInfoState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FieldTile(
                label: 'Рост (см)',
                value: state.heightText,
                isSaved: state.lastSavedField == BodyField.heightCm,
                onChanged: (v) => context.read<BodyInfoBloc>().add(BodyInfoEvent.changeHeightCm(v)),
                onSave: () => context.read<BodyInfoBloc>().add(const BodyInfoEvent.save(BodyField.heightCm)),
              ),
              const SizedBox(height: 12),
              _FieldTile(
                label: 'Вес (кг)',
                value: state.weightText,
                isSaved: state.lastSavedField == BodyField.weightKg,
                onChanged: (v) => context.read<BodyInfoBloc>().add(BodyInfoEvent.changeWeightKg(v)),
                onSave: () => context.read<BodyInfoBloc>().add(const BodyInfoEvent.save(BodyField.weightKg)),
              ),
              const SizedBox(height: 12),
              _FieldTile(
                label: 'Возраст',
                value: state.ageText,
                isSaved: state.lastSavedField == BodyField.age,
                onChanged: (v) => context.read<BodyInfoBloc>().add(BodyInfoEvent.changeAge(v)),
                onSave: () => context.read<BodyInfoBloc>().add(const BodyInfoEvent.save(BodyField.age)),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.router.navigate(const TodayPlanRoute()),
                child: const Text('Открыть план на сегодня'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => context.router.navigate(const ProgressRoute()),
                child: const Text('Открыть прогресс'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onSave,
    required this.isSaved,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return _ControlledFieldTile(
      label: label,
      value: value,
      onChanged: onChanged,
      onSave: onSave,
      isSaved: isSaved,
    );
  }
}

class _ControlledFieldTile extends StatefulWidget {
  const _ControlledFieldTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onSave,
    required this.isSaved,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;
  final bool isSaved;

  @override
  State<_ControlledFieldTile> createState() => _ControlledFieldTileState();
}

class _ControlledFieldTileState extends State<_ControlledFieldTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ControlledFieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                controller: _controller,
                onChanged: widget.onChanged,
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: widget.onSave,
              icon: Icon(widget.isSaved ? Icons.check : Icons.save_outlined),
              tooltip: 'Сохранить',
            ),
          ],
        ),
      ),
    );
  }
}

