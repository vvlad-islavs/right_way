import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:right_way/features/features.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: RootTabsRoute.page,
          initial: true,
          children: [
            AutoRoute(page: BodyInfoRoute.page),
            AutoRoute(page: NutritionSettingsRoute.page),
            AutoRoute(page: TodayPlanRoute.page),
            AutoRoute(page: AppSettingsRoute.page),
          ],
        ),
        AutoRoute(page: RecipeRoute.page),
      ];
}

