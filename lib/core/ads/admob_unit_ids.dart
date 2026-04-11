import 'package:right_way/core/config/app_env.dart';

/// Идентификаторы рекламных блоков из `.env` ([Env] / [Env]).
///
/// При использовании [официальных тестовых unit id](https://developers.google.com/admob/android/test-ads)
/// запросы безопасны для разработки.
abstract final class AdMobUnitIds {
  static String get banner => Env.admobBannerAdUnitId;

  static String get interstitial => Env.admobInterstitialAdUnitId;

  static String get rewarded => Env.admobRewardedAdUnitId;

  static String get rewardedInterstitial => Env.admobRewardedInterstitialAdUnitId;

  static String get appOpen => Env.admobAppOpenAdUnitId;

  static String get nativeAdvanced => Env.admobNativeAdUnitId;

  static bool get hasAnyAdUnit =>
      banner.isNotEmpty ||
      interstitial.isNotEmpty ||
      rewarded.isNotEmpty ||
      rewardedInterstitial.isNotEmpty ||
      appOpen.isNotEmpty ||
      nativeAdvanced.isNotEmpty;
}
