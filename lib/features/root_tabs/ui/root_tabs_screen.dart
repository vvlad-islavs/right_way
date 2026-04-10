import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

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
    return AutoTabsRouter(
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.monitor_weight_outlined),
                label: 'Тело',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                label: 'Питание',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                label: 'План',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Настройки',
              ),
            ],
          ),
        );
      },
    );
  }
}

