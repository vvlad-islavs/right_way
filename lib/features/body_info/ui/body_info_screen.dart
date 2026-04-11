import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/body_info.dart';

@RoutePage()
class BodyInfoScreen extends StatelessWidget {
  const BodyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di<BodyInfoBloc>(), child: const _BodyInfoView());
  }
}

class _BodyInfoView extends StatelessWidget {
  const _BodyInfoView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyScreenTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BlocBuilder<BodyInfoBloc, BodyInfoState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: scrollableContentPadding(context),
                  children: [
                    _FieldTile(
                      label: l10n.bodyHeightCm,
                      value: state.heightText,
                      onSave: (raw) =>
                          context.read<BodyInfoBloc>().add(BodyInfoEvent.save(field: BodyField.heightCm, raw: raw)),
                    ),
                    const Gap(12),
                    _FieldTile(
                      label: l10n.bodyWeightKg,
                      value: state.weightText,
                      onSave: (raw) =>
                          context.read<BodyInfoBloc>().add(BodyInfoEvent.save(field: BodyField.weightKg, raw: raw)),
                    ),
                    const Gap(12),
                    _FieldTile(
                      label: l10n.bodyAge,
                      value: state.ageText,
                      onSave: (raw) =>
                          context.read<BodyInfoBloc>().add(BodyInfoEvent.save(field: BodyField.age, raw: raw)),
                    ),
                    const Gap(24),
                    FilledButton.tonal(
                      onPressed: () => context.router.navigate(const TodayPlanRoute()),
                      child: Text(l10n.bodyOpenTodayPlan),
                    ),
                  ],
                );
              },
            ),
          ),
          const AdMobBannerSlot(),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.label, required this.value, required this.onSave});

  final String label;
  final String value;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    return _ControlledFieldTile(label: label, value: value, onSave: onSave);
  }
}

class _ControlledFieldTile extends StatefulWidget {
  const _ControlledFieldTile({required this.label, required this.value, required this.onSave});

  final String label;
  final String value;
  final ValueChanged<String> onSave;

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
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      widget.onSave(_controller.text);
    }
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
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _dismissKeyboardAndSave() {
    FocusScope.of(context).unfocus();
    widget.onSave(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          focusNode: _focusNode,
          decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _controller,
          onEditingComplete: _dismissKeyboardAndSave,
          onSubmitted: (_) => _dismissKeyboardAndSave(),
          onTapOutside: (_) => _dismissKeyboardAndSave(),
        ),
      ),
    );
  }
}
