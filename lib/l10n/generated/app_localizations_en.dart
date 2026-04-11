// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Right Way';

  @override
  String get appTagline => 'Healthy eating and lifestyle';

  @override
  String get navTabBody => 'Body';

  @override
  String get navTabNutrition => 'Nutrition';

  @override
  String get navTabPlan => 'Plan';

  @override
  String get navTabSettings => 'Settings';

  @override
  String get bodyScreenTitle => 'Body';

  @override
  String get bodyHeightCm => 'Height (cm)';

  @override
  String get bodyWeightKg => 'Weight (kg)';

  @override
  String get bodyAge => 'Age';

  @override
  String get bodyOpenTodayPlan => 'Open today’s plan';

  @override
  String get nutritionPlanTitle => 'Plan settings';

  @override
  String nutritionDaysInPlan(int days) {
    return 'Days in plan: $days';
  }

  @override
  String get nutritionGoalLabel => 'Goal';

  @override
  String get goalWeightLoss => 'Weight loss';

  @override
  String get goalMuscleGain => 'Muscle gain';

  @override
  String get goalHealth => 'Health';

  @override
  String get nutritionPlanName => 'Plan name';

  @override
  String get nutritionPlanNameHint => 'How this plan appears in the list';

  @override
  String get nutritionExcludedProducts => 'Exclude foods (comma-separated)';

  @override
  String get nutritionCalculate => 'Calculate';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLoadError => 'Could not load settings.';

  @override
  String get settingsRetry => 'Retry';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Interface language';

  @override
  String get settingsLanguageRu => 'Russian';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeHint => 'Interface theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsModelLabel => 'Model';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsApiKey => 'API key';

  @override
  String get settingsShowKey => 'Show';

  @override
  String get settingsHideKey => 'Hide';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get todayPlanAppBarTitle => 'Plan';

  @override
  String get todayPlanSegmentToday => 'Today';

  @override
  String get todayPlanSegmentFull => 'Full plan';

  @override
  String get todayPlanPlansButton => 'Plans';

  @override
  String get todayPlanLoadFailed =>
      'Could not load the plan. Pull down to refresh.';

  @override
  String get todayPlanEmpty =>
      'No saved plans yet or the plan has no days. Create a plan on the Nutrition tab and pick an active plan if needed.';

  @override
  String get todayPlanNoTodayMatch =>
      'The active plan has no day matching today in the week layout. Open Full plan or choose another active plan.';

  @override
  String todayPlanDayTotals(int kcal, int protein, int fat, int carbs) {
    return 'Day total: $kcal kcal · P $protein g · F $fat g · C $carbs g';
  }

  @override
  String todayPlanMealSubtitle(int kcal, int protein) {
    return '$kcal kcal · P $protein g';
  }

  @override
  String todayPlanSheetDayTitle(int day, String weekday) {
    return 'Day $day · $weekday';
  }

  @override
  String todayPlanSheetDayMacros(int kcal, int protein, int fat, int carbs) {
    return '$kcal kcal · P $protein g · F $fat g · C $carbs g';
  }

  @override
  String todayPlanDayRowTitle(int day, String weekday) {
    return 'Day $day · $weekday';
  }

  @override
  String todayPlanDayRowSubtitle(int count, String kcalPart) {
    return '$count meals$kcalPart';
  }

  @override
  String todayPlanKcalApprox(int kcal) {
    return ' · ~$kcal kcal';
  }

  @override
  String get todayPlanNoSavedPlansSnack =>
      'No saved plans yet. Create a plan on the Nutrition tab.';

  @override
  String get todayPlanMyPlans => 'My plans';

  @override
  String get todayPlanPickerHint =>
      'Tap a plan to make it active. Trash icon — delete.';

  @override
  String get todayPlanDeleteTooltip => 'Delete';

  @override
  String get todayPlanDeleteDialogTitle => 'Delete plan?';

  @override
  String todayPlanDeleteDialogBody(String name) {
    return '\"$name\" and all its days will be permanently deleted.';
  }

  @override
  String get todayPlanCancel => 'Cancel';

  @override
  String get todayPlanDelete => 'Delete';

  @override
  String get todayPlanActiveSuffix => ' · active';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get mealGeneric => 'Meal';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get recipeIngredients => 'Ingredients:';

  @override
  String get recipeSteps => 'Steps:';

  @override
  String recipeIngredientLine(String name, String amount, String unit) {
    return '· $name — $amount $unit';
  }

  @override
  String recipeStepLine(int n, String text) {
    return '$n. $text';
  }

  @override
  String get recipeNoDetails => 'No recipe details.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String errorMissingApiKey(String provider) {
    return 'Add an API key for $provider in Settings.';
  }

  @override
  String errorNoRemoteSource(String provider) {
    return 'No data source found for $provider.';
  }

  @override
  String get errorPlanNotFound => 'Plan not found.';

  @override
  String get errorEmptyPlanName =>
      'Enter a plan name so it appears in the list.';

  @override
  String get errorInvalidBody => 'Invalid value.';

  @override
  String get errorFailedSaveLocal => 'Could not update local data';

  @override
  String get errorInvalidAiPlan =>
      'The AI response does not look like a plan: invalid format.';

  @override
  String get errorGroqMissingPlan =>
      'The model returned a response without a day list.';

  @override
  String get errorInvalidModelJson =>
      'The model returned invalid JSON. Try again or switch the model.';

  @override
  String get errorGeminiFreeTier =>
      'No Gemini quota for this key (free tier = 0). Use another key or billing.';

  @override
  String get errorGeminiRateLimit =>
      'Gemini is temporarily unavailable due to limits. Try later.';

  @override
  String get errorGeminiRequestFailed =>
      'Could not reach Gemini. Check network and key.';

  @override
  String errorAiBadRequestDecommissioned(String provider) {
    return '$provider: model is no longer supported. Pick another in Settings.';
  }

  @override
  String errorAiBadRequestGeneric(String provider) {
    return '$provider: request rejected. Check model and settings.';
  }

  @override
  String errorAiAuth(String provider) {
    return '$provider: access denied. Check key and region.';
  }

  @override
  String errorAiRateLimit(String provider) {
    return '$provider: too many requests. Wait or switch model.';
  }

  @override
  String errorAiServer(String provider) {
    return '$provider: server temporarily unavailable.';
  }

  @override
  String errorAiNetwork(String provider) {
    return '$provider: request failed. Check network, key, and limits.';
  }
}
