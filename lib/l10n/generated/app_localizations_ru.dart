// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Right Way';

  @override
  String get appTagline => 'Правильное питание и здоровый образ жизни';

  @override
  String get navTabBody => 'Тело';

  @override
  String get navTabNutrition => 'Питание';

  @override
  String get navTabPlan => 'План';

  @override
  String get navTabSettings => 'Настройки';

  @override
  String get bodyScreenTitle => 'Тело';

  @override
  String get bodyHeightCm => 'Рост (см)';

  @override
  String get bodyWeightKg => 'Вес (кг)';

  @override
  String get bodyAge => 'Возраст';

  @override
  String get bodyOpenTodayPlan => 'Открыть план на сегодня';

  @override
  String get nutritionPlanTitle => 'Настройки плана';

  @override
  String nutritionDaysInPlan(int days) {
    return 'Дней в плане: $days';
  }

  @override
  String get nutritionGoalLabel => 'Цель';

  @override
  String get goalWeightLoss => 'Похудение';

  @override
  String get goalMuscleGain => 'Масса';

  @override
  String get goalHealth => 'Здоровье';

  @override
  String get nutritionPlanName => 'Название плана';

  @override
  String get nutritionPlanNameHint => 'Как назвать этот план в списке';

  @override
  String get nutritionExcludedProducts => 'Исключить продукты (через запятую)';

  @override
  String get nutritionCalculate => 'Рассчитать';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLoadError => 'Не удалось загрузить настройки.';

  @override
  String get settingsRetry => 'Повторить';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Язык интерфейса';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsThemeHint => 'Тема интерфейса';

  @override
  String get settingsThemeSystem => 'Система';

  @override
  String get settingsThemeLight => 'Свет';

  @override
  String get settingsThemeDark => 'Тьма';

  @override
  String get settingsModelLabel => 'Модель';

  @override
  String get settingsSave => 'Сохранить';

  @override
  String get settingsApiKey => 'API ключ';

  @override
  String get settingsShowKey => 'Показать';

  @override
  String get settingsHideKey => 'Скрыть';

  @override
  String get settingsSaved => 'Сохранено';

  @override
  String get todayPlanAppBarTitle => 'План';

  @override
  String get todayPlanSegmentToday => 'Сегодня';

  @override
  String get todayPlanSegmentFull => 'Весь план';

  @override
  String get todayPlanPlansButton => 'Планы';

  @override
  String get todayPlanLoadFailed =>
      'Не удалось загрузить план. Потяни вниз, чтобы обновить.';

  @override
  String get todayPlanEmpty =>
      'Пока нет сохранённых планов или в плане нет дней. Создай план на вкладке «Питание» и при необходимости выбери активный план.';

  @override
  String get todayPlanNoTodayMatch =>
      'В активном плане нет дня, совпадающего с сегодняшним по схеме недели. Открой «Весь план» или выбери другой активный план.';

  @override
  String todayPlanDayTotals(int kcal, int protein, int fat, int carbs) {
    return 'За день: $kcal ккал · Б $protein г · Ж $fat г · У $carbs г';
  }

  @override
  String todayPlanMealSubtitle(int kcal, int protein) {
    return '$kcal ккал · Б $protein г';
  }

  @override
  String todayPlanSheetDayTitle(int day, String weekday) {
    return 'День $day · $weekday';
  }

  @override
  String todayPlanSheetDayMacros(int kcal, int protein, int fat, int carbs) {
    return '$kcal ккал · Б $protein г · Ж $fat г · У $carbs г';
  }

  @override
  String todayPlanDayRowTitle(int day, String weekday) {
    return 'День $day · $weekday';
  }

  @override
  String todayPlanDayRowSubtitle(int count, String kcalPart) {
    return '$count приёмов пищи$kcalPart';
  }

  @override
  String todayPlanKcalApprox(int kcal) {
    return ' · ~$kcal ккал';
  }

  @override
  String get todayPlanNoSavedPlansSnack =>
      'Сохранённых планов пока нет. Создайте план на вкладке «Питание».';

  @override
  String get todayPlanMyPlans => 'Мои планы';

  @override
  String get todayPlanPickerHint =>
      'Нажми на план, чтобы сделать его активным. Корзина — удалить.';

  @override
  String get todayPlanDeleteTooltip => 'Удалить';

  @override
  String get todayPlanDeleteDialogTitle => 'Удалить план?';

  @override
  String todayPlanDeleteDialogBody(String name) {
    return '«$name» и все его дни будут удалены безвозвратно.';
  }

  @override
  String get todayPlanCancel => 'Отмена';

  @override
  String get todayPlanDelete => 'Удалить';

  @override
  String get todayPlanActiveSuffix => ' · активен';

  @override
  String get mealBreakfast => 'Завтрак';

  @override
  String get mealLunch => 'Обед';

  @override
  String get mealDinner => 'Ужин';

  @override
  String get mealSnack => 'Перекус';

  @override
  String get mealGeneric => 'Приём пищи';

  @override
  String get weekdayMon => 'Пн';

  @override
  String get weekdayTue => 'Вт';

  @override
  String get weekdayWed => 'Ср';

  @override
  String get weekdayThu => 'Чт';

  @override
  String get weekdayFri => 'Пт';

  @override
  String get weekdaySat => 'Сб';

  @override
  String get weekdaySun => 'Вс';

  @override
  String get recipeIngredients => 'Ингредиенты:';

  @override
  String get recipeSteps => 'Шаги:';

  @override
  String recipeIngredientLine(String name, String amount, String unit) {
    return '· $name — $amount $unit';
  }

  @override
  String recipeStepLine(int n, String text) {
    return '$n. $text';
  }

  @override
  String get recipeNoDetails => 'Нет деталей рецепта.';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String errorMissingApiKey(String provider) {
    return 'Укажите API-ключ для $provider в настройках.';
  }

  @override
  String errorNoRemoteSource(String provider) {
    return 'Не найден источник для $provider.';
  }

  @override
  String get errorPlanNotFound => 'План не найден.';

  @override
  String get errorEmptyPlanName =>
      'Введите название плана, так оно сохранится в списке.';

  @override
  String get errorInvalidBody => 'Некорректное значение.';

  @override
  String get errorFailedSaveLocal => 'Не удалось обновить локальное значение';

  @override
  String get errorInvalidAiPlan =>
      'Ответ ИИ не похож на план: неверный формат.';

  @override
  String get errorGroqMissingPlan => 'Модель вернула ответ без списка дней.';

  @override
  String get errorInvalidModelJson =>
      'Модель вернула некорректный JSON. Попробуйте ещё раз или смените модель.';

  @override
  String get errorGeminiFreeTier =>
      'Нет лимитов Gemini для этого ключа (free tier = 0). Нужен другой ключ или биллинг.';

  @override
  String get errorGeminiRateLimit =>
      'Gemini временно недоступен из-за лимитов. Попробуйте позже.';

  @override
  String get errorGeminiRequestFailed =>
      'Не удалось обратиться к Gemini. Проверьте сеть и ключ.';

  @override
  String errorAiBadRequestDecommissioned(String provider) {
    return '$provider: модель снята с поддержки. Выбери другую в настройках.';
  }

  @override
  String errorAiBadRequestGeneric(String provider) {
    return '$provider: запрос отклонён. Проверь модель и параметры в настройках.';
  }

  @override
  String errorAiAuth(String provider) {
    return '$provider: доступ запрещён. Проверь ключ и регион.';
  }

  @override
  String errorAiRateLimit(String provider) {
    return '$provider: слишком много запросов. Подожди или смени модель.';
  }

  @override
  String errorAiServer(String provider) {
    return '$provider: сервер временно недоступен.';
  }

  @override
  String errorAiNetwork(String provider) {
    return '$provider: запрос не выполнен. Проверь сеть, ключ и лимиты.';
  }

  @override
  String get navTabAds => 'Реклама';

  @override
  String get navTabSubscription => 'Подписка';

  @override
  String get adsTitle => 'Реклама';

  @override
  String get adsSdkStatus => 'Статус SDK';

  @override
  String get adsSdkInitialized => 'Инициализирован';

  @override
  String get adsSdkNotInitialized => 'Не инициализирован';

  @override
  String get adsBannerSection => 'Баннер';

  @override
  String get adsFormatsSection => 'Форматы';

  @override
  String get adsUnitIdLabel => 'Unit ID';

  @override
  String get adsNotConfigured => 'Не настроено';

  @override
  String get adsBannerLabel => 'Banner';

  @override
  String get adsInterstitialLabel => 'Interstitial';

  @override
  String get adsRewardedLabel => 'Rewarded';

  @override
  String get adsRewardedInterstitialLabel => 'Rewarded Interstitial';

  @override
  String get adsAppOpenLabel => 'App Open';

  @override
  String get adsNativeLabel => 'Native Advanced';

  @override
  String get adsShowAd => 'Показать';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionStatusSection => 'Статус';

  @override
  String get subscriptionPremium => 'Премиум-доступ';

  @override
  String get subscriptionActiveFlag => 'Активная подписка';

  @override
  String get subscriptionYes => 'Да';

  @override
  String get subscriptionNo => 'Нет';

  @override
  String get subscriptionUnknown => '—';

  @override
  String get subscriptionListSection => 'Активные подписки';

  @override
  String get subscriptionNoneActive => 'Нет активных подписок';

  @override
  String get subscriptionProductId => 'Продукт';

  @override
  String get subscriptionStatus => 'Статус';

  @override
  String get subscriptionExpiresAt => 'Истекает';

  @override
  String get subscriptionAutorenew => 'Авторенью';

  @override
  String get subscriptionPlacementsSection => 'Размещения (Placements)';

  @override
  String get subscriptionNoPlacements => 'Размещения ещё не загружены';

  @override
  String get subscriptionProductsSection => 'Продукты paywall';

  @override
  String get subscriptionNoProducts => 'Продукты ещё не загружены';

  @override
  String get subscriptionRestore => 'Восстановить покупки';

  @override
  String get subscriptionRestoreSuccess => 'Покупки успешно восстановлены';

  @override
  String get subscriptionRestoreFailed => 'Не удалось восстановить покупки';

  @override
  String get subscriptionRestoreNothing => 'Активных покупок не найдено';

  @override
  String get subscriptionSdkNotReady => 'Apphud SDK не инициализирован';

  @override
  String get subscriptionBuy => 'Купить';

  @override
  String get subscriptionPurchaseSuccess => 'Подписка успешно оформлена';

  @override
  String get subscriptionPurchaseFailed => 'Не удалось оформить подписку';

  @override
  String get subscriptionPurchasing => 'Оформляем...';

  @override
  String get subscriptionWeekly => 'Еженедельно';

  @override
  String get subscriptionMonthly => 'Ежемесячно';
}
