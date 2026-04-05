import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_x/features/scan/logic/entities/health_data_snapshot.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_service.dart';

final latestHealthSnapshotProvider = NotifierProvider<HealthSnapshotNotifier, HealthSnapshot?>(
  () => HealthSnapshotNotifier(),
);

class HealthSnapshotNotifier extends Notifier<HealthSnapshot?> {
  @override
  HealthSnapshot? build() => null;

  void setSnapshot(HealthSnapshot snap) => state = snap;
  void clear() => state = null;
}

final watchHealthServiceProvider = NotifierProvider<WatchHealthServiceNotifier, WatchHealthService?>(
  () => WatchHealthServiceNotifier(),
);

class WatchHealthServiceNotifier extends Notifier<WatchHealthService?> {
  StreamSubscription<HealthSnapshot>? _snapshotSub;

  @override
  WatchHealthService? build() {
    ref.onDispose(() {
      _snapshotSub?.cancel();
      _snapshotSub = null;
    });
    return null;
  }

  Future<void> setService(WatchHealthService service) async {
    await _snapshotSub?.cancel();
    _snapshotSub = service.snapshots.listen((snap) {
      ref.read(latestHealthSnapshotProvider.notifier).setSnapshot(snap);
    });

    ref.read(latestHealthSnapshotProvider.notifier).clear();
    state = service;
  }

  Future<void> clearService() async {
    await _snapshotSub?.cancel();
    _snapshotSub = null;
    ref.read(latestHealthSnapshotProvider.notifier).clear();
    state = null;
  }
}
