import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:right_way/core/telemetry/app_telemetry.dart';

/// Логирует открытие экранов в [AppTelemetry] (Firebase / AppMetrica / AppsFlyer).
class TelemetryNavigatorObserver extends AutoRouterObserver {
  TelemetryNavigatorObserver(this._telemetry);

  final AppTelemetry _telemetry;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final screen = route.data?.name ?? route.settings.name ?? 'unknown';
    unawaited(_telemetry.logScreenView(screen));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final screen = previousRoute?.data?.name ?? previousRoute?.settings.name;
    if (screen != null) unawaited(_telemetry.logScreenView(screen));
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    unawaited(_telemetry.logScreenView(route.name));
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    unawaited(_telemetry.logScreenView(route.name));
  }
}
