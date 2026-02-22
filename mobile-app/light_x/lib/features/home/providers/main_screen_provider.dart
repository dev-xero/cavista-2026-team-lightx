import 'package:flutter/widgets.dart';

class MainScreenProvider with ChangeNotifier {
  int currentIndex = 0;

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
