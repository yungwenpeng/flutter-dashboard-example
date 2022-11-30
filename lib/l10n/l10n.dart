import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('zh'),
  ];
  static String getName(String code) {
    switch (code) {
      case 'zh':
        return '繁體中文';
      case 'en':
      default:
        return 'English';
    }
  }

  static String getCountryFlag(String code) {
    // See https://en.wikipedia.org/wiki/Regional_indicator_symbol
    switch (code) {
      case 'zh':
        return 'TW';
      case 'en':
      default:
        return 'US';
    }
  }
}
