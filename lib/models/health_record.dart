class HealthRecord {
  final int? id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final double? sugar;
  final DateTime timestamp;
  final String period; // 'morning' or 'evening'

  HealthRecord({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.sugar,
    required this.timestamp,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'sugar': sugar,
      'timestamp': timestamp.toIso8601String(),
      'period': period,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      sugar: map['sugar'],
      timestamp: DateTime.parse(map['timestamp']),
      period: map['period'],
    );
  }
}
