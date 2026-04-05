/// health/health_profile.dart
/// Per-watch channel maps.
///
/// HOW TO ADD A NEW WATCH
/// ──────────────────────
/// 1. Connect it and run: adb logcat -s HealthService
/// 2. Note the SERVICE / CHAR lines in the log.
/// 3. Add a WatchProfile entry below — no other files change.

/// health/health_profile.dart
/// Per-watch channel maps.
///
/// HOW TO ADD A NEW WATCH
/// ──────────────────────
/// 1. Connect it and run: adb logcat -s HealthService
/// 2. Note the SERVICE / CHAR lines in the log.
/// 3. Add a WatchProfile entry below — no other files change.

library;

enum ChannelRole {
  heartRate,
  spo2,
  bloodPressure, // standard GATT 0x2A35
  battery,
  proprietary, // best-effort layout detection
}

class WatchChannel {
  final String service; // 4-char short UUID
  final String characteristic; // 4-char short UUID
  final ChannelRole role;

  const WatchChannel({required this.service, required this.characteristic, required this.role});
}

class WatchProfile {
  final String name;
  final List<WatchChannel> channels;

  /// Write characteristic to trigger health measurements.
  /// Set this when the watch needs an explicit command to start pushing data
  /// (e.g. Nordic UART / COLMI-based watches). null = no trigger needed.
  final _UartTrigger? uartTrigger;

  const WatchProfile({required this.name, required this.channels, this.uartTrigger});
}

/// Describes a write characteristic + commands to send on connect.
class _UartTrigger {
  final String service;
  final String characteristic;
  final List<List<int>> commands;
  const _UartTrigger({required this.service, required this.characteristic, required this.commands});
}

// ── Shared standard channels ──────────────────────────────────────────────────

const _standardHr = WatchChannel(service: '180d', characteristic: '2a37', role: ChannelRole.heartRate);
const _standardPlxContinuous = WatchChannel(service: '1822', characteristic: '2a5f', role: ChannelRole.spo2);
const _standardPlxSpotCheck = WatchChannel(service: '1822', characteristic: '2a5e', role: ChannelRole.spo2);
const _standardBp = WatchChannel(service: '1810', characteristic: '2a35', role: ChannelRole.bloodPressure);
const _standardBattery = WatchChannel(service: '180f', characteristic: '2a19', role: ChannelRole.battery);

// ── Watch channel lists ───────────────────────────────────────────────────────

// ── Watch 1: XWatch 3 Plus (MAC: 88:9B:B9:0A:DC:7E) ─────────────────────────
// Services: 180d (HR ✓), feea, fee7, 190e, ae00, 180f (battery ✓)
// No UART trigger needed — pushes data on its own after subscription.
const _xwatchChannels = [
  _standardHr,
  _standardBp,
  _standardBattery,
  WatchChannel(service: 'feea', characteristic: 'fee1', role: ChannelRole.proprietary),
  WatchChannel(service: 'feea', characteristic: 'fee3', role: ChannelRole.proprietary),
  WatchChannel(service: 'fee7', characteristic: 'fea1', role: ChannelRole.proprietary),
  WatchChannel(service: '190e', characteristic: '0003', role: ChannelRole.proprietary),
  WatchChannel(service: 'ae00', characteristic: 'ae02', role: ChannelRole.proprietary),
];

// ── Watch 2: ULTRA3 (MAC: C2:A0:0F:B6:58:54) ─────────────────────────────────
// Services: 0901 (Nordic UART), 3802, ae00, fee7, 180f (battery ✓)
// IMPORTANT: No UART trigger — the 0x01/0x69/0x15 commands caused a watchdog
// reset on this firmware. Subscribe only; watch pushes data passively.
const _ultra3Channels = [
  _standardBattery,
  WatchChannel(service: '0901', characteristic: '0003', role: ChannelRole.proprietary),
  WatchChannel(service: '0901', characteristic: '0004', role: ChannelRole.proprietary),
  WatchChannel(service: '3802', characteristic: '4a02', role: ChannelRole.proprietary),
  WatchChannel(service: 'ae00', characteristic: 'ae02', role: ChannelRole.proprietary),
  WatchChannel(service: 'fee7', characteristic: 'fec8', role: ChannelRole.proprietary),
];

// ── Watch 3: ULTRA9 (MAC: 38:86:FB:00:32:3A) ─────────────────────────────────
// Services: 0001 (UART-like), ffff (likely main health), 3802, 180f (battery)
// 0001/0002 [W]  — write/command channel
// 0001/0003 [N]  — notify/response channel
// ffff/ff11 [N]  — high probability health data (HR/SpO2/BP)
// 3802/4a02 [R|W|N] — shared proprietary health service (seen on ULTRA3 too)
// UART trigger on 0001/0002 — different service UUID from ULTRA3 (0901 vs 0001).
const _ultra9Channels = [
  _standardBattery,
  WatchChannel(service: '0001', characteristic: '0003', role: ChannelRole.proprietary),
  WatchChannel(service: 'ffff', characteristic: 'ff11', role: ChannelRole.proprietary),
  WatchChannel(service: '3802', characteristic: '4a02', role: ChannelRole.proprietary),
];

const _ultra9Trigger = _UartTrigger(
  service: '0001',
  characteristic: '0002',
  commands: [
    [0x01, 0x00], // start real-time HR
    [0x69, 0x00], // start SpO2
    [0x15, 0x01], // start BP
  ],
);

// ── Watch registry ────────────────────────────────────────────────────────────

final Map<String, WatchProfile> watchProfiles = {
  'xwatch': WatchProfile(name: 'XWatch 3 Plus', channels: _xwatchChannels),
  'hw': WatchProfile(name: 'HW Series', channels: _xwatchChannels),
  'oraimo': WatchProfile(name: 'Oraimo Watch 5 Lite', channels: _xwatchChannels),

  'ultra3': WatchProfile(name: 'ULTRA3', channels: _ultra3Channels),
  // ultra9 gets its own separate profile + UART trigger
  'ultra9': WatchProfile(name: 'ULTRA9', channels: _ultra9Channels, uartTrigger: _ultra9Trigger),
};

// ── Fallback ──────────────────────────────────────────────────────────────────

final WatchProfile fallbackProfile = WatchProfile(
  name: 'Generic BLE Wearable',
  channels: [_standardHr, _standardPlxContinuous, _standardPlxSpotCheck, _standardBp, _standardBattery],
);

// ── Resolver ──────────────────────────────────────────────────────────────────

WatchProfile resolveProfile(String deviceName) {
  final lower = deviceName.toLowerCase();
  for (final entry in watchProfiles.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return fallbackProfile;
}
