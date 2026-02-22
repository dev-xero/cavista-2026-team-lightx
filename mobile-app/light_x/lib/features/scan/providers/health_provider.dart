import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:light_x/features/scan/logic/models/health_data_snapshot.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_service.dart';

class HealthProvider with ChangeNotifier {
  @override
  void dispose() {
    _healthService?.dispose();
    log("HealthProvider disposed");
    super.dispose();
  }

  String? _currDeviceName;
  String? get currDeviceName => _currDeviceName;

  WatchHealthService? _healthService;
  WatchHealthService? get healthService => _healthService;

  void setCurrDeviceName(String name) {
    _currDeviceName = name;
    log("Set current device name in provider: $name");
    notifyListeners();
  }

  HealthSnapshot? get latestSnapshot => _latestSnapshot;
  HealthSnapshot? _latestSnapshot;

  void setHealthService(WatchHealthService service) {
    _healthService = service;
    service.snapshots.listen((snap) {
      _latestSnapshot = snap;
      notifyListeners();
    });
    notifyListeners();
  }
}
