// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppSettingsScreen]
class AppSettingsRoute extends PageRouteInfo<void> {
  const AppSettingsRoute({List<PageRouteInfo>? children})
    : super(AppSettingsRoute.name, initialChildren: children);

  static const String name = 'AppSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppSettingsScreen();
    },
  );
}

/// generated route for
/// [BodyInfoScreen]
class BodyInfoRoute extends PageRouteInfo<void> {
  const BodyInfoRoute({List<PageRouteInfo>? children})
    : super(BodyInfoRoute.name, initialChildren: children);

  static const String name = 'BodyInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BodyInfoScreen();
    },
  );
}

/// generated route for
/// [NutritionSettingsScreen]
class NutritionSettingsRoute extends PageRouteInfo<void> {
  const NutritionSettingsRoute({List<PageRouteInfo>? children})
    : super(NutritionSettingsRoute.name, initialChildren: children);

  static const String name = 'NutritionSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NutritionSettingsScreen();
    },
  );
}

/// generated route for
/// [RecipeScreen]
class RecipeRoute extends PageRouteInfo<RecipeRouteArgs> {
  RecipeRoute({
    required String title,
    required String recipe,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         RecipeRoute.name,
         args: RecipeRouteArgs(title: title, recipe: recipe, key: key),
         initialChildren: children,
       );

  static const String name = 'RecipeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeRouteArgs>();
      return RecipeScreen(
        title: args.title,
        recipe: args.recipe,
        key: args.key,
      );
    },
  );
}

class RecipeRouteArgs {
  const RecipeRouteArgs({required this.title, required this.recipe, this.key});

  final String title;

  final String recipe;

  final Key? key;

  @override
  String toString() {
    return 'RecipeRouteArgs{title: $title, recipe: $recipe, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecipeRouteArgs) return false;
    return title == other.title && recipe == other.recipe && key == other.key;
  }

  @override
  int get hashCode => title.hashCode ^ recipe.hashCode ^ key.hashCode;
}

/// generated route for
/// [RootTabsScreen]
class RootTabsRoute extends PageRouteInfo<void> {
  const RootTabsRoute({List<PageRouteInfo>? children})
    : super(RootTabsRoute.name, initialChildren: children);

  static const String name = 'RootTabsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RootTabsScreen();
    },
  );
}

/// generated route for
/// [TodayPlanScreen]
class TodayPlanRoute extends PageRouteInfo<void> {
  const TodayPlanRoute({List<PageRouteInfo>? children})
    : super(TodayPlanRoute.name, initialChildren: children);

  static const String name = 'TodayPlanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TodayPlanScreen();
    },
  );
}
