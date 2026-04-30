import 'package:flutter/material.dart';
import '../models/health_record.dart';

/// Builds a list of 6 notification times starting at [start], each 10 minutes
/// apart, with IDs starting at [baseId].
///
/// Returns a list of records with `hour`, `minute`, and `id` fields.
List<({int hour, int minute, int id})> buildNotificationTimes(
  TimeOfDay start,
  int baseId,
) {
  return List.generate(6, (i) {
    final total = start.hour * 60 + start.minute + (i * 10);
    return (
      hour: (total ~/ 60) % 24,
      minute: total % 60,
      id: baseId + i,
    );
  });
}

/// Returns true if [records] contains at least one record with the given
/// [period] whose date matches [today] (year/month/day comparison).
bool shouldSkipPeriod(
  List<HealthRecord> records,
  String period,
  DateTime today,
) {
  return records.any((r) =>
      r.timestamp.year == today.year &&
      r.timestamp.month == today.month &&
      r.timestamp.day == today.day &&
      r.period == period);
}
