import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Значения из `.env`. Нужен вызов `dotenv.load` в `main.dart` до `AppInitializer.init`.
class Env {
  Env._();

  static String get apphudApiKey => dotenv.get('APPHUD_API_KEY', fallback: '');

  static String get apphudBundleId => dotenv.get('APPHUD_BUNDLE_ID', fallback: '');

  static String get apphudPaywallId => dotenv.get('APPHUD_PAYWALL_ID', fallback: '');

  static String get apphudProductWeeklyId => dotenv.get('APPHUD_PRODUCT_WEEKLY_ID', fallback: '');

  static String get apphudProductMonthlyId => dotenv.get('APPHUD_PRODUCT_MONTHLY_ID', fallback: '');

  static String get appsflyerDevKey => dotenv.get('APPSFLYER_DEV_KEY', fallback: '');

  static String get appsflyerAppleAppId => dotenv.get('APPSFLYER_APPLE_APP_ID', fallback: '');

  static String get appmetricaApiKey => dotenv.get('APPMETRICA_API_KEY', fallback: '');

  /// `current_key` из `android/app/google-services.json` (не коммитить в репозиторий).
  static String get firebaseAndroidApiKey => dotenv.get('FIREBASE_ANDROID_API_KEY', fallback: '');

  /// `API_KEY` из `ios/Runner/GoogleService-Info.plist`.
  static String get firebaseIosApiKey => dotenv.get('FIREBASE_IOS_API_KEY', fallback: '');

  static String get admobAppId => dotenv.get('ADMOB_APP_ID', fallback: '');

  static String get admobBannerAdUnitId => dotenv.get('ADMOB_BANNER_AD_UNIT_ID', fallback: '');

  static String get admobInterstitialAdUnitId => dotenv.get('ADMOB_INTERSTITIAL_AD_UNIT_ID', fallback: '');

  static String get admobRewardedAdUnitId => dotenv.get('ADMOB_REWARDED_AD_UNIT_ID', fallback: '');

  static String get admobRewardedInterstitialAdUnitId =>
      dotenv.get('ADMOB_REWARDED_INTERSTITIAL_AD_UNIT_ID', fallback: '');

  static String get admobAppOpenAdUnitId => dotenv.get('ADMOB_APP_OPEN_AD_UNIT_ID', fallback: '');

  static String get admobNativeAdUnitId => dotenv.get('ADMOB_NATIVE_AD_UNIT_ID', fallback: '');

  /// iOS Simulator: принудительно `GADSimulatorID`, если автоопределение симулятора не сработало.
  static bool get admobIosSimulatorTestDevice =>
      dotenv.get('ADMOB_IOS_SIMULATOR_TEST_DEVICE', fallback: '').toLowerCase() == 'true';

  /// Android emulator: принудительно id эмулятора GMA, если автоопределение не сработало.
  static bool get admobAndroidEmulatorTestDevice =>
      dotenv.get('ADMOB_ANDROID_EMULATOR_TEST_DEVICE', fallback: '').toLowerCase() == 'true';
}
