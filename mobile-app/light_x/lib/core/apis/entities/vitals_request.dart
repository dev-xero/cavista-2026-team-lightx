class VitalsRequest {
  final int age;
  final int gender; // 0 = female, 1 = male
  final int smokingStatus; // 0 = never, 1 = former, 2 = current
  final double bmi;
  final double avgSleepHours;
  final int stressLevel; // 1–10
  final int diabetic; // 0 = no, 1 = yes
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final double spo2;
  final double breathingRate;
  final double hrv;
  final double totalCholesterol;
  final double hdlCholesterol;
  final double fastingGlucose;
  final double creatinine;

  const VitalsRequest({
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

  Map<String, dynamic> toJson() => {
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
