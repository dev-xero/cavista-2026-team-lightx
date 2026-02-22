import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_x/features/scan/logic/watch_scan/health_service.dart';
import 'package:light_x/features/scan/logic/models/health_data_snapshot.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:provider/provider.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  int? _lastHr;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthService = context.watch<HealthProvider>().healthService;

    return StreamBuilder<BluetoothConnectionState>(
      stream: healthService?.connectionState,
      builder: (_, connSnap) {
        final connected = connSnap.data == BluetoothConnectionState.connected;
        // dev.log("connection state: ${connSnap.data}");
        return AppScaffold(
          leading: AppBackButton(),
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTexts.pageAppBarTitleText(healthService?.deviceName ?? "Unknown Device"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: connected ? const Color(0xFF00E676) : const Color(0xFFFF4D6D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppText(
                      connected ? 'Connected' : 'Disconnected',
                      fontSize: 11,
                      color: connected ? const Color(0xFF00E676) : const Color(0xFFFF4D6D),
                    ),
                  ],
                ),
              ],
            ),
          ),

          body: _buildBody(healthService),
        );
      },
    );
  }

  Widget _buildBody(WatchHealthService? healthService) {
    return StreamBuilder<HealthSnapshot>(
      stream: healthService?.snapshots,
      builder: (_, snap) {
        final data = snap.data;
        dev.log("got data: $data");

        if (data?.heartRate != null && data!.heartRate != _lastHr) {
          _lastHr = data.heartRate;
          WidgetsBinding.instance.addPostFrameCallback((_) => _pulseCtrl.forward(from: 0));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heart Rate — always shown, "--" when no data
              _HrCard(bpm: data?.heartRate, pulseCtrl: _pulseCtrl),
              const SizedBox(height: 14),

              // SpO2 — always shown
              _Spo2Card(spo2: data?.spo2),
              const SizedBox(height: 14),

              // Blood Pressure — always shown
              _BpCard(bp: data?.bloodPressure),
              const SizedBox(height: 14),

              // Battery — only shown once a value arrives
              if (data?.battery != null) ...[_BatteryCard(battery: data!.battery!), const SizedBox(height: 14)],

              // Waiting hint — shown until at least one metric arrives
              if (data == null || !data.hasData) _WaitingHint(),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildDisconnected() => Center(
  //   child: Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(Icons.bluetooth_disabled_rounded, size: 64, color: Colors.white.withValues(alpha: 0.12)),
  //       const SizedBox(height: 16),
  //       const Text('Device disconnected', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 16)),
  //       const SizedBox(height: 8),
  //       TextButton(
  //         onPressed: () => context.pop(),
  //         child: const Text('Go back', style: TextStyle(color: AppColors.primary)),
  //       ),
  //     ],
  //   ),
  // );
}

// ── Heart Rate ─────────────────────────────────────────────────────────────────

class _HrCard extends StatelessWidget {
  final int? bpm;
  final AnimationController pulseCtrl;
  const _HrCard({required this.bpm, required this.pulseCtrl});

  static const _color = Color(0xFFFF4D6D);
  static const _textPri = Color(0xFFE8EDF5);
  static const _textSub = Color(0xFF6B7A99);

  @override
  Widget build(BuildContext context) => _MetricCard(
    color: _color,
    icon: Icons.favorite_rounded,
    label: 'HEART RATE',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + 0.04 * sin(pulseCtrl.value * pi),
                child: Text(
                  bpm != null ? '$bpm' : '--',
                  style: TextStyle(
                    color: bpm != null ? _textPri : _textSub,
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 6),
              child: Text('bpm', style: TextStyle(color: _textSub, fontSize: 18)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _EcgLine(active: bpm != null),
      ],
    ),
  );
}

// ── SpO2 ───────────────────────────────────────────────────────────────────────

class _Spo2Card extends StatelessWidget {
  final double? spo2;
  const _Spo2Card({required this.spo2});

  static const _color = AppColors.primary;
  static const _textPri = Color(0xFFE8EDF5);
  static const _textSub = Color(0xFF6B7A99);

  Color get _statusColor {
    if (spo2 == null) return _textSub;
    if (spo2! >= 95) return const Color(0xFF00E676);
    if (spo2! >= 90) return const Color(0xFFFFD740);
    return const Color(0xFFFF4D6D);
  }

  String get _statusLabel {
    if (spo2 == null) return '';
    if (spo2! >= 95) return 'Normal';
    if (spo2! >= 90) return 'Low';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) => _MetricCard(
    color: _color,
    icon: Icons.water_drop_rounded,
    label: 'BLOOD OXYGEN',
    badge: spo2 != null ? _statusLabel : null,
    badgeColor: _statusColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              spo2 != null ? spo2!.toStringAsFixed(1) : '--',
              style: TextStyle(
                color: spo2 != null ? _textPri : _textSub,
                fontSize: 72,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 6),
              child: Text('%', style: TextStyle(color: _textSub, fontSize: 24)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: spo2 != null ? (spo2! / 100).clamp(0.0, 1.0) : 0,
            minHeight: 6,
            backgroundColor: _color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(spo2 != null ? _statusColor : _textSub),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: _textSub, fontSize: 10)),
            Text('Normal ≥ 95%', style: TextStyle(color: _textSub, fontSize: 10)),
            Text('100%', style: TextStyle(color: _textSub, fontSize: 10)),
          ],
        ),
      ],
    ),
  );
}

// ── Blood Pressure ─────────────────────────────────────────────────────────────

class _BpCard extends StatelessWidget {
  final BloodPressure? bp;
  const _BpCard({required this.bp});

  static const _color = Color(0xFFFF9F43);
  static const _textPri = Color(0xFFE8EDF5);
  static const _textSub = Color(0xFF6B7A99);

  String get _statusLabel {
    if (bp == null) return '';
    final sys = bp!.systolic;
    final dia = bp!.diastolic;
    if (sys < 120 && dia < 80) return 'Normal';
    if (sys < 130 && dia < 80) return 'Elevated';
    if (sys < 140 || dia < 90) return 'High Stage 1';
    return 'High Stage 2';
  }

  Color get _statusColor {
    if (bp == null) return _textSub;
    final sys = bp!.systolic;
    final dia = bp!.diastolic;
    if (sys < 120 && dia < 80) return const Color(0xFF00E676);
    if (sys < 130 && dia < 80) return const Color(0xFFFFD740);
    return const Color(0xFFFF4D6D);
  }

  @override
  Widget build(BuildContext context) => _MetricCard(
    color: _color,
    icon: Icons.monitor_heart_rounded,
    label: 'BLOOD PRESSURE',
    badge: bp != null ? _statusLabel : null,
    badgeColor: _statusColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              bp != null ? '${bp!.systolic}' : '--',
              style: TextStyle(
                color: bp != null ? _textPri : _textSub,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
            if (bp != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                child: Text('/', style: TextStyle(color: _textSub.withValues(alpha: 0.5), fontSize: 40)),
              ),
              Text(
                '${bp!.diastolic}',
                style: TextStyle(
                  color: _textPri.withValues(alpha: 0.7),
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.only(bottom: 10, left: 6),
              child: Text('mmHg', style: TextStyle(color: _textSub, fontSize: 16)),
            ),
          ],
        ),
        if (bp?.meanArterial != null) ...[
          const SizedBox(height: 6),
          Text('Mean arterial: ${bp!.meanArterial} mmHg', style: const TextStyle(color: _textSub, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        // Systolic range bar (60–180 mmHg displayed range)
        _BpRangeBar(value: bp?.systolic, min: 60, max: 180, color: _statusColor),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('60', style: TextStyle(color: _textSub, fontSize: 10)),
            Text('Systolic (Normal <120)', style: TextStyle(color: _textSub, fontSize: 10)),
            Text('180', style: TextStyle(color: _textSub, fontSize: 10)),
          ],
        ),
      ],
    ),
  );
}

class _BpRangeBar extends StatelessWidget {
  final int? value;
  final int min;
  final int max;
  final Color color;
  const _BpRangeBar({required this.value, required this.min, required this.max, required this.color});

  static const _textSub = Color(0xFF6B7A99);

  @override
  Widget build(BuildContext context) {
    final fraction = value != null ? ((value! - min) / (max - min)).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(value != null ? color : _textSub),
      ),
    );
  }
}

// ── Battery ────────────────────────────────────────────────────────────────────

class _BatteryCard extends StatelessWidget {
  final int battery;
  const _BatteryCard({required this.battery});

  static const _card = Color(0xFF1C2438);
  static const _textPri = Color(0xFFE8EDF5);
  static const _textSub = Color(0xFF6B7A99);

  Color get _color {
    if (battery >= 50) return const Color(0xFF00E676);
    if (battery >= 20) return const Color(0xFFFFD740);
    return const Color(0xFFFF4D6D);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _color.withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        Icon(
          battery >= 50
              ? Icons.battery_full_rounded
              : battery >= 20
              ? Icons.battery_4_bar_rounded
              : Icons.battery_alert_rounded,
          color: _color,
          size: 22,
        ),
        const SizedBox(width: 12),
        const Text(
          'BATTERY',
          style: TextStyle(color: _textSub, fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          '$battery%',
          style: TextStyle(color: _textPri, fontSize: 22, fontWeight: FontWeight.w300),
        ),
      ],
    ),
  );
}

// ── Shared card shell ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final Widget child;

  const _MetricCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.child,
    this.badge,
    this.badgeColor,
  });

  static const _card = Color(0xFF1C2438);
  static const _textSub = Color(0xFF6B7A99);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: _textSub, fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (badge != null && badge!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor!.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor!.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

// ── ECG line ───────────────────────────────────────────────────────────────────

class _EcgLine extends StatefulWidget {
  final bool active;
  const _EcgLine({required this.active});
  @override
  State<_EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<_EcgLine> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => SizedBox(
      height: 36,
      child: CustomPaint(
        painter: _EcgPainter(progress: _ctrl.value, active: widget.active),
        size: Size.infinite,
      ),
    ),
  );
}

class _EcgPainter extends CustomPainter {
  final double progress;
  final bool active;
  _EcgPainter({required this.progress, required this.active});

  static const _pts = [
    [0.00, 0.5],
    [0.10, 0.5],
    [0.12, 0.4],
    [0.14, 0.5],
    [0.16, 0.5],
    [0.18, 0.15],
    [0.20, 0.85],
    [0.22, 0.35],
    [0.24, 0.5],
    [0.28, 0.5],
    [0.30, 0.38],
    [0.33, 0.62],
    [0.36, 0.5],
    [1.00, 0.5],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const c = Color(0xFFFF4D6D);
    final paint = Paint()
      ..color = active ? c : c.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(0, size.height / 2);
    for (final pt in _pts) {
      path.lineTo(((pt[0] + progress) % 1.0) * size.width, pt[1] * size.height);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EcgPainter o) => o.progress != progress || o.active != active;
}

// ── Waiting hint ───────────────────────────────────────────────────────────────

class _WaitingHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Waiting for data… Keep the sensor in contact with your skin.',
            style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
