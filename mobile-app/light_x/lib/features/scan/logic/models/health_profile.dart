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
  const WatchProfile({required this.name, required this.channels});
}

// ── Shared standard channels ──────────────────────────────────────────────────

const _standardHr = WatchChannel(service: '180d', characteristic: '2a37', role: ChannelRole.heartRate);
const _standardPlxContinuous = WatchChannel(service: '1822', characteristic: '2a5f', role: ChannelRole.spo2);
const _standardPlxSpotCheck = WatchChannel(service: '1822', characteristic: '2a5e', role: ChannelRole.spo2);
const _standardBp = WatchChannel(service: '1810', characteristic: '2a35', role: ChannelRole.bloodPressure);
const _standardBattery = WatchChannel(service: '180f', characteristic: '2a19', role: ChannelRole.battery);

// ── Watch channel lists ───────────────────────────────────────────────────────

// Watch 1 — XWatch 3 Plus (MAC: 88:9B:B9:0A:DC:7E)
// Confirmed services: 180d (HR ✓), feea, fee7, 190e, ae00, 180f (battery ✓)
// Name variants: "XWatch 3 Plus", "HW Watch", any "hw" prefix
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

// Watch 2 — ULTRA3 (MAC: C2:A0:0F:B6:58:54)
// No standard HR/SpO2/BP services. Uses Nordic UART (0901) + proprietary channels.
// 0901/0003 = Nordic UART notify (6e400003) — main health data pipe
// 0901/0004 = Nordic UART TX    (6e400004) — responses/acks
// 3802/4a02 = proprietary health data (R|W|N)
// ae00/ae02 = proprietary notify (shared pattern with XWatch)
// fee7/fec8 = proprietary indicate
// Battery via 180f/2a19 (R|N) — confirmed
const _ultra3Channels = [
  _standardBattery,
  // Nordic UART — main data channel on this watch
  WatchChannel(service: '0901', characteristic: '0003', role: ChannelRole.proprietary),
  WatchChannel(service: '0901', characteristic: '0004', role: ChannelRole.proprietary),
  // Proprietary health service
  WatchChannel(service: '3802', characteristic: '4a02', role: ChannelRole.proprietary),
  // Shared proprietary channels
  WatchChannel(service: 'ae00', characteristic: 'ae02', role: ChannelRole.proprietary),
  WatchChannel(service: 'fee7', characteristic: 'fec8', role: ChannelRole.proprietary),
];

// ── Watch registry ────────────────────────────────────────────────────────────
// Keys matched case-insensitively as substrings of the resolved device name.
// First match wins. Multiple keys can share the same channel list.

final Map<String, WatchProfile> watchProfiles = {
  // XWatch 3 Plus — all known name variants
  'xwatch': WatchProfile(name: 'XWatch 3 Plus', channels: _xwatchChannels),
  'hw': WatchProfile(name: 'HW Series', channels: _xwatchChannels),

  // ULTRA3 — all known name variants
  'ultra3': WatchProfile(name: 'ULTRA3', channels: _ultra3Channels),
  'ultra9': WatchProfile(name: 'ULTRA9', channels: _ultra3Channels),

  // Add more watches here after getting their GATT dump:
  // 'infinix': WatchProfile(name: 'Infinix', channels: [...]),
};

// ── Fallback — standard GATT only ────────────────────────────────────────────
// Used when no name key matches. Tries all standard GATT channels then falls
// through to notify-all scan in health_service.dart.

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
