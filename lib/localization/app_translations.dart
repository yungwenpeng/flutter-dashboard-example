import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  Locale locale;
  static Map<dynamic, dynamic>? _localisedValues;

  AppTranslations(this.locale);

  static AppTranslations? of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations);
  }

  static Future<AppTranslations> load(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      locale = Locale(languageCode);
    }
    AppTranslations appTranslations = AppTranslations(locale);
    String jsonContent =
        await rootBundle.loadString("lib/l10n/app_${locale.languageCode}.arb");
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String text(String key) {
    return _localisedValues![key] ?? "$key not found";
  }
}
