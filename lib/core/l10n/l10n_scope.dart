import 'package:get_it/get_it.dart';
import 'package:right_way/core/l10n/locale_controller.dart';
import 'package:right_way/l10n/generated/app_localizations.dart';

/// Локализация без [BuildContext] (ошибки, мапперы) — по текущему [LocaleController].
AppLocalizations appL10n() =>
    lookupAppLocalizations(GetIt.instance<LocaleController>().locale);
