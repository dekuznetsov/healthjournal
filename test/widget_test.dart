// Basic smoke test for HealthDiaryApp.
// The full functional tests live in test/utils/ and test/services/.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('smoke – test infrastructure initialises without error', () {
    // Verifies that sqflite_common_ffi initialises correctly in the test
    // environment. The widget-level tests for the app are intentionally
    // omitted here because the app requires platform channels (notifications,
    // shared_preferences) that are not available in the headless test runner.
    expect(databaseFactory, isNotNull);
  });
}
