import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_x/features/scan/logic/ble_connector.dart';
import 'package:light_x/features/scan/logic/ble_scanner.dart';
import 'package:light_x/features/scan/logic/health_service.dart';
import 'health_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _scanner = BleScanner();
  bool _connecting = false;
  String? _connectingId;

  // Deduplicate by MAC, keep strongest RSSI, sort strongest first
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
        const SnackBar(content: Text('Connection failed. Keep the device nearby.'), backgroundColor: Color(0xFFFF4D6D)),
      );
      return;
    }

    final name = BleScanner.resolveName(result);
    final service = WatchHealthService(device: device, deviceName: name);

    setState(() {
      _connecting = false;
      _connectingId = null;
    });

    // Navigate first so StreamBuilder is subscribed before start() emits data
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthScreen(deviceName: name, service: service),
      ),
    );
    await service.start();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  static const _bg = Color(0xFF0A0E1A);
  static const _surface = Color(0xFF131929);
  static const _accent = Color(0xFF00E5FF);
  static const _textPri = Color(0xFFE8EDF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: const Text(
          'Nearby Devices',
          style: TextStyle(color: _textPri, fontFamily: 'monospace', fontSize: 18, letterSpacing: 1.2),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: _scanner.isScanning,
            builder: (_, snap) {
              final scanning = snap.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: scanning
                    ? const _ScanningBadge()
                    : IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: _accent),
                        onPressed: () => _scanner.startScan(),
                      ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: _scanner.results,
        initialData: const [],
        builder: (_, snap) {
          final results = _process(snap.data ?? []);
          if (results.isEmpty) {
            return _EmptyState(onScan: _scanner.startScan);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = results[i];
              return _DeviceTile(
                result: r,
                name: BleScanner.resolveName(r),
                isConnecting: _connecting && _connectingId == r.device.remoteId.toString(),
                disabled: _connecting,
                onTap: () => _onTap(r),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => Center(
    child: FadeTransition(
      opacity: _ctrl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF), width: 0.6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_rounded, color: Color(0xFF00E5FF), size: 14),
            SizedBox(width: 4),
            Text(
              'SCANNING',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

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

  static const _accent = Color(0xFF00E5FF);
  static const _card = Color(0xFF1C2438);
  static const _textPri = Color(0xFFE8EDF5);
  static const _textSub = Color(0xFF6B7A99);

  bool get _isUnknown => name.startsWith('Device ');

  Color get _rssiColor {
    if (result.rssi >= -60) return const Color(0xFF00E676);
    if (result.rssi >= -75) return const Color(0xFFFFD740);
    return const Color(0xFFFF6E6E);
  }

  int get _bars {
    if (result.rssi >= -60) return 3;
    if (result.rssi >= -75) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _accent.withOpacity(0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isConnecting ? _accent : Colors.white.withOpacity(0.06),
              width: isConnecting ? 1.0 : 0.8,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(_isUnknown ? 0.04 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isUnknown ? Icons.device_unknown_rounded : Icons.watch_rounded,
                  color: _isUnknown ? _textSub : _accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: _isUnknown ? _textSub : _textPri,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.device.remoteId.toString(),
                      style: const TextStyle(color: _textSub, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              if (isConnecting)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _accent))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RssiBars(bars: _bars, color: _rssiColor),
                    const SizedBox(height: 3),
                    Text(
                      '${result.rssi} dBm',
                      style: TextStyle(color: _rssiColor, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
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
            color: i < bars ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bluetooth_searching_rounded, size: 64, color: Colors.white.withOpacity(0.12)),
        const SizedBox(height: 16),
        const Text('No devices found', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 16)),
        const SizedBox(height: 8),
        const Text(
          'Make sure your watch is awake.\nNo pairing mode needed.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4A5568), fontSize: 13),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E5FF)),
          label: const Text('Scan Again', style: TextStyle(color: Color(0xFF00E5FF))),
        ),
      ],
    ),
  );
}
