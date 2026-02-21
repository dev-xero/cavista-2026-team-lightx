/// ble_scanner.dart
/// Handles BLE scanning, runtime permissions, and device name resolution.
/// Scans for watches only — filtered by known wearable service UUIDs first,
/// then by name heuristics for watches that advertise no services.

library;

import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

const _tag = 'BleScanner';

// ── Watch detection ───────────────────────────────────────────────────────────
// Service UUIDs commonly advertised by BLE watches / fitness trackers.
// We pass these to startScan so the OS does the filtering at the radio level
// (most efficient). Devices that match ANY of these are included.
// Note: many cheap watches advertise NO services, so we also apply a
// name-based heuristic as a second pass.
const _watchServiceUuids = [
  '0000180d-0000-1000-8000-00805f9b34fb', // Heart Rate
  '00001822-0000-1000-8000-00805f9b34fb', // Pulse Oximeter
  '00001810-0000-1000-8000-00805f9b34fb', // Blood Pressure
  '0000180f-0000-1000-8000-00805f9b34fb', // Battery (almost always on watches)
  '0000fee0-0000-1000-8000-00805f9b34fb', // Huawei/Honor/HW wearables
  '0000fee7-0000-1000-8000-00805f9b34fb', // HW series
  '0000feea-0000-1000-8000-00805f9b34fb', // HW series
  '0000ae00-0000-1000-8000-00805f9b34fb', // Some Ultra/HW watches
  '0000190e-0000-1000-8000-00805f9b34fb', // Some Ultra/HW watches
  '0000fff0-0000-1000-8000-00805f9b34fb', // Generic fitness trackers
  '0000ffe0-0000-1000-8000-00805f9b34fb', // Generic fitness trackers
];

// Name fragments (case-insensitive) that indicate a wearable.
// Used as fallback for watches that advertise no services at all.
const _watchNameHints = [
  'watch',
  'band',
  'fit',
  'sport',
  'health',
  'smart',
  'tracker',
  'ultra',
  'hw',
  'gt',
  'gts',
  'gtr',
  'amazfit',
  'mi',
  'galaxy',
  'infinix',
  'tecno',
  'itel',
  'colmi',
  'bip',
  'stratos',
];

/// Returns true if this scan result looks like a watch.
bool _looksLikeWatch(ScanResult r) {
  // Advertised a known watch service UUID → definite match
  final advServices = r.advertisementData.serviceUuids.map((u) => u.toString().toLowerCase()).toSet();
  if (_watchServiceUuids.any((u) => advServices.contains(u))) return true;

  // Name heuristic — catches cheap watches with no advertised services
  final name = BleScanner.resolveName(r).toLowerCase();
  if (_watchNameHints.any((h) => name.contains(h))) return true;

  // Has manufacturer data but no name — likely a watch that hides its name
  // until connected. Include it so users can still tap and connect.
  final hasMfrData = r.advertisementData.manufacturerData.isNotEmpty;
  final isAnonymous = name.startsWith('device ');
  if (hasMfrData && isAnonymous) return true;

  return false;
}

class BleScanner {
  bool _disposed = false;

  /// Filtered stream — watches only.
  Stream<List<ScanResult>> get results =>
      FlutterBluePlus.scanResults.map((list) => list.where(_looksLikeWatch).toList());

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  // ── Name resolution ────────────────────────────────────────────────────────

  static String resolveName(ScanResult r) {
    final platform = r.device.platformName.trim();
    if (platform.isNotEmpty) return platform;

    final adv = r.advertisementData.advName.trim();
    if (adv.isNotEmpty) return adv;

    for (final bytes in r.advertisementData.manufacturerData.values) {
      if (bytes.length > 2) {
        final name = _decodeAscii(bytes.sublist(2));
        if (name != null) return name;
      }
    }

    for (final bytes in r.advertisementData.serviceData.values) {
      final name = _decodeAscii(bytes);
      if (name != null) return name;
    }

    final mac = r.device.remoteId.toString();
    return 'Device ${mac.substring(mac.length - 5)}';
  }

  static String? _decodeAscii(List<int> bytes) {
    try {
      final s = String.fromCharCodes(bytes).replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
      return s.length >= 3 ? s : null;
    } catch (_) {
      return null;
    }
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<bool> _requestPermissions() async {
    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      if (_disposed) return false;

      final granted = statuses.values.every((s) => s == PermissionStatus.granted || s == PermissionStatus.limited);
      if (!granted) log('Permissions not fully granted', name: _tag);
      return granted;
    } catch (e) {
      log('Permission request error: $e', name: _tag);
      return false;
    }
  }

  // ── Scan ───────────────────────────────────────────────────────────────────

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    if (_disposed) return;

    if (!await _requestPermissions()) return;

    BluetoothAdapterState state;
    try {
      state = await FlutterBluePlus.adapterState.first;
    } catch (e) {
      log('Could not read adapter state: $e', name: _tag);
      return;
    }

    if (state != BluetoothAdapterState.on) {
      log('Bluetooth is off', name: _tag);
      return;
    }

    try {
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (_) {}

    if (_disposed) return;

    log('Scan started (watches only)', name: _tag);
    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidScanMode: AndroidScanMode.balanced,
        androidUsesFineLocation: true,
        withServices: [],
      );
    } catch (e) {
      log('startScan error: $e', name: _tag);
    }
  }

  Future<void> stopScan() async {
    try {
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
        log('Scan stopped', name: _tag);
      }
    } catch (e) {
      log('stopScan error: $e', name: _tag);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stopScan();
  }
}
