import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:right_way/core/core.dart';
import 'package:right_way/features/today_plan/ui/bloc/bloc.dart';

@RoutePage()
class RootTabsScreen extends StatefulWidget {
  const RootTabsScreen({super.key});

  @override
  State<RootTabsScreen> createState() => _RootTabsScreenState();
}

class _RootTabsScreenState extends State<RootTabsScreen> {
  StreamSubscription<AppError>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = di<ErrorReporter>().stream.listen((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.uiMessage)));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider<TodayPlanCubit>.value(
      value: di<TodayPlanCubit>(),
      child: AutoTabsRouter(
        routes: const [
          BodyInfoRoute(),
          NutritionSettingsRoute(),
          TodayPlanRoute(),
          AppSettingsRoute(),
        ],
        builder: (context, child) {
          final tabs = AutoTabsRouter.of(context);
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: tabs.activeIndex,
              onDestinationSelected: tabs.setActiveIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: l10n.navTabBody,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_outlined),
                  label: l10n.navTabNutrition,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.restaurant_menu_outlined),
                  label: l10n.navTabPlan,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  label: l10n.navTabSettings,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
