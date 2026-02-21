/// UUID normalisation and well-known GATT UUID constants.
/// flutter_blue_plus returns UUIDs in different formats depending on platform
/// and FBP version. Everything is normalised to the 4-char short form here.

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ── Normalisation ─────────────────────────────────────────────────────────────

/// Converts any FBP Guid to the 4-char lowercase short UUID.
/// "0000180d-0000-1000-8000-00805f9b34fb" → "180d"
/// "180d" → "180d"
String shortUuid(Guid guid) {
  final s = guid.toString().toLowerCase();
  if (s.length == 36) return s.substring(4, 8); // full 128-bit
  return s.replaceAll('-', '').substring(0, 4);
}

/// Same but from a raw string (for map keys etc.)
String shortUuidStr(String raw) {
  final s = raw.toLowerCase();
  if (s.length == 36) return s.substring(4, 8);
  return s.replaceAll('-', '').substring(0, 4);
}

// ── Standard GATT Services ────────────────────────────────────────────────────

const kSvcGenericAccess = '1800';
const kSvcGenericAttribute = '1801';
const kSvcHeartRate = '180d';
const kSvcBattery = '180f';
const kSvcDeviceInfo = '180a';
const kSvcPlx = '1822'; // Pulse Oximeter

// ── Standard GATT Characteristics ────────────────────────────────────────────

const kCharDeviceName = '2a00';
const kCharHeartRate = '2a37'; // Heart Rate Measurement
const kCharBodySensorLoc = '2a38';
const kCharBattery = '2a19';
const kCharPlxContinuous = '2a5f';
const kCharPlxSpotCheck = '2a5e';

// ── Human-readable label for a short UUID (for logging) ──────────────────────

String uuidLabel(String short) => _labels[short] ?? short;

const _labels = {
  kSvcHeartRate: 'Heart Rate Service',
  kSvcBattery: 'Battery Service',
  kSvcPlx: 'Pulse Oximeter Service',
  kSvcDeviceInfo: 'Device Info Service',
  kCharHeartRate: 'HR Measurement',
  kCharBattery: 'Battery Level',
  kCharPlxContinuous: 'PLX Continuous',
  kCharPlxSpotCheck: 'PLX Spot-check',
};
