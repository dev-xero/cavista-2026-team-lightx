import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:light_x/features/scan/logic/health_service.dart';

class HealthProvider with ChangeNotifier {
  @override
  void dispose() {
    currentHealthService?.dispose();
    log("HealthProvider disposed");
    super.dispose();
  }

  String? _currDeviceName;
  String? get currDeviceName => _currDeviceName;

  WatchHealthService? currentHealthService;
  WatchHealthService? get healthService => currentHealthService;

  void setCurrDeviceName(String name) {
    _currDeviceName = name;
    notifyListeners();
  }

  void setHealthService(WatchHealthService service) {
    currentHealthService = service;
    notifyListeners();
  }
}
