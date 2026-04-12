import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:apphud/apphud.dart';
import 'package:apphud/models/apphud_models/apphud_attribution_data.dart';
import 'package:apphud/models/apphud_models/apphud_attribution_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:right_way/core/config/app_env.dart';
import 'package:right_way/core/di/core_di.dart';
import 'package:right_way/core/purchases/apphud_subscription_service.dart';
import 'package:right_way/core/purchases/appsflyer_apphud_attribution.dart';
import 'package:right_way/core/telemetry/app_telemetry.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Старт AppHud, listener, атрибуция (AppsFlyer, Firebase, Apple Search Ads).
class ApphudBootstrap {
  ApphudBootstrap._();

  static Future<void> init(Talker talker, {bool enable = true}) async {
    final apiKey = Env.apphudApiKey;
    if (!enable || apiKey.isEmpty) {
      talker.info('Apphud: пропуск - нет APPHUD_API_KEY или enable=false');
      return;
    }
    if (di.isRegistered<ApphudSubscriptionService>()) {
      talker.warning('Apphud: ApphudSubscriptionService уже зарегистрирован');
      return;
    }

    try {

      if (kDebugMode) {
        await Apphud.enableDebugLogs();
      } 

      const int timeoutS = 3;
      try {
        await Apphud.start(apiKey: apiKey).timeout( Duration(seconds: timeoutS));
      } on TimeoutException {
        // Android SDK не вызывает completion callback при сетевых ошибках (403/5xx) —
        // Future зависает. Продолжаем инициализацию: SDK продолжит работу в фоне.
        talker.warning('Apphud: start() timeout ($timeoutS с). Apphud initialization error');
        return;
      }
      if (Platform.isAndroid) {
        await Apphud.collectDeviceIdentifiers();
      } else if (Platform.isIOS) {
        await _setIosAdvertisingIdentifier(talker);
      }
      final service = ApphudSubscriptionService(talker);
      await Apphud.setListener(listener: service);
      di.registerSingleton<ApphudSubscriptionService>(service);
      await service.refreshPremiumFlags();
      try {
        final pl = await Apphud.placements();
        service.ingestPlacements(pl);
      } catch (e, st) {
        talker.error('Apphud: placements()', e, st);
      }
      await AppsFlyerApphudAttribution.flushPending(talker);
      await _sendAttribution(talker);
      talker.info('Apphud: SDK запущен');
    } catch (e, st) {
      talker.error('Apphud: ошибка инициализации', e, st);
    }
  }

  /// iOS: передаёт IDFA (если ATT authorized) и автоматически собирает IDFV.
  /// Нужен для корректной работы MMP-атрибуции (AppsFlyer и др.) — без IDFV
  /// события могут зависнуть в Pending-статусе на стороне Apphud.
  static Future<void> _setIosAdvertisingIdentifier(Talker talker) async {
    try {
      var idfa = '';
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.authorized) {
        final raw = await AppTrackingTransparency.getAdvertisingIdentifier();
        if (raw != '00000000-0000-0000-0000-000000000000') {
          idfa = raw;
        }
      }
      await Apphud.setAdvertisingIdentifier(idfa);
      talker.info(
        'Apphud: setAdvertisingIdentifier — '
        '${idfa.isEmpty ? 'пусто (ATT не authorized), IDFV собран SDK' : idfa}',
      );
    } catch (e, st) {
      talker.error('Apphud: setAdvertisingIdentifier', e, st);
    }
  }

  static Future<void> _sendAttribution(Talker talker) async {
    if (!di.isRegistered<AppTelemetry>()) return;
    final telemetry = di<AppTelemetry>();

    final af = telemetry.appsflyerSdk;
    if (af != null) {
      try {
        final uid = await af.getAppsFlyerUID();
        if (uid != null && uid.isNotEmpty) {
          final ok = await Apphud.setAttribution(
            provider: ApphudAttributionProvider.appsFlyer,
            data: ApphudAttributionData(rawData: {'appsflyer_id': uid}),
            identifier: uid,
          );
          talker.info('Apphud: AppsFlyer UID (fallback) ${ok ? 'отправлен' : 'отклонён'}');
        }
      } catch (e, st) {
        talker.error('Apphud: AppsFlyer UID fallback', e, st);
      }
    }

    final fa = telemetry.firebaseAnalytics;
    if (fa != null) {
      try {
        // См. https://docs.apphud.com/docs/firebase — сопоставление User ID
        // между Apphud и Firebase и передача instance ID в Apphud через identifier.
        final apphudUserId = await Apphud.userID();
        await fa.setUserId(id: apphudUserId);

        final instanceId = await fa.appInstanceId;
        if (instanceId != null && instanceId.isNotEmpty) {
          final ok = await Apphud.setAttribution(
            provider: ApphudAttributionProvider.firebase,
            data: ApphudAttributionData(rawData: {}),
            identifier: instanceId,
          );
          talker.info('Apphud: атрибуция Firebase ${ok ? 'отправлена' : 'не принята'}');
        }
      } catch (e, st) {
        talker.error('Apphud: Firebase attribution', e, st);
      }
    }

    if (Platform.isIOS) {
      try {
        final ads = await Apphud.collectSearchAdsAttribution().timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
        if (ads != null && ads.isNotEmpty) {
          final ok = await Apphud.setAttribution(
            provider: ApphudAttributionProvider.appleAdsAttribution,
            data: ApphudAttributionData(rawData: Map<String, dynamic>.from(ads)),
          );
          talker.info('Apphud: Apple Search Ads ${ok ? 'отправлено' : 'не принято'}');
        } else {
          talker.info(
            'Apphud: Apple Search Ads — нет данных (часто симулятор или таймаут 3 c).',
          );
        }
      } catch (e, st) {
        talker.error('Apphud: Apple Search Ads', e, st);
      }
    }
  }
}
