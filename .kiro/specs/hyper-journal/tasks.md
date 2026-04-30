# Implementation Plan: Hypertonic Journal — Tests & Improvements

## Overview

The app is already fully implemented. This plan covers writing unit tests and property-based tests for all 13 correctness properties defined in the design, plus extracting testable logic into standalone functions where needed to make it testable without a widget context.

All tests are written in Dart using `flutter_test`. Property-based tests use `dart:math` `Random` with 100 iterations per property, following the pattern described in the design.

## Tasks

- [x] 1. Set up test infrastructure and extract pure functions for testability
  - Add `shared_preferences: ^2.3.5` mock support via `SharedPreferences.setMockInitialValues({})` in test setup
  - Add `sqflite_common_ffi` in-memory database initialisation helper for unit tests
  - Extract `determinePeriod(int hour) → String` as a top-level or static function in `lib/main.dart` (or a new `lib/utils/period_utils.dart`) so it can be tested without a widget
  - Extract `validateRequired(String? v, int min, int max, String label) → String?` and `validateSugar(String? v) → String?` as pure functions (no `BuildContext`) into `lib/utils/validators.dart`; update `_AddDataTabState` to delegate to them
  - Extract `classifySugarWarning(double sugar) → String?` returning `'seeDoctor'`, `'lessCarbs'`, or `null` into `lib/utils/validators.dart`; update `_AddDataTabState` to use it
  - Extract `resolveLocale(Locale? deviceLocale) → Locale` as a top-level function in `lib/main.dart` (rename `_resolveLocale` to public); update `HealthDiaryApp` to call it
  - Extract notification time calculation `List<({int hour, int minute, int id})> buildNotificationTimes(TimeOfDay start, int baseId)` into `lib/utils/notification_utils.dart`; update `NotificationService` to use it
  - Extract PDF row formatting `List<String> formatRecordRow(HealthRecord r)` as a pure function in `lib/services/report_service.dart`; update `generateAndShowReport` to use it
  - _Requirements: 1.3, 1.4, 1.7, 1.8, 1.9, 1.10, 1.14, 1.17, 1.18, 4.2, 5.4, 5.5, 7.2, 7.3, 7.4, 7.5_

- [x] 2. Write tests for period determination and locale resolution
  - [x] 2.1 Write unit tests for `determinePeriod` boundary values
    - Test hour = 5 → `'morning'`
    - Test hour = 11 → `'morning'`
    - Test hour = 12 → `'evening'`
    - Test hour = 4 → `'evening'`
    - Test hour = 0 → `'evening'`
    - Test hour = 23 → `'evening'`
    - Create `test/utils/period_utils_test.dart`
    - _Requirements: 1.3, 1.4_

  - [x] 2.2 Write property test for period determination (Property 1)
    - **Property 1: Period determination by hour**
    - **Validates: Requirements 1.3, 1.4**
    - For 100 random `hour ∈ [0, 23]`: assert `determinePeriod(hour) == 'morning'` iff `hour >= 5 && hour < 12`, else `'evening'`
    - Tag: `// Feature: hyper-journal, Property 1: Period determination by hour`

  - [x] 2.3 Write unit tests for `resolveLocale`
    - Test `Locale('uk')` → `Locale('uk')`
    - Test `Locale('ru')` → `Locale('uk')`
    - Test `Locale('en')` → `Locale('en')`
    - Test `Locale('de')` → `Locale('en')`
    - Test `null` → `Locale('uk')`
    - Create `test/utils/locale_utils_test.dart`
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

  - [x] 2.4 Write property test for locale resolution (Property 13)
    - **Property 13: Locale resolution**
    - **Validates: Requirements 7.2, 7.3, 7.4, 7.5**
    - For 100 random language codes from a representative set: assert `resolveLocale(Locale(code)).languageCode` is `'uk'` for `{'uk', 'ru'}` and `'en'` for all others; assert `resolveLocale(null) == Locale('uk')`
    - Tag: `// Feature: hyper-journal, Property 13: Locale resolution`

- [x] 3. Checkpoint — Ensure period and locale tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Write tests for input validation
  - [x] 4.1 Write unit tests for `validateRequired` (integer fields)
    - Test each boundary: SYS 70, 250; DIA 40, 150; Pulse 30, 200 → `null`
    - Test SYS 69, 251; DIA 39, 151; Pulse 29, 201 → non-null error
    - Test empty string → non-null error
    - Test non-numeric string `'abc'` → non-null error
    - Create `test/utils/validators_test.dart`
    - _Requirements: 1.7, 1.8, 1.9, 1.11, 1.12, 1.13_

  - [x] 4.2 Write property test for integer field validation (Property 2)
    - **Property 2: Integer field validation**
    - **Validates: Requirements 1.7, 1.8, 1.9, 1.11, 1.12, 1.13**
    - For 100 random `(value, min, max)` triples: assert `validateRequired(value.toString(), min, max, 'X') == null` iff `value >= min && value <= max`; also test random non-numeric strings always return non-null
    - Tag: `// Feature: hyper-journal, Property 2: Integer field validation`

  - [x] 4.3 Write unit tests for `validateSugar`
    - Test `'1.0'` → `null`
    - Test `'30.0'` → `null`
    - Test `'7,5'` (comma) → `null`
    - Test `'0.9'` → non-null error
    - Test `'30.1'` → non-null error
    - Test `''` → non-null error
    - Test `'abc'` → non-null error
    - _Requirements: 1.10, 1.14_

  - [x] 4.4 Write property test for sugar validation (Property 3)
    - **Property 3: Sugar field validation with comma support**
    - **Validates: Requirements 1.10, 1.14**
    - For 100 random `v ∈ [1.0, 30.0]`: assert `validateSugar(v.toString()) == null` and `validateSugar(v.toString().replaceAll('.', ',')) == null`; for 100 random `v` outside range: assert non-null
    - Tag: `// Feature: hyper-journal, Property 3: Sugar validation with comma support`

  - [x] 4.5 Write unit tests for `classifySugarWarning`
    - Test `10.1` → `'seeDoctor'`
    - Test `7.1` → `'lessCarbs'`
    - Test `10.0` → `'lessCarbs'`
    - Test `7.0` → `null`
    - Test `1.0` → `null`
    - _Requirements: 1.17, 1.18_

  - [x] 4.6 Write property test for sugar warning classification (Property 4)
    - **Property 4: Sugar warning classification**
    - **Validates: Requirements 1.17, 1.18**
    - For 100 random `sugar > 10.0`: assert `'seeDoctor'`; for 100 random `7.0 < sugar ≤ 10.0`: assert `'lessCarbs'`; for 100 random `sugar ≤ 7.0`: assert `null`
    - Tag: `// Feature: hyper-journal, Property 4: Sugar warning classification`

- [x] 5. Checkpoint — Ensure validation tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Write tests for DatabaseHelper
  - [x] 6.1 Write unit tests for `DatabaseHelper` CRUD operations
    - Set up in-memory SQLite via `sqflite_common_ffi` in `setUp`
    - Test `insertRecord` returns a positive integer id
    - Test `getRecords` returns empty list on fresh database
    - Test `deleteAllRecords` leaves database empty
    - Create `test/services/database_helper_test.dart`
    - _Requirements: 8.1, 8.2, 8.6_

  - [x] 6.2 Write property test for HealthRecord round-trip (Property 5)
    - **Property 5: Round-trip save and read of HealthRecord**
    - **Validates: Requirements 1.15, 8.1, 8.2**
    - For 100 randomly generated valid `HealthRecord` values: insert, then `getRecords()`, assert the returned list contains a record with identical `systolic`, `diastolic`, `pulse`, `sugar`, `period`, and `timestamp` (to second precision)
    - Tag: `// Feature: hyper-journal, Property 5: HealthRecord round-trip save/read`

  - [x] 6.3 Write property test for reverse-chronological sort (Property 6)
    - **Property 6: Records sorted in reverse chronological order**
    - **Validates: Requirements 2.1, 8.6**
    - For 100 randomly ordered sets of records inserted in arbitrary order: assert that `getRecords()` returns them with `records[i].timestamp >= records[i+1].timestamp` for every adjacent pair
    - Tag: `// Feature: hyper-journal, Property 6: Records sorted DESC`

  - [x] 6.4 Write property test for record deletion round-trip (Property 7)
    - **Property 7: Record deletion round-trip**
    - **Validates: Requirements 2.5**
    - For 100 random records: insert, capture returned id, call `deleteRecord(id)`, assert `getRecords()` contains no record with that id
    - Tag: `// Feature: hyper-journal, Property 7: Record deletion round-trip`

- [x] 7. Checkpoint — Ensure database tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Write tests for notification time calculation
  - [x] 8.1 Write unit tests for `buildNotificationTimes`
    - Test `TimeOfDay(8, 0)` → times `[08:00, 08:10, 08:20, 08:30, 08:40, 08:50]` with IDs `[0..5]`
    - Test `TimeOfDay(20, 0)` → times `[20:00, 20:10, 20:20, 20:30, 20:40, 20:50]` with IDs `[10..15]`
    - Test midnight wrap: `TimeOfDay(23, 55)` → `[23:55, 00:05, 00:15, 00:25, 00:35, 00:45]`
    - Create `test/utils/notification_utils_test.dart`
    - _Requirements: 4.2_

  - [x] 8.2 Write property test for 6-notification scheduling (Property 8)
    - **Property 8: 6 notifications scheduled at 10-minute intervals**
    - **Validates: Requirements 4.2**
    - For 100 random `TimeOfDay(hour, minute)`: assert `buildNotificationTimes` returns exactly 6 entries where `times[i] == startTime + i * 10 minutes (mod 24h)` and IDs match the expected base offset
    - Tag: `// Feature: hyper-journal, Property 8: 6 notifications at 10-minute intervals`

- [x] 9. Write tests for SettingsService
  - [x] 9.1 Write unit tests for `SettingsService` defaults and persistence
    - Use `SharedPreferences.setMockInitialValues({})` in `setUp`
    - Test `getNotificationsEnabled()` default → `true`
    - Test `getMorningTime()` default → `TimeOfDay(8, 0)`
    - Test `getEveningTime()` default → `TimeOfDay(20, 0)`
    - Create `test/services/settings_service_test.dart`
    - _Requirements: 4.7, 4.8, 4.9_

  - [x] 9.2 Write property test for SettingsService round-trip (Property 10)
    - **Property 10: SettingsService round-trip save/read**
    - **Validates: Requirements 4.7, 4.8, 4.9**
    - For 100 random `TimeOfDay(hour ∈ [0,23], minute ∈ [0,59])`: call `setMorningTime(t)`, assert `getMorningTime() == t`; repeat for `setEveningTime`; for 100 random booleans: call `setNotificationsEnabled(b)`, assert `getNotificationsEnabled() == b`
    - Tag: `// Feature: hyper-journal, Property 10: SettingsService round-trip`

- [x] 10. Write tests for notification skip logic (Property 9)
  - [x] 10.1 Write unit tests for today's-record skip logic
    - Extract `shouldSkipPeriod(List<HealthRecord> records, String period, DateTime today) → bool` from `NotificationService.scheduleDailyReminders` into `lib/utils/notification_utils.dart`; update `NotificationService` to use it
    - Test: list with morning record for today → `shouldSkipPeriod(..., 'morning', today) == true`
    - Test: list with evening record for today → `shouldSkipPeriod(..., 'evening', today) == true`
    - Test: list with morning record for yesterday → `shouldSkipPeriod(..., 'morning', today) == false`
    - Test: empty list → both periods return `false`
    - Create tests in `test/utils/notification_utils_test.dart`
    - _Requirements: 4.3, 4.4_

  - [x] 10.2 Write property test for notification skip logic (Property 9)
    - **Property 9: Skip notifications when today's record exists**
    - **Validates: Requirements 4.3, 4.4**
    - For 100 random record sets that include at least one morning record for today: assert `shouldSkipPeriod(..., 'morning', today) == true`; for 100 random record sets with no morning record for today: assert `false`; repeat for evening
    - Tag: `// Feature: hyper-journal, Property 9: Skip notifications when today's record exists`

- [x] 11. Checkpoint — Ensure notification and settings tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 12. Write tests for ReportService formatting
  - [x] 12.1 Write unit tests for `formatRecordRow`
    - Test date formatted as `dd.MM.yyyy`
    - Test time formatted as `HH:mm`
    - Test pressure formatted as `'SYS/DIA'` (e.g. `'120/80'`)
    - Test `sugar == null` → `'-'` in sugar column
    - Test `sugar == 5.5` → `'5.5'` in sugar column
    - Create `test/services/report_service_test.dart`
    - _Requirements: 5.4, 5.5_

  - [x] 12.2 Write property test for PDF report field formatting (Property 12)
    - **Property 12: PDF report field formatting**
    - **Validates: Requirements 5.4, 5.5**
    - For 100 random `HealthRecord` values: assert `formatRecordRow(r)[0]` matches `dd.MM.yyyy`, `[1]` matches `HH:mm`, `[3]` matches `SYS/DIA`, and `[5] == '-'` when `sugar == null`
    - Tag: `// Feature: hyper-journal, Property 12: PDF report field formatting`

  - [x] 12.3 Write unit tests for report record filtering and sorting
    - Test that records older than 30 days are excluded
    - Test that records within 30 days are included
    - Test that the resulting list is sorted DESC by timestamp
    - _Requirements: 5.1, 5.2_

  - [x] 12.4 Write property test for PDF report sort order (Property 11)
    - **Property 11: PDF report sorted DESC**
    - **Validates: Requirements 5.2**
    - Extract `filterAndSortForReport(List<HealthRecord> records, DateTime now) → List<HealthRecord>` as a pure function; for 100 random record sets: assert every adjacent pair satisfies `records[i].timestamp >= records[i+1].timestamp`
    - Tag: `// Feature: hyper-journal, Property 11: PDF report sorted DESC`

- [x] 13. Final checkpoint — Ensure all tests pass
  - Run `flutter test` and ensure all tests pass.
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests use 100 iterations each with `dart:math` `Random` — no additional PBT library required
- The extraction tasks in Task 1 are prerequisites for all test tasks; they involve small, safe refactors that preserve existing behaviour
- `sqflite_common_ffi` is already a project dependency and can be used in tests with an in-memory database path
- `SharedPreferences.setMockInitialValues({})` is available from the `shared_preferences` package test utilities
- Property tests are tagged with `// Feature: hyper-journal, Property N: <description>` as specified in the design
