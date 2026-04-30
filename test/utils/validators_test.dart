import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_journal/utils/validators.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.1 — Unit tests for validateRequired
  // ─────────────────────────────────────────────────────────────────────────
  group('validateRequired — unit tests', () {
    // SYS boundaries
    test('SYS lower boundary 70 → null', () {
      expect(validateRequired('70', 70, 250, 'SYS'), isNull);
    });
    test('SYS upper boundary 250 → null', () {
      expect(validateRequired('250', 70, 250, 'SYS'), isNull);
    });

    // SYS out of range
    test('SYS below lower boundary 69 → non-null', () {
      expect(validateRequired('69', 70, 250, 'SYS'), isNotNull);
    });
    test('SYS above upper boundary 251 → non-null', () {
      expect(validateRequired('251', 70, 250, 'SYS'), isNotNull);
    });

    // DIA boundaries
    test('DIA lower boundary 40 → null', () {
      expect(validateRequired('40', 40, 150, 'DIA'), isNull);
    });
    test('DIA upper boundary 150 → null', () {
      expect(validateRequired('150', 40, 150, 'DIA'), isNull);
    });

    // DIA out of range
    test('DIA below lower boundary 39 → non-null', () {
      expect(validateRequired('39', 40, 150, 'DIA'), isNotNull);
    });
    test('DIA above upper boundary 151 → non-null', () {
      expect(validateRequired('151', 40, 150, 'DIA'), isNotNull);
    });

    // Pulse boundaries
    test('Pulse lower boundary 30 → null', () {
      expect(validateRequired('30', 30, 200, 'Pulse'), isNull);
    });
    test('Pulse upper boundary 200 → null', () {
      expect(validateRequired('200', 30, 200, 'Pulse'), isNull);
    });

    // Pulse out of range
    test('Pulse below lower boundary 29 → non-null', () {
      expect(validateRequired('29', 30, 200, 'Pulse'), isNotNull);
    });
    test('Pulse above upper boundary 201 → non-null', () {
      expect(validateRequired('201', 30, 200, 'Pulse'), isNotNull);
    });

    // Edge cases
    test('empty string → non-null', () {
      expect(validateRequired('', 70, 250, 'SYS'), isNotNull);
    });
    test('null → non-null', () {
      expect(validateRequired(null, 70, 250, 'SYS'), isNotNull);
    });
    test('non-numeric "abc" → non-null', () {
      expect(validateRequired('abc', 70, 250, 'SYS'), isNotNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.2 — Property test for integer field validation (Property 2)
  // Feature: hyper-journal, Property 2: Integer field validation
  // Validates: Requirements 1.7, 1.8, 1.9, 1.11, 1.12, 1.13
  // ─────────────────────────────────────────────────────────────────────────
  group('validateRequired — property tests', () {
    // Feature: hyper-journal, Property 2: Integer field validation
    test('Property 2: valid iff value in [min, max]', () {
      final rng = Random(42);
      for (var i = 0; i < 100; i++) {
        final min = rng.nextInt(100) + 1; // [1, 100]
        final max = min + rng.nextInt(200) + 1; // [min+1, min+200]
        // Pick a value anywhere in a wider range to get both in- and out-of-range
        final value = min - 50 + rng.nextInt(max - min + 101);
        final result = validateRequired(value.toString(), min, max, 'X');
        if (value >= min && value <= max) {
          expect(
            result,
            isNull,
            reason: 'value=$value min=$min max=$max should be valid',
          );
        } else {
          expect(
            result,
            isNotNull,
            reason: 'value=$value min=$min max=$max should be invalid',
          );
        }
      }
    });

    test('Property 2: non-numeric strings always return non-null', () {
      final rng = Random(43);
      const chars = 'abcdefghijklmnopqrstuvwxyz!@#\$%^&*()';
      for (var i = 0; i < 100; i++) {
        // Build a string that contains at least one non-digit character
        final len = rng.nextInt(5) + 1;
        final buf = StringBuffer();
        // Ensure at least one letter
        buf.write(chars[rng.nextInt(chars.length)]);
        for (var j = 1; j < len; j++) {
          buf.write(chars[rng.nextInt(chars.length)]);
        }
        final s = buf.toString();
        expect(
          validateRequired(s, 1, 100, 'X'),
          isNotNull,
          reason: '"$s" should be invalid',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.3 — Unit tests for validateSugar
  // ─────────────────────────────────────────────────────────────────────────
  group('validateSugar — unit tests', () {
    test('"1.0" → null (lower boundary)', () {
      expect(validateSugar('1.0'), isNull);
    });
    test('"30.0" → null (upper boundary)', () {
      expect(validateSugar('30.0'), isNull);
    });
    test('"7,5" (comma separator) → null', () {
      expect(validateSugar('7,5'), isNull);
    });
    test('"0.9" → non-null (below range)', () {
      expect(validateSugar('0.9'), isNotNull);
    });
    test('"30.1" → non-null (above range)', () {
      expect(validateSugar('30.1'), isNotNull);
    });
    test('"" → non-null (empty)', () {
      expect(validateSugar(''), isNotNull);
    });
    test('null → non-null', () {
      expect(validateSugar(null), isNotNull);
    });
    test('"abc" → non-null (non-numeric)', () {
      expect(validateSugar('abc'), isNotNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.4 — Property test for sugar validation (Property 3)
  // Feature: hyper-journal, Property 3: Sugar field validation with comma support
  // Validates: Requirements 1.10, 1.14
  // ─────────────────────────────────────────────────────────────────────────
  group('validateSugar — property tests', () {
    // Feature: hyper-journal, Property 3: Sugar field validation with comma support
    test('Property 3: values in [1.0, 30.0] are valid with dot and comma', () {
      final rng = Random(44);
      for (var i = 0; i < 100; i++) {
        // v ∈ [1.0, 30.0]
        final v = 1.0 + rng.nextDouble() * 29.0;
        final dotStr = v.toStringAsFixed(2);
        final commaStr = dotStr.replaceAll('.', ',');

        expect(
          validateSugar(dotStr),
          isNull,
          reason: '"$dotStr" should be valid',
        );
        expect(
          validateSugar(commaStr),
          isNull,
          reason: '"$commaStr" should be valid',
        );
      }
    });

    test('Property 3: values outside [1.0, 30.0] are invalid', () {
      final rng = Random(45);
      for (var i = 0; i < 100; i++) {
        // Alternate between below and above range
        final double v;
        if (i.isEven) {
          // v < 1.0: range [0.0, 0.99]
          v = rng.nextDouble() * 0.99;
        } else {
          // v > 30.0: range (30.0, 60.0]
          v = 30.0 + rng.nextDouble() * 30.0 + 0.01;
        }
        final s = v.toStringAsFixed(2);
        expect(
          validateSugar(s),
          isNotNull,
          reason: '"$s" (v=$v) should be invalid',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.5 — Unit tests for classifySugarWarning
  // ─────────────────────────────────────────────────────────────────────────
  group('classifySugarWarning — unit tests', () {
    test('10.1 → "seeDoctor"', () {
      expect(classifySugarWarning(10.1), equals('seeDoctor'));
    });
    test('7.1 → "lessCarbs"', () {
      expect(classifySugarWarning(7.1), equals('lessCarbs'));
    });
    test('10.0 → "lessCarbs" (boundary, not > 10.0)', () {
      expect(classifySugarWarning(10.0), equals('lessCarbs'));
    });
    test('7.0 → null (boundary, not > 7.0)', () {
      expect(classifySugarWarning(7.0), isNull);
    });
    test('1.0 → null', () {
      expect(classifySugarWarning(1.0), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Task 4.6 — Property test for sugar warning classification (Property 4)
  // Feature: hyper-journal, Property 4: Sugar warning classification
  // Validates: Requirements 1.17, 1.18
  // ─────────────────────────────────────────────────────────────────────────
  group('classifySugarWarning — property tests', () {
    // Feature: hyper-journal, Property 4: Sugar warning classification
    test('Property 4: sugar > 10.0 → "seeDoctor"', () {
      final rng = Random(46);
      for (var i = 0; i < 100; i++) {
        // sugar ∈ (10.0, 40.0]
        final sugar = 10.0 + rng.nextDouble() * 30.0 + 0.001;
        expect(
          classifySugarWarning(sugar),
          equals('seeDoctor'),
          reason: 'sugar=$sugar should be seeDoctor',
        );
      }
    });

    test('Property 4: 7.0 < sugar ≤ 10.0 → "lessCarbs"', () {
      final rng = Random(47);
      for (var i = 0; i < 100; i++) {
        // sugar ∈ (7.0, 10.0]
        final sugar = 7.0 + rng.nextDouble() * 3.0 + 0.001;
        // Clamp to ensure we don't exceed 10.0 due to floating-point
        final clamped = sugar > 10.0 ? 10.0 : sugar;
        expect(
          classifySugarWarning(clamped),
          equals('lessCarbs'),
          reason: 'sugar=$clamped should be lessCarbs',
        );
      }
    });

    test('Property 4: sugar ≤ 7.0 → null', () {
      final rng = Random(48);
      for (var i = 0; i < 100; i++) {
        // sugar ∈ [0.0, 7.0]
        final sugar = rng.nextDouble() * 7.0;
        expect(
          classifySugarWarning(sugar),
          isNull,
          reason: 'sugar=$sugar should be null',
        );
      }
    });
  });
}
