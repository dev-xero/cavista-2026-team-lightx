import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';
import 'package:light_x/data/models/health_model.dart';

class OnboardingProvider with ChangeNotifier {
  ///---------------------------------------------------
  /// STEP 1: Symptoms Assessment
  /// -------------------------------------------------

  int _sleepIndex = 0;
  int get sleepIndex => _sleepIndex;
  int _sleepTime = 0;
  int get sleepTime => _sleepTime;

  void setCurrentSleepTime(int index) {
    _sleepTime = switch (index) {
      0 => 3,
      1 => 5,
      2 => 7,
      3 => 8,
      _ => 1,
    };
    _sleepIndex = index;
    notifyListeners();
  }

  ///---------------------------------------------------
  /// STEP 2: User Details
  /// -------------------------------------------------
  int _age = 1;
  int get age => _age;

  double _height = 1;
  double get height => _height;

  double _weight = 1;
  double get weight => _weight;

  bool _isSmoking = false;
  bool get isSmoking => _isSmoking;

  void setAge(int age) {
    _age = age;
    notifyListeners();
  }

  void setHeight(double height) {
    _height = height;
    notifyListeners();
  }

  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }

  void setIsSmoking(bool isSmoking) {
    _isSmoking = isSmoking;
    notifyListeners();
  }

  bool? _isMale;
  bool? get isMale => _isMale;

  void completeOnboarding() async {
    await SharedPrefs.set(
      SharedPrefKeys.onboardingData,
      jsonEncode(
        HealthModel(
          age: _age,
          bmi: _weight.toInt(),
          smokingStatus: _isSmoking ? 1 : 1,
          gender: (_isMale == null ? null : (_isMale! ? 1 : 1)) ?? 1,
          avgSleepHours: sleepTime.toInt(),

          stressLevel: 1,
          spo2: 1,
          heartRate: 1,
          diabetic: 1,
          systolicBp: 1,
          diastolicBp: 1,
          breathingRate: 1,
          hrv: 1,
          totalCholesterol: 1,
          hdlCholesterol: 1,
          fastingGlucose: 1,
          creatinine: 1,
        ).toJson(),
      ),
    );
  }
}
