// Pure validation functions — no BuildContext required.
// Return null on success, a non-null error string on failure.

/// Validates that [v] is an integer in the range [[min], [max]].
/// [label] is used in the range-error message.
String? validateRequired(String? v, int min, int max, String label) {
  if (v == null || v.isEmpty) return 'Required';
  final val = int.tryParse(v);
  if (val == null) return 'Numbers only';
  if (val < min || val > max) return '$label: $min–$max';
  return null;
}

/// Validates that [v] is a decimal number in the range [1.0, 30.0].
/// Accepts both '.' and ',' as decimal separators.
String? validateSugar(String? v) {
  if (v == null || v.isEmpty) return 'Required';
  final val = double.tryParse(v.replaceFirst(',', '.'));
  if (val == null) return 'Invalid format';
  if (val < 1.0 || val > 30.0) return 'Sugar: 1.0–30.0';
  return null;
}

/// Classifies a sugar value for warning display.
/// Returns 'seeDoctor' if [sugar] > 10.0,
///         'lessCarbs' if 7.0 < [sugar] <= 10.0,
///         null if [sugar] <= 7.0.
String? classifySugarWarning(double sugar) {
  if (sugar > 10.0) return 'seeDoctor';
  if (sugar > 7.0) return 'lessCarbs';
  return null;
}
