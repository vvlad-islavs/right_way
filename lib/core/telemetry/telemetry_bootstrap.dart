import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:right_way/core/config/app_env.dart';
import 'package:right_way/core/di/core_di.dart';
import 'package:right_way/core/purchases/appsflyer_apphud_attribution.dart';
import 'package:right_way/core/errors/errors.dart';
import 'package:right_way/core/telemetry/app_telemetry.dart';
import 'package:right_way/firebase_options.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Инициализация Firebase (Analytics + Crashlytics), AppMetrica, AppsFlyer и регистрация [AppTelemetry].
class TelemetryBootstrap {
  TelemetryBootstrap._();

  static bool _firebaseReady = false;

  /// Вызывать из зоны после [Firebase.initializeApp], если нужно отправить фатал до полного bootstrap.
  static void reportFatalIfReady(Object error, StackTrace stack) {
    if (!_firebaseReady) return;
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }

  static Future<void> init(Talker talker, {bool enableTalker = true, bool enable = true}) async {
    if (!enable) {
      final telemetry = AppTelemetry(
        talker: null,
        analytics: null,
        crashlytics: null,
        appsflyer: null,
        appMetricaActive: false,
      );
      di.registerSingleton<AppTelemetry>(telemetry);

      if (!enable) {
        log('AppTelemetry is disabled', name: 'TelemetryBootstrap');
      }
      return;
    }

    FirebaseAnalytics? analytics;
    FirebaseCrashlytics? crashlytics;
    AppsflyerSdk? appsflyer;
    var appMetricaActive = false;

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _firebaseReady = true;
      analytics = FirebaseAnalytics.instance;
      crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(true);

      FlutterError.onError = (FlutterErrorDetails details) {
        crashlytics!.recordFlutterError(details, fatal: false);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      talker.info('Firebase initialized (Analytics + Crashlytics).');
    } catch (e, st) {
      _firebaseReady = false;
      talker.error('Firebase init failed — Analytics/Crashlytics отключены.', e, st);
    }

    final metricaKey = Env.appmetricaApiKey;
    if (metricaKey.isNotEmpty) {
      try {
        await AppMetrica.activate(
          AppMetricaConfig(
            metricaKey,
            logs: kDebugMode,
            flutterCrashReporting: false,
            crashReporting: false,
            nativeCrashReporting: false,
          ),
        );
        appMetricaActive = true;
        talker.info('AppMetrica activated.');
      } catch (e, st) {
        talker.error('AppMetrica init failed.', e, st);
      }
    } else {
      talker.warning('APPMETRICA_API_KEY пуст — AppMetrica не запущена.');
    }

    final afKey = Env.appsflyerDevKey;
    if (afKey.isEmpty) {
      talker.warning('APPSFLYER_DEV_KEY пуст — AppsFlyer не запущен.');
    } else if (Platform.isAndroid) {
      // Пока в AppsFlyer на Anroid вовзращает 400 код ошибки
      talker.info('AppsFlyer на Android возвращает 400 код ошибки, пропускаем.');
    } else {
      try {
        final options = AppsFlyerOptions(
          afDevKey: afKey,
          appId: Env.appsflyerAppleAppId,
          showDebug: kDebugMode,
          timeToWaitForATTUserAuthorization: Platform.isIOS ? 60 : null,
          manualStart: true,
        );
        appsflyer = AppsflyerSdk(options);

        await appsflyer.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true,
        );

        appsflyer.onInstallConversionData((dynamic data) {
          AppsFlyerApphudAttribution.onInstallConversionData(talker, data);
          talker.info('AppsFlyer install conversion: $data');
        });
        appsflyer.onAppOpenAttribution((dynamic data) {
          AppsFlyerApphudAttribution.onAppOpenAttribution(talker, data);
          talker.info('AppsFlyer app open attribution: $data');
        });

        appsflyer.startSDK();

        talker.info('AppsFlyer SDK started.');
        await _runIosAttFlow(talker);
      } catch (e, st) {
        talker.error('AppsFlyer init failed.', e, st);
        appsflyer = null;
      }
    }

    final telemetry = AppTelemetry(
      talker: enableTalker ? talker : null,
      analytics: analytics,
      crashlytics: crashlytics,
      appsflyer: appsflyer,
      appMetricaActive: appMetricaActive,
    );
    di.registerSingleton<AppTelemetry>(telemetry);

    await telemetry.logCustomEvent('rw_app_start', {'debug': kDebugMode.toString()});
  }

  /// Вызывать после [CoreDi.init] — подписывает [ErrorReporter] на Crashlytics non-fatal.
  static void wireErrorReporter() {
    if (!di.isRegistered<AppTelemetry>() || !di.isRegistered<ErrorReporter>()) {
      log('Failed to connect NonFatalErrors: One of services not registered in GetIt', name: 'TelemetryBootstrap');
      return;
    }

    final telemetry = di<AppTelemetry>();
    di<ErrorReporter>().stream.listen((appError) {
      final cause = appError.cause;
      if (cause == null) return;
      telemetry.recordNonFatal(cause, appError.stackTrace ?? StackTrace.empty, reason: appError.debugMessage);
    });
  }
}

/// iOS 14+: ATT-диалог в окне [AppsFlyerOptions.timeToWaitForATTUserAuthorization].
/// Нативный AppsFlyer SDK сам читает [ATTrackingManager] после ответа пользователя.
Future<void> _runIosAttFlow(Talker talker) async {
  try {
    var status = await AppTrackingTransparency.trackingAuthorizationStatus;
    talker.info('ATT: текущий статус до запроса — ${_attStatusLabel(status)}');

    switch (status) {
      case TrackingStatus.notSupported:
        talker.info('ATT: не поддерживается (версия ОС / платформа).');
        return;
      case TrackingStatus.restricted:
        talker.warning('ATT: restricted — диалог недоступен, трекинг ограничен на устройстве.');
        return;
      case TrackingStatus.denied:
        talker.info('ATT: denied — пользователь ранее отказал.');
        return;
      case TrackingStatus.authorized:
        talker.info('ATT: authorized — доступ к трекингу уже выдан.');
        return;
      case TrackingStatus.notDetermined:
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        talker.info('ATT: ответ пользователя — ${_attStatusLabel(status)}');
        _logAttOutcome(talker, status);
        return;
    }
  } catch (e, st) {
    talker.error('ATT: ошибка', e, st);
  }
}

void _logAttOutcome(Talker talker, TrackingStatus status) {
  switch (status) {
    case TrackingStatus.authorized:
      talker.info('ATT: AppsFlyer получит статус из системы (IDFA при разрешении).');
    case TrackingStatus.denied:
      talker.info('ATT: отказ — AppsFlyer работает без IDFA (SKAN и др.).');
    case TrackingStatus.restricted:
      talker.warning('ATT: restricted после запроса.');
    case TrackingStatus.notDetermined:
      talker.warning('ATT: всё ещё notDetermined после диалога.');
    case TrackingStatus.notSupported:
      talker.debug('ATT: notSupported после запроса.');
  }
}

String _attStatusLabel(TrackingStatus status) => switch (status) {
  TrackingStatus.notDetermined => 'notDetermined',
  TrackingStatus.restricted => 'restricted',
  TrackingStatus.denied => 'denied',
  TrackingStatus.authorized => 'authorized',
  TrackingStatus.notSupported => 'notSupported',
};
