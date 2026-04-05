import 'package:light_x/features/scan/logic/entities/health_data_snapshot.dart';

class DevicesState {
  final String? currDeviceName;
  final HealthSnapshot? latestSnapshot;

  const DevicesState({this.currDeviceName, this.latestSnapshot});

  factory DevicesState.d() => const DevicesState();

  DevicesState copyWith({String? currDeviceName, HealthSnapshot? latestSnapshot, bool clearSnapshot = false}) {
    return DevicesState(
      currDeviceName: currDeviceName ?? this.currDeviceName,
      latestSnapshot: clearSnapshot ? null : (latestSnapshot ?? this.latestSnapshot),
    );
  }
}
