import 'package:flutter/material.dart';

/// Resolves the app locale from the device locale.
///
/// - Returns `Locale('uk')` for Ukrainian and Russian device locales.
/// - Returns `Locale('uk')` when [deviceLocale] is null.
/// - Returns `Locale('en')` for all other locales.
Locale resolveLocale(Locale? deviceLocale) {
  if (deviceLocale == null) return const Locale('uk');
  if (deviceLocale.languageCode == 'ru') return const Locale('uk');
  if (deviceLocale.languageCode == 'uk') return const Locale('uk');
  return const Locale('en');
}
