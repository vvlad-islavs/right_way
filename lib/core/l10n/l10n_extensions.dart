import 'package:flutter/widgets.dart';
import 'package:right_way/l10n/generated/app_localizations.dart';

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
