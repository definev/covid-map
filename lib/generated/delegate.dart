import 'package:flutter/material.dart';
import 'package:flutter_challenger/generated/locale_base.dart';

class LocDelegate extends LocalizationsDelegate<LocaleBase> {
  const LocDelegate();
  final idMap = const {'en': 'locales/EN.json', 'vi': 'locales/VI.json'};

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<LocaleBase> load(Locale locale) async {
    var lang = 'en';
    if (isSupported(locale)) lang = locale.languageCode;
    final loc = LocaleBase();
    await loc.load(idMap[lang]);
    return loc;
  }

  @override
  bool shouldReload(LocDelegate old) => false;
}
