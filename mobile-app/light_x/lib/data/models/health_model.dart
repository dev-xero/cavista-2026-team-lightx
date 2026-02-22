class HealthModel {
  final int age;
  final int gender;
  final int smokingStatus;
  final int bmi;
  final int avgSleepHours;
  final int stressLevel;
  final int diabetic;
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final int spo2;
  final int breathingRate;
  final int hrv;
  final int totalCholesterol;
  final int hdlCholesterol;
  final int fastingGlucose;
  final double creatinine;

  const HealthModel({
    required this.age,
    required this.gender,
    required this.smokingStatus,
    required this.bmi,
    required this.avgSleepHours,
    required this.stressLevel,
    required this.diabetic,
    required this.systolicBp,
    required this.diastolicBp,
    required this.heartRate,
    required this.spo2,
    required this.breathingRate,
    required this.hrv,
    required this.totalCholesterol,
    required this.hdlCholesterol,
    required this.fastingGlucose,
    required this.creatinine,
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) {
    return HealthModel(
      age: json['age'] as int,
      gender: json['gender'] as int,
      smokingStatus: json['smoking_status'] as int,
      bmi: json['bmi'] as int,
      avgSleepHours: json['avg_sleep_hours'] as int,
      stressLevel: json['stress_level'] as int,
      diabetic: json['diabetic'] as int,
      systolicBp: json['systolic_bp'] as int,
      diastolicBp: json['diastolic_bp'] as int,
      heartRate: json['heart_rate'] as int,
      spo2: json['spo2'] as int,
      breathingRate: json['breathing_rate'] as int,
      hrv: json['hrv'] as int,
      totalCholesterol: json['total_cholesterol'] as int,
      hdlCholesterol: json['hdl_cholesterol'] as int,
      fastingGlucose: json['fasting_glucose'] as int,
      creatinine: json['creatinine'] as double,
    );
  }

  factory HealthModel.empty() {
    return HealthModel(
      age: 1,
      bmi: 1,
      smokingStatus: 1,
      gender: 1,
      avgSleepHours: 1,

      stressLevel: 1,
      spo2: 1,
      heartRate: 1,
      diabetic: 1,
      systolicBp: 1,
      diastolicBp: 1,
      breathingRate: 1,
      hrv: 18,
      totalCholesterol: 240,
      hdlCholesterol: 35,
      fastingGlucose: 118,
      creatinine: 1.4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'smoking_status': smokingStatus,
      'bmi': bmi,
      'avg_sleep_hours': avgSleepHours,
      'stress_level': stressLevel,
      'diabetic': diabetic,
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,
      'heart_rate': heartRate,
      'spo2': spo2,
      'breathing_rate': breathingRate,
      'hrv': hrv,
      'total_cholesterol': totalCholesterol,
      'hdl_cholesterol': hdlCholesterol,
      'fasting_glucose': fastingGlucose,
      'creatinine': creatinine,
    };
  }

  HealthModel copyWith({
    int? age,
    int? gender,
    int? smokingStatus,
    int? bmi,
    int? avgSleepHours,
    int? stressLevel,
    int? diabetic,
    int? systolicBp,
    int? diastolicBp,
    int? heartRate,
    int? spo2,
    int? breathingRate,
    int? hrv,
    int? totalCholesterol,
    int? hdlCholesterol,
    int? fastingGlucose,
    double? creatinine,
  }) {
    return HealthModel(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      bmi: bmi ?? this.bmi,
      avgSleepHours: avgSleepHours ?? this.avgSleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      diabetic: diabetic ?? this.diabetic,
      systolicBp: systolicBp ?? this.systolicBp,
      diastolicBp: diastolicBp ?? this.diastolicBp,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      breathingRate: breathingRate ?? this.breathingRate,
      hrv: hrv ?? this.hrv,
      totalCholesterol: totalCholesterol ?? this.totalCholesterol,
      hdlCholesterol: hdlCholesterol ?? this.hdlCholesterol,
      fastingGlucose: fastingGlucose ?? this.fastingGlucose,
      creatinine: (creatinine ?? this.creatinine).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthModel &&
        other.age == age &&
        other.gender == gender &&
        other.smokingStatus == smokingStatus &&
        other.bmi == bmi &&
        other.avgSleepHours == avgSleepHours &&
        other.stressLevel == stressLevel &&
        other.diabetic == diabetic &&
        other.systolicBp == systolicBp &&
        other.diastolicBp == diastolicBp &&
        other.heartRate == heartRate &&
        other.spo2 == spo2 &&
        other.breathingRate == breathingRate &&
        other.hrv == hrv &&
        other.totalCholesterol == totalCholesterol &&
        other.hdlCholesterol == hdlCholesterol &&
        other.fastingGlucose == fastingGlucose &&
        other.creatinine == creatinine;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      age,
      gender,
      smokingStatus,
      bmi,
      avgSleepHours,
      stressLevel,
      diabetic,
      systolicBp,
      diastolicBp,
      heartRate,
      spo2,
      breathingRate,
      hrv,
      totalCholesterol,
      hdlCholesterol,
      fastingGlucose,
      creatinine,
    ]);
  }

  @override
  String toString() {
    return 'HealthModel('
        'age: $age, '
        'gender: $gender, '
        'smokingStatus: $smokingStatus, '
        'bmi: $bmi, '
        'avgSleepHours: $avgSleepHours, '
        'stressLevel: $stressLevel, '
        'diabetic: $diabetic, '
        'systolicBp: $systolicBp, '
        'diastolicBp: $diastolicBp, '
        'heartRate: $heartRate, '
        'spo2: $spo2, '
        'breathingRate: $breathingRate, '
        'hrv: $hrv, '
        'totalCholesterol: $totalCholesterol, '
        'hdlCholesterol: $hdlCholesterol, '
        'fastingGlucose: $fastingGlucose, '
        'creatinine: $creatinine'
        ')';
  }
}
