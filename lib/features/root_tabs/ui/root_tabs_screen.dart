import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

@RoutePage()
class RootTabsScreen extends StatelessWidget {
  const RootTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        BodyInfoRoute(),
        NutritionSettingsRoute(),
        TodayPlanRoute(),
        ProgressRoute(),
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
                label: 'Настройки',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                label: 'План',
              ),
              NavigationDestination(
                icon: Icon(Icons.show_chart_outlined),
                label: 'Прогресс',
              ),
            ],
          ),
        );
      },
    );
  }
}

