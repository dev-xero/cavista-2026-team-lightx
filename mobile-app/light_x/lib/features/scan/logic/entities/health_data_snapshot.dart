/// health/health_snapshot.dart
/// Immutable health data snapshot emitted by WatchHealthService.
/// All fields are nullable — the UI must handle each being absent independently.

library;

class BloodPressure {
  final int systolic; // mmHg  (upper number, e.g. 120)
  final int diastolic; // mmHg  (lower number, e.g. 80)
  final int? meanArterial; // mmHg  (optional, not all watches provide it)

  const BloodPressure({required this.systolic, required this.diastolic, this.meanArterial});

  @override
  String toString() {
    final map = meanArterial != null ? ' / $meanArterial' : '';
    return '$systolic / $diastolic$map mmHg';
  }
}

class HealthSnapshot {
  final int? heartRate; // bpm
  final double? spo2; // % (0–100)
  final BloodPressure? bloodPressure;
  final int? battery; // % (0–100)

  const HealthSnapshot({this.heartRate, this.spo2, this.bloodPressure, this.battery});

  HealthSnapshot copyWith({int? heartRate, double? spo2, BloodPressure? bloodPressure, int? battery}) => HealthSnapshot(
    heartRate: heartRate ?? this.heartRate,
    spo2: spo2 ?? this.spo2,
    bloodPressure: bloodPressure ?? this.bloodPressure,
    battery: battery ?? this.battery,
  );

  bool get hasData => heartRate != null || spo2 != null || bloodPressure != null;

  @override
  String toString() => [
    if (heartRate != null) 'HR=$heartRate bpm',
    if (spo2 != null) 'SpO2=$spo2%',
    if (bloodPressure != null) 'BP=$bloodPressure',
    if (battery != null) 'Batt=$battery%',
  ].join(' | ');
}
