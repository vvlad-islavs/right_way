import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:right_way/features/today_plan/domain/domain.dart';
import 'package:right_way/l10n/generated/app_localizations.dart';

String mealTypeLabel(AppLocalizations l10n, String type) {
  return switch (type) {
    'breakfast' => l10n.mealBreakfast,
    'lunch' => l10n.mealLunch,
    'dinner' => l10n.mealDinner,
    'snack' => l10n.mealSnack,
    _ => type.isEmpty ? l10n.mealGeneric : type,
  };
}

String formatRecipe(MealEntity meal, AppLocalizations l10n) {
  final buf = StringBuffer();
  if (meal.ingredients.isNotEmpty) {
    buf.writeln(l10n.recipeIngredients);
    for (final i in meal.ingredients) {
      buf.writeln(l10n.recipeIngredientLine(i.name, i.amount.toString(), i.unit));
    }
    buf.writeln();
  }
  if (meal.steps.isNotEmpty) {
    buf.writeln(l10n.recipeSteps);
    var step = 1;
    for (final s in meal.steps) {
      buf.writeln(l10n.recipeStepLine(step, s));
      step++;
    }
  }
  final t = buf.toString().trim();
  return t.isEmpty ? l10n.recipeNoDetails : t;
}

String weekdayShort(AppLocalizations l10n, int weekDay) {
  return switch (weekDay) {
    1 => l10n.weekdayMon,
    2 => l10n.weekdayTue,
    3 => l10n.weekdayWed,
    4 => l10n.weekdayThu,
    5 => l10n.weekdayFri,
    6 => l10n.weekdaySat,
    7 => l10n.weekdaySun,
    _ => '',
  };
}

String formatPlanDate(BuildContext context, int ms) {
  final loc = Localizations.localeOf(context);
  return DateFormat.yMd(loc.toString()).format(DateTime.fromMillisecondsSinceEpoch(ms));
}
