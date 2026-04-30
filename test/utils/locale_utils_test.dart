import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_journal/utils/locale_utils.dart';

void main() {
  // ── Unit tests for resolveLocale ─────────────────────────────────────────────

  group('resolveLocale – explicit locales', () {
    test('Locale(uk) → Locale(uk)', () {
      expect(resolveLocale(const Locale('uk')), const Locale('uk'));
    });

    test('Locale(ru) → Locale(uk)', () {
      expect(resolveLocale(const Locale('ru')), const Locale('uk'));
    });

    test('Locale(en) → Locale(en)', () {
      expect(resolveLocale(const Locale('en')), const Locale('en'));
    });

    test('Locale(de) → Locale(en)', () {
      expect(resolveLocale(const Locale('de')), const Locale('en'));
    });

    test('null → Locale(uk)', () {
      expect(resolveLocale(null), const Locale('uk'));
    });
  });

  // ── Property test ────────────────────────────────────────────────────────────
  // Feature: hyper-journal, Property 13: Locale resolution

  test('Property 13: resolveLocale maps uk/ru → uk, everything else → en', () {
    // Validates: Requirements 7.2, 7.3, 7.4, 7.5
    const codes = ['uk', 'ru', 'en', 'de', 'fr', 'es', 'zh', 'ja', 'ar', 'pt'];
    const ukCodes = {'uk', 'ru'};

    final random = Random(42);
    for (var i = 0; i < 100; i++) {
      final code = codes[random.nextInt(codes.length)];
      final result = resolveLocale(Locale(code));
      if (ukCodes.contains(code)) {
        expect(result.languageCode, 'uk',
            reason: 'code "$code" should resolve to uk');
      } else {
        expect(result.languageCode, 'en',
            reason: 'code "$code" should resolve to en');
      }
    }

    // null always resolves to uk
    expect(resolveLocale(null), const Locale('uk'));
  });
}
