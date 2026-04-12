import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Right Way'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ru, this message translates to:
  /// **'Правильное питание и здоровый образ жизни'**
  String get appTagline;

  /// No description provided for @navTabBody.
  ///
  /// In ru, this message translates to:
  /// **'Тело'**
  String get navTabBody;

  /// No description provided for @navTabNutrition.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get navTabNutrition;

  /// No description provided for @navTabPlan.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get navTabPlan;

  /// No description provided for @navTabSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navTabSettings;

  /// No description provided for @bodyScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тело'**
  String get bodyScreenTitle;

  /// No description provided for @bodyHeightCm.
  ///
  /// In ru, this message translates to:
  /// **'Рост (см)'**
  String get bodyHeightCm;

  /// No description provided for @bodyWeightKg.
  ///
  /// In ru, this message translates to:
  /// **'Вес (кг)'**
  String get bodyWeightKg;

  /// No description provided for @bodyAge.
  ///
  /// In ru, this message translates to:
  /// **'Возраст'**
  String get bodyAge;

  /// No description provided for @bodyOpenTodayPlan.
  ///
  /// In ru, this message translates to:
  /// **'Открыть план на сегодня'**
  String get bodyOpenTodayPlan;

  /// No description provided for @nutritionPlanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки плана'**
  String get nutritionPlanTitle;

  /// No description provided for @nutritionDaysInPlan.
  ///
  /// In ru, this message translates to:
  /// **'Дней в плане: {days}'**
  String nutritionDaysInPlan(int days);

  /// No description provided for @nutritionGoalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get nutritionGoalLabel;

  /// No description provided for @goalWeightLoss.
  ///
  /// In ru, this message translates to:
  /// **'Похудение'**
  String get goalWeightLoss;

  /// No description provided for @goalMuscleGain.
  ///
  /// In ru, this message translates to:
  /// **'Масса'**
  String get goalMuscleGain;

  /// No description provided for @goalHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get goalHealth;

  /// No description provided for @nutritionPlanName.
  ///
  /// In ru, this message translates to:
  /// **'Название плана'**
  String get nutritionPlanName;

  /// No description provided for @nutritionPlanNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Как назвать этот план в списке'**
  String get nutritionPlanNameHint;

  /// No description provided for @nutritionExcludedProducts.
  ///
  /// In ru, this message translates to:
  /// **'Исключить продукты (через запятую)'**
  String get nutritionExcludedProducts;

  /// No description provided for @nutritionCalculate.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать'**
  String get nutritionCalculate;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить настройки.'**
  String get settingsLoadError;

  /// No description provided for @settingsRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get settingsRetry;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeHint.
  ///
  /// In ru, this message translates to:
  /// **'Тема интерфейса'**
  String get settingsThemeHint;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Свет'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тьма'**
  String get settingsThemeDark;

  /// No description provided for @settingsModelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get settingsModelLabel;

  /// No description provided for @settingsSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get settingsSave;

  /// No description provided for @settingsApiKey.
  ///
  /// In ru, this message translates to:
  /// **'API ключ'**
  String get settingsApiKey;

  /// No description provided for @settingsShowKey.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get settingsShowKey;

  /// No description provided for @settingsHideKey.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get settingsHideKey;

  /// No description provided for @settingsSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get settingsSaved;

  /// No description provided for @todayPlanAppBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get todayPlanAppBarTitle;

  /// No description provided for @todayPlanSegmentToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayPlanSegmentToday;

  /// No description provided for @todayPlanSegmentFull.
  ///
  /// In ru, this message translates to:
  /// **'Весь план'**
  String get todayPlanSegmentFull;

  /// No description provided for @todayPlanPlansButton.
  ///
  /// In ru, this message translates to:
  /// **'Планы'**
  String get todayPlanPlansButton;

  /// No description provided for @todayPlanLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить план. Потяни вниз, чтобы обновить.'**
  String get todayPlanLoadFailed;

  /// No description provided for @todayPlanEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сохранённых планов или в плане нет дней. Создай план на вкладке «Питание» и при необходимости выбери активный план.'**
  String get todayPlanEmpty;

  /// No description provided for @todayPlanNoTodayMatch.
  ///
  /// In ru, this message translates to:
  /// **'В активном плане нет дня, совпадающего с сегодняшним по схеме недели. Открой «Весь план» или выбери другой активный план.'**
  String get todayPlanNoTodayMatch;

  /// No description provided for @todayPlanDayTotals.
  ///
  /// In ru, this message translates to:
  /// **'За день: {kcal} ккал · Б {protein} г · Ж {fat} г · У {carbs} г'**
  String todayPlanDayTotals(int kcal, int protein, int fat, int carbs);

  /// No description provided for @todayPlanMealSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{kcal} ккал · Б {protein} г'**
  String todayPlanMealSubtitle(int kcal, int protein);

  /// No description provided for @todayPlanSheetDayTitle.
  ///
  /// In ru, this message translates to:
  /// **'День {day} · {weekday}'**
  String todayPlanSheetDayTitle(int day, String weekday);

  /// No description provided for @todayPlanSheetDayMacros.
  ///
  /// In ru, this message translates to:
  /// **'{kcal} ккал · Б {protein} г · Ж {fat} г · У {carbs} г'**
  String todayPlanSheetDayMacros(int kcal, int protein, int fat, int carbs);

  /// No description provided for @todayPlanDayRowTitle.
  ///
  /// In ru, this message translates to:
  /// **'День {day} · {weekday}'**
  String todayPlanDayRowTitle(int day, String weekday);

  /// No description provided for @todayPlanDayRowSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count} приёмов пищи{kcalPart}'**
  String todayPlanDayRowSubtitle(int count, String kcalPart);

  /// No description provided for @todayPlanKcalApprox.
  ///
  /// In ru, this message translates to:
  /// **' · ~{kcal} ккал'**
  String todayPlanKcalApprox(int kcal);

  /// No description provided for @todayPlanNoSavedPlansSnack.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённых планов пока нет. Создайте план на вкладке «Питание».'**
  String get todayPlanNoSavedPlansSnack;

  /// No description provided for @todayPlanMyPlans.
  ///
  /// In ru, this message translates to:
  /// **'Мои планы'**
  String get todayPlanMyPlans;

  /// No description provided for @todayPlanPickerHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажми на план, чтобы сделать его активным. Корзина — удалить.'**
  String get todayPlanPickerHint;

  /// No description provided for @todayPlanDeleteTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get todayPlanDeleteTooltip;

  /// No description provided for @todayPlanDeleteDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить план?'**
  String get todayPlanDeleteDialogTitle;

  /// No description provided for @todayPlanDeleteDialogBody.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» и все его дни будут удалены безвозвратно.'**
  String todayPlanDeleteDialogBody(String name);

  /// No description provided for @todayPlanCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get todayPlanCancel;

  /// No description provided for @todayPlanDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get todayPlanDelete;

  /// No description provided for @todayPlanActiveSuffix.
  ///
  /// In ru, this message translates to:
  /// **' · активен'**
  String get todayPlanActiveSuffix;

  /// No description provided for @mealBreakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтрак'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In ru, this message translates to:
  /// **'Обед'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In ru, this message translates to:
  /// **'Ужин'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In ru, this message translates to:
  /// **'Перекус'**
  String get mealSnack;

  /// No description provided for @mealGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Приём пищи'**
  String get mealGeneric;

  /// No description provided for @weekdayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get weekdaySun;

  /// No description provided for @recipeIngredients.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиенты:'**
  String get recipeIngredients;

  /// No description provided for @recipeSteps.
  ///
  /// In ru, this message translates to:
  /// **'Шаги:'**
  String get recipeSteps;

  /// No description provided for @recipeIngredientLine.
  ///
  /// In ru, this message translates to:
  /// **'· {name} — {amount} {unit}'**
  String recipeIngredientLine(String name, String amount, String unit);

  /// No description provided for @recipeStepLine.
  ///
  /// In ru, this message translates to:
  /// **'{n}. {text}'**
  String recipeStepLine(int n, String text);

  /// No description provided for @recipeNoDetails.
  ///
  /// In ru, this message translates to:
  /// **'Нет деталей рецепта.'**
  String get recipeNoDetails;

  /// No description provided for @errorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз.'**
  String get errorGeneric;

  /// No description provided for @errorMissingApiKey.
  ///
  /// In ru, this message translates to:
  /// **'Укажите API-ключ для {provider} в настройках.'**
  String errorMissingApiKey(String provider);

  /// No description provided for @errorNoRemoteSource.
  ///
  /// In ru, this message translates to:
  /// **'Не найден источник для {provider}.'**
  String errorNoRemoteSource(String provider);

  /// No description provided for @errorPlanNotFound.
  ///
  /// In ru, this message translates to:
  /// **'План не найден.'**
  String get errorPlanNotFound;

  /// No description provided for @errorEmptyPlanName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название плана, так оно сохранится в списке.'**
  String get errorEmptyPlanName;

  /// No description provided for @errorInvalidBody.
  ///
  /// In ru, this message translates to:
  /// **'Некорректное значение.'**
  String get errorInvalidBody;

  /// No description provided for @errorFailedSaveLocal.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить локальное значение'**
  String get errorFailedSaveLocal;

  /// No description provided for @errorInvalidAiPlan.
  ///
  /// In ru, this message translates to:
  /// **'Ответ ИИ не похож на план: неверный формат.'**
  String get errorInvalidAiPlan;

  /// No description provided for @errorGroqMissingPlan.
  ///
  /// In ru, this message translates to:
  /// **'Модель вернула ответ без списка дней.'**
  String get errorGroqMissingPlan;

  /// No description provided for @errorInvalidModelJson.
  ///
  /// In ru, this message translates to:
  /// **'Модель вернула некорректный JSON. Попробуйте ещё раз или смените модель.'**
  String get errorInvalidModelJson;

  /// No description provided for @errorGeminiFreeTier.
  ///
  /// In ru, this message translates to:
  /// **'Нет лимитов Gemini для этого ключа (free tier = 0). Нужен другой ключ или биллинг.'**
  String get errorGeminiFreeTier;

  /// No description provided for @errorGeminiRateLimit.
  ///
  /// In ru, this message translates to:
  /// **'Gemini временно недоступен из-за лимитов. Попробуйте позже.'**
  String get errorGeminiRateLimit;

  /// No description provided for @errorGeminiRequestFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обратиться к Gemini. Проверьте сеть и ключ.'**
  String get errorGeminiRequestFailed;

  /// No description provided for @errorAiBadRequestDecommissioned.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: модель снята с поддержки. Выбери другую в настройках.'**
  String errorAiBadRequestDecommissioned(String provider);

  /// No description provided for @errorAiBadRequestGeneric.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: запрос отклонён. Проверь модель и параметры в настройках.'**
  String errorAiBadRequestGeneric(String provider);

  /// No description provided for @errorAiAuth.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: доступ запрещён. Проверь ключ и регион.'**
  String errorAiAuth(String provider);

  /// No description provided for @errorAiRateLimit.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: слишком много запросов. Подожди или смени модель.'**
  String errorAiRateLimit(String provider);

  /// No description provided for @errorAiServer.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: сервер временно недоступен.'**
  String errorAiServer(String provider);

  /// No description provided for @errorAiNetwork.
  ///
  /// In ru, this message translates to:
  /// **'{provider}: запрос не выполнен. Проверь сеть, ключ и лимиты.'**
  String errorAiNetwork(String provider);

  /// No description provided for @navTabAds.
  ///
  /// In ru, this message translates to:
  /// **'Реклама'**
  String get navTabAds;

  /// No description provided for @navTabSubscription.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get navTabSubscription;

  /// No description provided for @adsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Реклама'**
  String get adsTitle;

  /// No description provided for @adsSdkStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус SDK'**
  String get adsSdkStatus;

  /// No description provided for @adsSdkInitialized.
  ///
  /// In ru, this message translates to:
  /// **'Инициализирован'**
  String get adsSdkInitialized;

  /// No description provided for @adsSdkNotInitialized.
  ///
  /// In ru, this message translates to:
  /// **'Не инициализирован'**
  String get adsSdkNotInitialized;

  /// No description provided for @adsBannerSection.
  ///
  /// In ru, this message translates to:
  /// **'Баннер'**
  String get adsBannerSection;

  /// No description provided for @adsFormatsSection.
  ///
  /// In ru, this message translates to:
  /// **'Форматы'**
  String get adsFormatsSection;

  /// No description provided for @adsUnitIdLabel.
  ///
  /// In ru, this message translates to:
  /// **'Unit ID'**
  String get adsUnitIdLabel;

  /// No description provided for @adsNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Не настроено'**
  String get adsNotConfigured;

  /// No description provided for @adsBannerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Banner'**
  String get adsBannerLabel;

  /// No description provided for @adsInterstitialLabel.
  ///
  /// In ru, this message translates to:
  /// **'Interstitial'**
  String get adsInterstitialLabel;

  /// No description provided for @adsRewardedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Rewarded'**
  String get adsRewardedLabel;

  /// No description provided for @adsRewardedInterstitialLabel.
  ///
  /// In ru, this message translates to:
  /// **'Rewarded Interstitial'**
  String get adsRewardedInterstitialLabel;

  /// No description provided for @adsAppOpenLabel.
  ///
  /// In ru, this message translates to:
  /// **'App Open'**
  String get adsAppOpenLabel;

  /// No description provided for @adsNativeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Native Advanced'**
  String get adsNativeLabel;

  /// No description provided for @adsShowAd.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get adsShowAd;

  /// No description provided for @subscriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionStatusSection.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get subscriptionStatusSection;

  /// No description provided for @subscriptionPremium.
  ///
  /// In ru, this message translates to:
  /// **'Премиум-доступ'**
  String get subscriptionPremium;

  /// No description provided for @subscriptionActiveFlag.
  ///
  /// In ru, this message translates to:
  /// **'Активная подписка'**
  String get subscriptionActiveFlag;

  /// No description provided for @subscriptionYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get subscriptionYes;

  /// No description provided for @subscriptionNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get subscriptionNo;

  /// No description provided for @subscriptionUnknown.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get subscriptionUnknown;

  /// No description provided for @subscriptionListSection.
  ///
  /// In ru, this message translates to:
  /// **'Активные подписки'**
  String get subscriptionListSection;

  /// No description provided for @subscriptionNoneActive.
  ///
  /// In ru, this message translates to:
  /// **'Нет активных подписок'**
  String get subscriptionNoneActive;

  /// No description provided for @subscriptionProductId.
  ///
  /// In ru, this message translates to:
  /// **'Продукт'**
  String get subscriptionProductId;

  /// No description provided for @subscriptionStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get subscriptionStatus;

  /// No description provided for @subscriptionExpiresAt.
  ///
  /// In ru, this message translates to:
  /// **'Истекает'**
  String get subscriptionExpiresAt;

  /// No description provided for @subscriptionAutorenew.
  ///
  /// In ru, this message translates to:
  /// **'Авторенью'**
  String get subscriptionAutorenew;

  /// No description provided for @subscriptionPlacementsSection.
  ///
  /// In ru, this message translates to:
  /// **'Размещения (Placements)'**
  String get subscriptionPlacementsSection;

  /// No description provided for @subscriptionNoPlacements.
  ///
  /// In ru, this message translates to:
  /// **'Размещения ещё не загружены'**
  String get subscriptionNoPlacements;

  /// No description provided for @subscriptionProductsSection.
  ///
  /// In ru, this message translates to:
  /// **'Продукты paywall'**
  String get subscriptionProductsSection;

  /// No description provided for @subscriptionNoProducts.
  ///
  /// In ru, this message translates to:
  /// **'Продукты ещё не загружены'**
  String get subscriptionNoProducts;

  /// No description provided for @subscriptionRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить покупки'**
  String get subscriptionRestore;

  /// No description provided for @subscriptionRestoreSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Покупки успешно восстановлены'**
  String get subscriptionRestoreSuccess;

  /// No description provided for @subscriptionRestoreFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось восстановить покупки'**
  String get subscriptionRestoreFailed;

  /// No description provided for @subscriptionRestoreNothing.
  ///
  /// In ru, this message translates to:
  /// **'Активных покупок не найдено'**
  String get subscriptionRestoreNothing;

  /// No description provided for @subscriptionSdkNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Apphud SDK не инициализирован'**
  String get subscriptionSdkNotReady;

  /// No description provided for @subscriptionBuy.
  ///
  /// In ru, this message translates to:
  /// **'Купить'**
  String get subscriptionBuy;

  /// No description provided for @subscriptionPurchaseSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Подписка успешно оформлена'**
  String get subscriptionPurchaseSuccess;

  /// No description provided for @subscriptionPurchaseFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось оформить подписку'**
  String get subscriptionPurchaseFailed;

  /// No description provided for @subscriptionPurchasing.
  ///
  /// In ru, this message translates to:
  /// **'Оформляем...'**
  String get subscriptionPurchasing;

  /// No description provided for @subscriptionWeekly.
  ///
  /// In ru, this message translates to:
  /// **'Еженедельно'**
  String get subscriptionWeekly;

  /// No description provided for @subscriptionMonthly.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячно'**
  String get subscriptionMonthly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
