import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:right_way/core/config/app_env.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Значение `AdRequest.DEVICE_ID_EMULATOR` (Google Mobile Ads на Android) для эмулятора.
/// См. https://developer.android.com/reference/com/google/android/gms/ads/AdRequest#DEVICE_ID_EMULATOR
const String _androidGmaEmulatorTestDeviceId = '33BE2250B43518CCDA7ED426A9048872';

/// Ранняя инициализация Google Mobile Ads после загрузки `.env`.
///
/// На Android/iOS в манифесте / Info.plist должен быть тот же [Env.admobAppId],
/// что и в `.env` (см. [официальный quick start](https://developers.google.com/admob/flutter/quick-start)).
///
/// **Тестовые устройства (эмулятор / симулятор):** после [MobileAds.instance.initialize]
/// выставляется [RequestConfiguration], если сработало автоопределение или флаги в `.env`
/// ([Env.admobIosSimulatorTestDevice], [Env.admobAndroidEmulatorTestDevice]).
/// На **физических** устройствах не включать эти флаги — возможен ухудшенный fill.
bool get _isIosSimulatorHost {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    final e = Platform.environment;
    return e['SIMULATOR_DEVICE_NAME'] != null || e['SIMULATOR_UDID'] != null;
  } catch (_) {
    return false;
  }
}

bool get _isAndroidEmulatorHost {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    final e = Platform.environment;
    return e['ANDROID_EMU'] == '1' || e['ANDROID_AVD_HOME'] != null;
  } catch (_) {
    return false;
  }
}

Future<void> _applyTestDeviceConfiguration(Talker talker) async {
  final ids = <String>[];
  final reasons = <String>[];

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      final use = _isIosSimulatorHost || Env.admobIosSimulatorTestDevice;
      if (use) {
        ids.add('GADSimulatorID');
        reasons.add(Env.admobIosSimulatorTestDevice && !_isIosSimulatorHost ? 'iOS (.env)' : 'iOS Simulator');
      }
    case TargetPlatform.android:
      final useEmulator = _isAndroidEmulatorHost || Env.admobAndroidEmulatorTestDevice;
      if (useEmulator) {
        ids.add(_androidGmaEmulatorTestDeviceId);
        reasons.add(
          Env.admobAndroidEmulatorTestDevice && !_isAndroidEmulatorHost ? 'Android (.env)' : 'Android emulator',
        );
      }
    default:
      break;
  }

  // Дополнительные реальные тестовые устройства разработчиков из .env.
  final extra = Env.admobTestDeviceIds;
  if (extra.isNotEmpty) {
    ids.addAll(extra);
    reasons.add('ADMOB_TEST_DEVICE_IDS (.env)');
  }

  if (ids.isEmpty) return;

  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ids));
  talker.info('AdMob: testDeviceIds [${ids.join(", ")}] (${reasons.join(", ")}).');
}

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
      // Тестовые устройства нужно зарегистрировать ДО initialize() —
      // иначе первые запросы уходят без флага тестового режима.
      await _applyTestDeviceConfiguration(talker);
      final status = await MobileAds.instance.initialize();
      // Открывает дебаг параметры рекламы
      // await MobileAds.instance.openDebugMenu(AdMobUnitIds.banner);
      _initialized = true;
      final adapters = status.adapterStatuses.entries.map((e) => '${e.key}:${e.value.state.name}').join(', ');
      talker.info('AdMob initialized ($adapters).');
    } catch (e, st) {
      talker.error('AdMob init failed.', e, st);
    }
  }
}
