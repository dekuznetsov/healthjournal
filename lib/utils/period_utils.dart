/// Returns 'morning' if [hour] is in [5, 11], 'evening' otherwise.
/// [hour] must be in the range [0, 23].
String determinePeriod(int hour) {
  return (hour >= 5 && hour < 12) ? 'morning' : 'evening';
}
