# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-30

### Added

- Health data entry form with systolic/diastolic pressure, pulse, and optional blood sugar fields
- Automatic period detection (morning 05:00–11:59, evening 12:00–04:59) based on device time
- Input validation for all fields with range checks (SYS 70–250, DIA 40–150, Pulse 30–200, Sugar 1.0–30.0)
- Comma as decimal separator support for the Sugar field
- Real-time sugar warning display: "💡 Рекомендовано вживати менше вуглеводів" (>7.0) and "⚠️ Необхідно звернутись до лікаря!" (>10.0)
- Journal tab showing all records in reverse chronological order with period icons (☀️/🌙)
- Record deletion from the journal with immediate UI update
- Charts tab with stacked bar chart for pressure (DIA blue + SYS red) and bar chart for blood sugar
- Chart period filters: 7 days, 30 days, year, all data, and custom date range
- Drag-to-select gesture on charts to set a custom date range
- Local SQLite storage via sqflite (mobile) and sqflite_common_ffi (desktop/Windows/Linux)
- Daily reminder notifications scheduled at 6 intervals of 10 minutes starting from configured time
- Smart notification skip: no reminders scheduled when today's record already exists for that period
- Notification settings persisted via SharedPreferences (enabled/disabled, morning time 08:00, evening time 20:00)
- Boot-completed receiver to restore notifications after device restart (Android)
- PDF report generation for the last 30 days, sorted DESC, with NotoSans font for Cyrillic support
- Drawer with reminder settings, report generation, and developer tools (clear database, seed 1 year of data)
- Ukrainian (uk) and English (en) localisation; Russian locale mapped to Ukrainian
- Desktop window fixed at 414×896 px, centred, non-resizable (Windows/Linux)
- Extracted pure utility functions for testability: `determinePeriod`, `resolveLocale`, `validateRequired`, `validateSugar`, `classifySugarWarning`, `buildNotificationTimes`, `shouldSkipPeriod`, `formatRecordRow`, `filterAndSortForReport`
- Unit and property-based test suite covering all 13 correctness properties (93 tests, 100 iterations each)
