import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  ///---------------------------------------------------
  /// STEP 1: Symptoms Assessment
  /// -------------------------------------------------
  int _sleepTimeIndex = 0;
  int get sleepTimeIndex => _sleepTimeIndex;

  void setCurrentIndex(int index) {
    _sleepTimeIndex = index;
    notifyListeners();
  }

  ///---------------------------------------------------
  /// STEP 2: User Details
  /// -------------------------------------------------
  int _age = 0;
  int get age => _age;

  double _height = 0;
  double get height => _height;

  double _weight = 0;
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
}
