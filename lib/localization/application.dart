import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Application {
  static final Application _application = Application._internal();

  factory Application() => _application;

  Application._internal();

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() => AppLocalizations.supportedLocales;
  late LocaleChangeCallback onLocaleChanged;
}

Application application = Application();

typedef LocaleChangeCallback = void Function(Locale locale);
