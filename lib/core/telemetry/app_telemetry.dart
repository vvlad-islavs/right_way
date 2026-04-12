import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Единая точка для событий и ошибок.
///
/// Роли SDK:
/// - **Firebase Analytics** — воронки, аудитории, связка с BigQuery / GA4.
/// - **Firebase Crashlytics** — падения и нефатальные ошибки (основной crash-отчёт).
/// - **AppsFlyer** — атрибуция установок и in-app для ROI / медиа-источников.
/// - **AppMetrica** — продуктовая аналитика и рынки, где сильна Метрика (дублирование crash отключено).
class AppTelemetry {
  AppTelemetry({
    required Talker? talker,
    required FirebaseAnalytics? analytics,
    required FirebaseCrashlytics? crashlytics,
    required AppsflyerSdk? appsflyer,
    required bool appMetricaActive,
  }) : _talker = talker,
       _analytics = analytics,
       _crashlytics = crashlytics,
       _appsflyer = appsflyer,
       _appMetricaActive = appMetricaActive;

  final Talker? _talker;
  final FirebaseAnalytics? _analytics;
  final FirebaseCrashlytics? _crashlytics;
  final AppsflyerSdk? _appsflyer;
  final bool _appMetricaActive;

  /// Для AppHud и др. интеграций после старта телеметрии.
  FirebaseAnalytics? get firebaseAnalytics => _analytics;

  AppsflyerSdk? get appsflyerSdk => _appsflyer;

  /// Экраны: Firebase (GA4) + AppMetrica; в AppsFlyer — облегчённое событие для воронок.
  Future<void> logScreenView(String screenName) async {
    final name = _truncate(_sanitizeName(screenName), 100);
    await Future.wait([
      _safe(
        'firebase_analytics',
        'logScreenView($name)',
        active: _analytics != null,
        fn: () async => _analytics!.logScreenView(screenName: name),
      ),
      _safe(
        'appmetrica',
        'rw_screen($name)',
        active: _appMetricaActive,
        fn: () async => AppMetrica.reportEventWithMap('rw_screen', {'screen': name}),
      ),
      _safe(
        'appsflyer',
        'rw_screen($name)',
        active: _appsflyer != null,
        fn: () async => _appsflyer!.logEvent('rw_screen', {'screen': name}),
      ),
    ]);
  }

  /// Кастомные in-app: все три системы (разные отчёты и сильные стороны).
  Future<void> logCustomEvent(String name, [Map<String, Object?>? params]) async {
    final event = _sanitizeName(name);
    final merged = <String, Object?>{...(params ?? const {})};

    await Future.wait([
      _safe(
        'firebase_analytics',
        'logEvent($event)',
        active: _analytics != null,
        fn: () async {
          final fa = _firebaseAnalyticsParams(merged);
          await _analytics!.logEvent(name: event, parameters: fa.isEmpty ? null : fa);
        },
      ),
      _safe(
        'appsflyer',
        'logEvent($event)',
        active: _appsflyer != null,
        fn: () async {
          final af = _appsFlyerParams(merged);
          await _appsflyer!.logEvent(event, af);
        },
      ),
      _safe(
        'appmetrica',
        'reportEvent($event)',
        active: _appMetricaActive,
        fn: () async {
          final am = _appMetricaParams(merged);
          if (am.isEmpty) {
            await AppMetrica.reportEvent(event);
          } else {
            await AppMetrica.reportEventWithMap(event, am);
          }
        },
      ),
    ]);
  }

  Future<void> setUserId(String? userId) async {
    await Future.wait([
      _safe(
        'firebase_analytics',
        'setUserId',
        active: _analytics != null,
        fn: () async => _analytics!.setUserId(id: userId),
      ),
      _safe(
        'appsflyer',
        'setCustomerUserId',
        active: _appsflyer != null && userId != null && userId.isNotEmpty,
        fn: () async => _appsflyer!.setCustomerUserId(userId!),
      ),
      _safe(
        'appmetrica',
        'setUserProfileID',
        active: _appMetricaActive,
        fn: () async => AppMetrica.setUserProfileID(userId),
      ),
    ]);
    await _safe(
      'crashlytics',
      'setUserIdentifier',
      active: _crashlytics != null && userId != null && userId.isNotEmpty,
      fn: () async => _crashlytics!.setUserIdentifier(userId!),
    );
  }

  /// Нефатальные ошибки — только Crashlytics (группировка стека, алерты).
  Future<void> recordNonFatal(Object exception, StackTrace stack, {String? reason}) async {
    await _safe(
      'crashlytics',
      'recordNonFatal',
      active: _crashlytics != null,
      fn: () async => _crashlytics!.recordError(exception, stack, reason: reason, fatal: false),
    );
    _talker?.handle(exception, stack, 'Telemetry.recordNonFatal');
  }

  // ─── Product events ────────────────────────────────────────────────────────

  /// Генерация плана успешно завершена.
  Future<void> logPlanGenerated({required int days, required String goal, required String aiProvider}) =>
      logCustomEvent('rw_plan_generated', {'days': days, 'goal': goal, 'ai_provider': aiProvider});

  /// Генерация плана завершилась ошибкой.
  Future<void> logPlanGenerationFailed({required String aiProvider, String? reason}) =>
      logCustomEvent('rw_plan_generation_failed', {'ai_provider': aiProvider, 'reason': reason});

  /// Сохранены данные тела (поле + значение).
  Future<void> logBodySaved({required String field}) => logCustomEvent('rw_body_saved', {'field': field});

  /// Сохранение данных тела завершилось ошибкой.
  Future<void> logBodySaveFailed({required String field}) => logCustomEvent('rw_body_save_failed', {'field': field});

  /// Пользователь сменил AI-провайдер.
  Future<void> logAiProviderChanged(String provider) =>
      logCustomEvent('rw_ai_provider_changed', {'provider': provider});

  /// Пользователь сохранил API-ключ AI.
  Future<void> logAiSettingsSaved(String provider) => logCustomEvent('rw_ai_settings_saved', {'provider': provider});

  /// Пользователь активировал сохранённый план.
  Future<void> logPlanActivated() => logCustomEvent('rw_plan_activated');

  /// Пользователь удалил план.
  Future<void> logPlanDeleted() => logCustomEvent('rw_plan_deleted');

  // ─── Subscription events ───────────────────────────────────────────────────

  /// Продукты paywall загружены и доступны (placements ready).
  Future<void> logSubProductsLoaded({required int count}) =>
      logCustomEvent('rw_sub_products_loaded', {'count': count});

  /// Пользователь нажал «Купить».
  Future<void> logSubPurchaseStarted({
    required String productId,
    required String planType,
  }) =>
      logCustomEvent('rw_sub_purchase_started', {
        'product_id': productId,
        'plan_type': planType,
      });

  /// Покупка прошла успешно.
  Future<void> logSubPurchaseSuccess({
    required String productId,
    required String planType,
    String? price,
    String? currency,
  }) =>
      logCustomEvent('rw_sub_purchase_success', {
        'product_id': productId,
        'plan_type': planType,
        'price': price,
        'currency': currency,
      });

  /// Покупка завершилась ошибкой (в т.ч. отмена пользователем).
  Future<void> logSubPurchaseFailed({
    required String productId,
    String? errorMessage,
  }) =>
      logCustomEvent('rw_sub_purchase_failed', {
        'product_id': productId,
        if (errorMessage != null && errorMessage.isNotEmpty) 'error': errorMessage,
      });

  /// Пользователь нажал «Восстановить покупки».
  Future<void> logSubRestoreStarted() => logCustomEvent('rw_sub_restore_started');

  /// Восстановление прошло успешно, есть активные подписки.
  Future<void> logSubRestoreSuccess({required int restoredCount}) =>
      logCustomEvent('rw_sub_restore_success', {'count': restoredCount});

  /// После restore активных покупок не найдено.
  Future<void> logSubRestoreNothing() => logCustomEvent('rw_sub_restore_nothing');

  /// Восстановление отменено или прервано ошибкой StoreKit / Billing.
  Future<void> logSubRestoreCancelled({String? errorMessage}) =>
      logCustomEvent('rw_sub_restore_cancelled', {
        if (errorMessage != null && errorMessage.isNotEmpty) 'error': errorMessage,
      });

  /// [active]: false — sink отключён, вызов и лог успеха пропускаются.
  Future<void> _safe(String sink, String action, {required bool active, required Future<void> Function() fn}) async {
    if (!active) {
      _talker?.warning('Telemetry not active · $sink · $action');
      return;
    }

    try {
      await fn();
      _talker?.info('Telemetry OK · $sink · $action');
    } catch (e, st) {
      _talker?.error('Telemetry fail · $sink · $action', e, st);
    }
  }
}

String _sanitizeName(String raw) {
  var s = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  if (s.isEmpty) return 'event';
  if (!RegExp(r'^[a-z]').hasMatch(s)) {
    s = 'e_$s';
  }
  if (s.length > 40) {
    s = s.substring(0, 40);
  }
  return s;
}

String _truncate(String s, int max) {
  if (s.length <= max) return s;
  return s.substring(0, max);
}

Map<String, Object> _firebaseAnalyticsParams(Map<String, Object?> raw) {
  final out = <String, Object>{};
  var i = 0;
  for (final e in raw.entries) {
    if (i >= 25) break;
    final key = _sanitizeName(e.key);
    final v = e.value;
    if (v == null) continue;
    if (v is String || v is num || v is bool) {
      out[key] = v is String ? _truncate(v, 100) : v;
    } else {
      out[key] = _truncate(jsonEncode(v), 100);
    }
    i++;
  }
  return out;
}

Map<String, dynamic> _appsFlyerParams(Map<String, Object?> raw) {
  final out = <String, dynamic>{};
  for (final e in raw.entries) {
    out[e.key] = e.value?.toString() ?? '';
  }
  return out;
}

Map<String, Object> _appMetricaParams(Map<String, Object?> raw) {
  final out = <String, Object>{};
  for (final e in raw.entries) {
    final v = e.value;
    if (v == null) continue;
    if (v is String || v is num || v is bool) {
      out[e.key] = v;
    } else {
      out[e.key] = jsonEncode(v);
    }
  }
  return out;
}
