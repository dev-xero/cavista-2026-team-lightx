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
}
