// Замените на вывод `dart run flutterfire_cli:flutterfire configure` для своего проекта Firebase.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Конфигурация Firebase по умолчанию для [Firebase.initializeApp].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase для Web не настроен.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase не настроен для платформы $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6iLrDKvAbW1GmiHVdcvd7bSt0cAa09EE',
    appId: '1:82266865490:android:4d3db1ba45d0c4ca12048b',
    messagingSenderId: '82266865490',
    projectId: 'mst-step-c',
    storageBucket: 'mst-step-c.firebasestorage.app',
  );

  /// Должно совпадать с `android/app/google-services.json` → client.package_name.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJLki6NGNgtD4U5nWppiGHJWmiU02YF4I',
    appId: '1:82266865490:ios:730529d4f5adac9412048b',
    messagingSenderId: '82266865490',
    projectId: 'mst-step-c',
    storageBucket: 'mst-step-c.firebasestorage.app',
    iosBundleId: 'com.example.rightWay',
  );

  /// Должно совпадать с `ios/Runner/GoogleService-Info.plist` (GOOGLE_APP_ID, BUNDLE_ID).
}