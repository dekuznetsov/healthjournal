import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_journal/utils/period_utils.dart';

void main() {
  // ── Unit tests for determinePeriod ──────────────────────────────────────────

  group('determinePeriod – boundary values', () {
    test('hour = 5 → morning', () {
      expect(determinePeriod(5), 'morning');
    });

    test('hour = 11 → morning', () {
      expect(determinePeriod(11), 'morning');
    });

    test('hour = 12 → evening', () {
      expect(determinePeriod(12), 'evening');
    });

    test('hour = 4 → evening', () {
      expect(determinePeriod(4), 'evening');
    });

    test('hour = 0 → evening', () {
      expect(determinePeriod(0), 'evening');
    });

    test('hour = 23 → evening', () {
      expect(determinePeriod(23), 'evening');
    });
  });

  // ── Property test ────────────────────────────────────────────────────────────
  // Feature: hyper-journal, Property 1: Period determination by hour

  test('Property 1: determinePeriod returns morning iff hour ∈ [5, 11]', () {
    // Validates: Requirements 1.3, 1.4
    final random = Random(42);
    for (var i = 0; i < 100; i++) {
      final hour = random.nextInt(24); // [0, 23]
      final result = determinePeriod(hour);
      if (hour >= 5 && hour < 12) {
        expect(result, 'morning',
            reason: 'hour $hour should map to morning');
      } else {
        expect(result, 'evening',
            reason: 'hour $hour should map to evening');
      }
    }
  });
}
