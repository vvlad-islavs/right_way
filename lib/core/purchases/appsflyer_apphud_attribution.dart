import 'dart:async';

import 'package:apphud/apphud.dart';
import 'package:apphud/models/apphud_models/apphud_attribution_data.dart';
import 'package:apphud/models/apphud_models/apphud_attribution_provider.dart';
import 'package:right_way/core/di/core_di.dart';
import 'package:right_way/core/purchases/apphud_subscription_service.dart';
import 'package:right_way/core/telemetry/app_telemetry.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Колбэки AppsFlyer → [Apphud.setAttribution]. Если AppHud ещё не стартовал, данные буферизуются до [flushPending].
abstract final class AppsFlyerApphudAttribution {
  static Map<String, dynamic>? _pendingInstallConversion;
  static Map<String, dynamic>? _pendingAppOpen;

  /// [onInstallConversionData] из AppsFlyer SDK.
  static void onInstallConversionData(Talker talker, dynamic data) {
    final map = _normalizePayload(data);
    if (!di.isRegistered<ApphudSubscriptionService>()) {
      _pendingInstallConversion = map;
      talker.info('Apphud: данные install conversion сохранены до старта SDK');
      return;
    }
    unawaited(_sendToApphud(talker, map, context: 'install_conversion'));
  }

  /// [onAppOpenAttribution] из AppsFlyer SDK.
  static void onAppOpenAttribution(Talker talker, dynamic data) {
    final map = _normalizePayload(data);
    if (!di.isRegistered<ApphudSubscriptionService>()) {
      _pendingAppOpen = map;
      talker.info('Apphud: данные app open attribution сохранены до старта SDK');
      return;
    }
    unawaited(_sendToApphud(talker, map, context: 'app_open'));
  }

  /// Вызвать после [Apphud.start], чтобы отправить данные, пришедшие до инициализации AppHud.
  static Future<void> flushPending(Talker talker) async {
    if (!di.isRegistered<ApphudSubscriptionService>()) return;
    final install = _pendingInstallConversion;
    if (install != null) {
      _pendingInstallConversion = null;
      await _sendToApphud(talker, install, context: 'install_conversion_flush');
    }
    final open = _pendingAppOpen;
    if (open != null) {
      _pendingAppOpen = null;
      await _sendToApphud(talker, open, context: 'app_open_flush');
    }
  }

  static Map<String, dynamic> _normalizePayload(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      final top = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
      // appsflyer_sdk оборачивает колбэки в { status, payload }; см. AppsFlyer
      // + Apphud https://docs.apphud.com/docs/appsflyer
      final wrapped = top['payload'];
      if (wrapped is Map) {
        final status = top['status']?.toString().toLowerCase();
        final payload = Map<String, dynamic>.from(
          wrapped.map((k, v) => MapEntry(k.toString(), _jsonify(v))),
        );
        if (status == 'success') {
          return payload;
        }
        final err = payload['data'] ?? payload['af_message'] ?? top['status'] ?? 'conversion_failed';
        return {'error': err is String ? err : err.toString()};
      }
      return top.map((k, v) => MapEntry(k, _jsonify(v)));
    }
    return {'raw': data.toString()};
  }

  static dynamic _jsonify(dynamic v) {
    if (v == null || v is num || v is bool || v is String) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), _jsonify(val)));
    }
    if (v is List) {
      return v.map(_jsonify).toList();
    }
    return v.toString();
  }

  static Future<void> _sendToApphud(
    Talker talker,
    Map<String, dynamic> rawData, {
    required String context,
  }) async {
    final af = di.isRegistered<AppTelemetry>() ? di<AppTelemetry>().appsflyerSdk : null;
    String? uid;
    try {
      uid = await af?.getAppsFlyerUID();
    } catch (e, st) {
      talker.handle(e, st, 'Apphud: AppsFlyer UID ($context)');
    }
    final merged = Map<String, dynamic>.from(rawData);
    if (uid != null && uid.isNotEmpty) {
      merged.putIfAbsent('appsflyer_id', () => uid!);
    }
    try {
      final ok = await Apphud.setAttribution(
        provider: ApphudAttributionProvider.appsFlyer,
        data: ApphudAttributionData(rawData: merged),
        identifier: uid,
      );
      talker.info('Apphud: атрибуция AppsFlyer ($context) ${ok ? 'принята' : 'отклонена'}');
    } catch (e, st) {
      talker.error('Apphud: атрибуция AppsFlyer ($context)', e, st);
    }
  }
}
