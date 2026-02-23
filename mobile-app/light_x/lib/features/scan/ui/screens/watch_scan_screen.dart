import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_x/features/scan/logic/watch_scan/ble_connector.dart';
import 'package:light_x/features/scan/logic/watch_scan/ble_scanner.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_service.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:provider/provider.dart';

/// Redesigned scan screen — matches the Devices screen colour palette
/// (white cards, rounded corners, Manrope type, AppColors tokens).
class WatchScanScreen extends StatefulWidget {
  const WatchScanScreen({super.key});

  @override
  State<WatchScanScreen> createState() => _WatchScanScreenState();
}

class _WatchScanScreenState extends State<WatchScanScreen> {
  final _scanner = BleScanner();
  bool _connecting = false;
  String? _connectingId;

  List<ScanResult> _process(List<ScanResult> raw) {
    final map = <String, ScanResult>{};
    for (final r in raw) {
      final id = r.device.remoteId.toString();
      if (!map.containsKey(id) || r.rssi > map[id]!.rssi) map[id] = r;
    }
    return map.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  @override
  void initState() {
    super.initState();
    _scanner.startScan();
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onTap(ScanResult result) async {
    if (_connecting) return;
    final id = result.device.remoteId.toString();
    setState(() {
      _connecting = true;
      _connectingId = id;
    });

    final device = await BleConnector.connect(result.device);

    if (!mounted) return;
    if (device == null) {
      setState(() {
        _connecting = false;
        _connectingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connection failed. Keep the device nearby.'),
          backgroundColor: const Color(0xFFFF4D6D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final name = BleScanner.resolveName(result);
    final service = WatchHealthService(device: device, deviceName: name);

    setState(() {
      _connecting = false;
      _connectingId = null;
    });

    final hp = context.read<HealthProvider>();
    hp.setCurrDeviceName(name);
    hp.setHealthService(service);

    // Pop back to Devices screen — it will reflect the connected state.
    if (!mounted) return;
    Navigator.of(context).pop();

    // Start data streaming after navigation.
    await service.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: AppColors.textPrimary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Nearby Devices',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 28 / 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Scanning badge / refresh
                  StreamBuilder<bool>(
                    stream: _scanner.isScanning,
                    builder: (_, snap) {
                      final scanning = snap.data ?? false;
                      return scanning
                          ? const _ScanningBadge()
                          : GestureDetector(
                              onTap: () => _scanner.startScan(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh_rounded, color: AppColors.primary, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'SCAN',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),

            // ── Subtitle ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Text(
                'Select a watch to connect. No pairing mode needed.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w400),
              ),
            ),

            // ── Device list ────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: _scanner.results,
                initialData: const [],
                builder: (_, snap) {
                  final results = _process(snap.data ?? []);
                  if (results.isEmpty) {
                    return _EmptyState(onScan: _scanner.startScan);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = results[i];
                      final id = r.device.remoteId.toString();
                      return _DeviceTile(
                        result: r,
                        name: BleScanner.resolveName(r),
                        isConnecting: _connecting && _connectingId == id,
                        disabled: _connecting,
                        onTap: () => _onTap(r),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scanning badge ─────────────────────────────────────────────────────────────

class _ScanningBadge extends StatefulWidget {
  const _ScanningBadge();

  @override
  State<_ScanningBadge> createState() => _ScanningBadgeState();
}

class _ScanningBadgeState extends State<_ScanningBadge> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _ctrl,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors_rounded, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(
            'SCANNING',
            style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

// ── Device tile ────────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final String name;
  final bool isConnecting;
  final bool disabled;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.result,
    required this.name,
    required this.isConnecting,
    required this.disabled,
    required this.onTap,
  });

  bool get _isUnknown => name.startsWith('Device ');

  Color get _signalColor {
    if (result.rssi >= -60) return const Color(0xFF22C55E);
    if (result.rssi >= -75) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _signalLabel {
    if (result.rssi >= -60) return 'Strong';
    if (result.rssi >= -75) return 'Good';
    return 'Weak';
  }

  int get _bars {
    if (result.rssi >= -60) return 3;
    if (result.rssi >= -75) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isConnecting ? AppColors.primary : AppColors.surfaceBorder,
            width: isConnecting ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnecting ? AppColors.primary.withValues(alpha: 0.08) : const Color(0x0D000000),
              blurRadius: isConnecting ? 8 : 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isUnknown ? AppColors.inputBg : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _isUnknown ? Icons.device_unknown_rounded : Icons.watch_rounded,
                color: _isUnknown ? AppColors.textMuted : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Name + MAC
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: _isUnknown ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.device.remoteId.toString(),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),

            // Right: connecting spinner or signal indicator
            if (isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _RssiBars(bars: _bars, color: _signalColor),
                  const SizedBox(height: 3),
                  Text(
                    _signalLabel,
                    style: TextStyle(color: _signalColor, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RssiBars extends StatelessWidget {
  final int bars;
  final Color color;
  const _RssiBars({required this.bars, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: List.generate(3, (i) {
      return Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Container(
          width: 4,
          height: 6.0 + i * 4,
          decoration: BoxDecoration(
            color: i < bars ? color : color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }),
  );
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(Icons.bluetooth_searching_rounded, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No devices found',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your watch is awake.\nNo pairing mode needed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onScan,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(color: AppColors.syncBtn, borderRadius: BorderRadius.circular(24)),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan Again',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
