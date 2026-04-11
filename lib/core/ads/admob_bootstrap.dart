import 'dart:developer';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:right_way/core/config/app_env.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Ранняя инициализация Google Mobile Ads после загрузки `.env`.
///
/// На Android/iOS в манифесте / Info.plist должен быть тот же [Env.admobAppId],
/// что и в `.env` (см. [официальный quick start](https://developers.google.com/admob/flutter/quick-start)).
class AdMobBootstrap {
  AdMobBootstrap._();

  static bool _initialized = false;

  static bool get initialized => _initialized;

  static Future<void> init(Talker talker, {bool enable = true}) async {
    if (!enable) {
      log('AdMob is disabled', name: '$AdMobBootstrap');
      return;
    }
    if (_initialized) return;
    if (kIsWeb) return;
    if (Env.admobAppId.isEmpty) {
      talker.warning('AdMob: ADMOB_APP_ID пуст — SDK не инициализирован.');
      return;
    }
    try {
      final status = await MobileAds.instance.initialize();
      _initialized = true;
      final adapters = status.adapterStatuses.entries.map((e) => '${e.key}:${e.value.state.name}').join(', ');
      talker.info('AdMob initialized ($adapters).');
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['GADSimulatorID']));
      }
    } catch (e, st) {
      talker.error('AdMob init failed.', e, st);
    }
  }
}
