import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/home/providers/entities/devices_state.dart';
import 'package:light_x/features/scan/logic/models/health_data_snapshot.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_service.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';

const _tag = 'DevicesNotifier';

class DevicesNotifier extends Notifier<DevicesState> {
  @override
  DevicesState build() {
    ref.listen<HealthSnapshot?>(latestHealthSnapshotProvider, (_, next) {
      state = state.copyWith(latestSnapshot: next);
    });
    return DevicesState.d();
  }

  void setCurrDeviceName(String name) {
    state = state.copyWith(currDeviceName: name);
    log('Set current device name in provider: $name', name: _tag);
  }

  Future<void> setHealthService(WatchHealthService service) async {
    await ref.read(watchHealthServiceProvider.notifier).setService(service);
    state = state.copyWith(latestSnapshot: null);
  }

  Future<void> clearHealthService() async {
    await ref.read(watchHealthServiceProvider.notifier).clearService();
    state = state.copyWith(clearSnapshot: true);
  }
}
