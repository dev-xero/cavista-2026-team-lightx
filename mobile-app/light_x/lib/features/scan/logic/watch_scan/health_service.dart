/// health/health_service.dart
/// Orchestrates service discovery → channel subscription → parsing → emission.
/// All watch-specific knowledge lives in health_profile.dart.
/// All parsing logic lives in health_parser.dart.

library;

import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_x/features/scan/logic/data/ble_uuid.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_parser.dart';
import 'package:light_x/features/scan/logic/models/health_data_snapshot.dart';
import 'package:light_x/features/scan/logic/models/health_profile.dart';

const _tag = 'HealthService';

class WatchHealthService {
  final BluetoothDevice device;
  final String deviceName;

  WatchHealthService({required this.device, required this.deviceName});

  final _controller = StreamController<HealthSnapshot>.broadcast();
  Stream<HealthSnapshot> get snapshots => _controller.stream;
  Stream<BluetoothConnectionState> get connectionState => device.connectionState;

  HealthSnapshot _current = const HealthSnapshot();
  final List<StreamSubscription> _subs = [];
  final List<Timer> _timers = [];
  bool _disposed = false;

  // ── Start ──────────────────────────────────────────────────────────────────

  Future<void> start() async {
    final profile = resolveProfile(deviceName);
    log('Profile: "${profile.name}" for "$deviceName"', name: _tag);

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      log('discoverServices() failed: $e', name: _tag);
      return;
    }
    if (_disposed) return;

    log('Found ${services.length} services', name: _tag);

    // Build lookup: svc short UUID → char short UUID → characteristic object
    // Always log the full GATT table so we can build profiles for unknown watches
    final lookup = <String, Map<String, BluetoothCharacteristic>>{};
    for (final svc in services) {
      final sKey = shortUuid(svc.serviceUuid);
      log('  SERVICE $sKey', name: _tag);
      lookup[sKey] = {};
      for (final c in svc.characteristics) {
        final cKey = shortUuid(c.characteristicUuid);
        final props = [
          if (c.properties.read) 'R',
          if (c.properties.write) 'W',
          if (c.properties.notify) 'N',
          if (c.properties.indicate) 'I',
        ].join('|');
        log('    CHAR $cKey [$props]', name: _tag);
        lookup[sKey]![cKey] = c;
      }
    }

    int subscribed = 0;
    for (final channel in profile.channels) {
      final char = lookup[channel.service]?[channel.characteristic];
      if (char == null) continue; // not present on this device — skip silently
      await _subscribeChannel(char, channel);
      subscribed++;
    }

    log('Subscribed to $subscribed / ${profile.channels.length} channels', name: _tag);

    // Nordic UART watches (e.g. ULTRA3) require a write command to the TX
    // characteristic (0901/0002) to start pushing health data notifications.
    // Send the standard "start measurement" probe bytes used by most COLMI/
    // Nordic-based wearables. Silently skipped if the char isn't present.
    await _triggerNordicUart(lookup, profile);

    // Trigger notify-all fallback if no *health* data channels were found
    // (battery alone doesn't count — we still need HR / SpO2 / BP)
    final hasHealthData = _current.heartRate != null || _current.spo2 != null || _current.bloodPressure != null;
    final healthChannels = profile.channels
        .where(
          (c) =>
              c.role == ChannelRole.heartRate ||
              c.role == ChannelRole.spo2 ||
              c.role == ChannelRole.bloodPressure ||
              c.role == ChannelRole.proprietary,
        )
        .length;
    final subscribedHealth = profile.channels
        .where(
          (c) =>
              lookup[c.service]?[c.characteristic] != null &&
              (c.role == ChannelRole.heartRate ||
                  c.role == ChannelRole.spo2 ||
                  c.role == ChannelRole.bloodPressure ||
                  c.role == ChannelRole.proprietary),
        )
        .length;

    log('Health channels: $healthChannels, subscribed: $subscribedHealth, has data: $hasHealthData', name: _tag);

    if (subscribedHealth == 0) {
      log('No health channels matched — subscribing to all notifying chars', name: _tag);
      await _subscribeAllNotifying(services);
    }
  }

  // ── Channel handler dispatch ───────────────────────────────────────────────

  Future<void> _subscribeChannel(BluetoothCharacteristic char, WatchChannel channel) async {
    final label = '${channel.service}/${channel.characteristic}';

    void handler(List<int> data) {
      if (data.isEmpty || _disposed) return;
      switch (channel.role) {
        case ChannelRole.heartRate:
          final hr = parseHeartRate(data);
          if (hr != null) {
            log('HR $hr bpm', name: _tag);
            _emit(_current = _current.copyWith(heartRate: hr));
          }

        case ChannelRole.spo2:
          final spo2 = parsePlxSpo2(data);
          if (spo2 != null) {
            log('SpO2 $spo2%', name: _tag);
            _emit(_current = _current.copyWith(spo2: spo2));
          }

        case ChannelRole.bloodPressure:
          final bp = parseBloodPressure(data);
          if (bp != null) {
            log('BP ${bp.systolic}/${bp.diastolic} mmHg', name: _tag);
            _emit(_current = _current.copyWith(bloodPressure: bp));
          }

        case ChannelRole.battery:
          final batt = parseBattery(data);
          if (batt != null) {
            log('Battery $batt%', name: _tag);
            _emit(_current = _current.copyWith(battery: batt));
          }

        case ChannelRole.proprietary:
          final result = parseProprietary(data, label: label);
          if (result.hasData) {
            if (result.heartRate != null) log('HR ${result.heartRate} bpm', name: _tag);
            if (result.spo2 != null) log('SpO2 ${result.spo2}%', name: _tag);
            if (result.bloodPressure != null) {
              log('BP ${result.bloodPressure!.systolic}/${result.bloodPressure!.diastolic} mmHg', name: _tag);
            }
            _emit(
              _current = _current.copyWith(
                heartRate: result.heartRate,
                spo2: result.spo2,
                bloodPressure: result.bloodPressure,
              ),
            );
          }
      }
    }

    await _attach(char, handler, label: label);
  }

  // ── UART trigger ─────────────────────────────────────────────────────────
  // Sends profile-defined commands to the watch's write characteristic to
  // start health data notifications. Only runs if the profile defines a
  // uartTrigger — avoids the watchdog crash that happened on ULTRA3.
  Future<void> _triggerNordicUart(
    Map<String, Map<String, BluetoothCharacteristic>> lookup,
    WatchProfile profile,
  ) async {
    final trigger = profile.uartTrigger;
    if (trigger == null) return; // this watch pushes data on its own

    final writeChar = lookup[trigger.service]?[trigger.characteristic];
    if (writeChar == null || !writeChar.properties.write) {
      log('UART trigger char ${trigger.service}/${trigger.characteristic} not found', name: _tag);
      return;
    }

    log('Sending ${trigger.commands.length} UART trigger commands', name: _tag);
    for (final cmd in trigger.commands) {
      try {
        await writeChar.write(cmd, withoutResponse: false);
        log('UART → ${cmd.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}', name: _tag);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        log('UART cmd failed: $e', name: _tag);
      }
    }
  }

  // ── Fallback: subscribe to all notifying characteristics ──────────────────

  Future<void> _subscribeAllNotifying(List<BluetoothService> services) async {
    for (final svc in services) {
      for (final char in svc.characteristics) {
        if (!char.properties.notify && !char.properties.indicate) continue;
        final label = '${shortUuid(svc.serviceUuid)}/${shortUuid(char.characteristicUuid)}';
        await _attach(char, (data) {
          if (data.isEmpty || _disposed) return;
          final result = parseProprietary(data, label: label);
          if (result.hasData) {
            _emit(
              _current = _current.copyWith(
                heartRate: result.heartRate,
                spo2: result.spo2,
                bloodPressure: result.bloodPressure,
              ),
            );
          }
        }, label: label);
      }
    }
  }

  // ── Low-level: notify or read-poll ────────────────────────────────────────

  Future<void> _attach(BluetoothCharacteristic char, void Function(List<int>) handler, {required String label}) async {
    try {
      if (char.properties.notify || char.properties.indicate) {
        await char.setNotifyValue(true);
        _subs.add(char.lastValueStream.listen(handler, onError: (e) => log('Stream error [$label]: $e', name: _tag)));
        log('Subscribed [$label]', name: _tag);
      } else if (char.properties.read) {
        final timer = Timer.periodic(const Duration(seconds: 3), (_) async {
          if (_disposed) return;
          try {
            handler(await char.read());
          } catch (_) {}
        });
        _timers.add(timer);
        log('Polling [$label] every 3s', name: _tag);
      }
    } catch (e) {
      log('Failed to attach [$label]: $e', name: _tag);
    }
  }

  void _emit(HealthSnapshot snap) {
    if (!_controller.isClosed) _controller.add(snap);
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    _disposed = true;
    for (final t in _timers) t.cancel();
    for (final s in _subs) await s.cancel();
    await _controller.close();
    try {
      await device.disconnect();
      log('Disconnected from ${device.remoteId}', name: _tag);
    } catch (_) {}
  }
}
