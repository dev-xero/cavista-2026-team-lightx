import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

/// Top bar: title on the left, optional action widget on the right.
class WatchSyncHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const WatchSyncHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(title, fontWeight: FontWeight.w700, fontSize: 20, height: 28 / 20, color: AppColors.textPrimary),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Connection Badge
// ─────────────────────────────────────────────

/// Animated pulsing dot + label pill.
class ConnectionBadge extends StatefulWidget {
  final String label;
  final bool connected;
  const ConnectionBadge({super.key, this.label = 'Connected', this.connected = true});

  @override
  State<ConnectionBadge> createState() => _ConnectionBadgeState();
}

class _ConnectionBadgeState extends State<ConnectionBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.2).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.connected ? AppColors.connectedDot : const Color(0xFFFF4D6D);
    final glowColor = widget.connected ? AppColors.connectedGlow : const Color(0xFFFF4D6D).withValues(alpha: 0.3);
    final bgColor = widget.connected ? AppColors.connectedBg : const Color(0xFFFF4D6D).withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: glowColor, shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label.toUpperCase(),
              style: AppTextStyles.connBadge.copyWith(color: widget.connected ? null : const Color(0xFFFF4D6D)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sync Hub
// ─────────────────────────────────────────────

class _SyncRingPainter extends CustomPainter {
  final double rotation;

  _SyncRingPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final inset = size.width * 0.0417;
    final radius = size.width / 2 - inset - 4;

    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final dashPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const dashCount = 20;
    const dashAngle = 2 * math.pi / dashCount;
    const gapFraction = 0.4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    for (int i = 0; i < dashCount; i++) {
      final start = i * dashAngle;
      final sweep = dashAngle * (1 - gapFraction);
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius), start, sweep, false, dashPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SyncRingPainter old) => old.rotation != rotation;
}

class SyncHub extends StatefulWidget {
  final String valueLabel;
  final String title;
  final String subtitle;

  const SyncHub({super.key, required this.valueLabel, required this.title, required this.subtitle});

  @override
  State<SyncHub> createState() => _SyncHubState();
}

class _SyncHubState extends State<SyncHub> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _spin,
                builder: (_, __) =>
                    CustomPaint(size: const Size(192, 192), painter: _SyncRingPainter(_spin.value * 2 * math.pi)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.watch_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 4),
                  Text(widget.valueLabel, style: AppTextStyles.syncValue),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(widget.title, textAlign: TextAlign.center, style: AppTextStyles.syncTitle),
        const SizedBox(height: 4),
        Text(widget.subtitle, textAlign: TextAlign.center, style: AppTextStyles.syncSubtitle),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Stat Cards
// ─────────────────────────────────────────────

class _Sparkline extends StatelessWidget {
  static const _bars = [
    (height: 12.0, color: AppColors.heartBar1),
    (height: 20.0, color: AppColors.heartBar2),
    (height: 32.0, color: AppColors.heartBar3),
    (height: 16.0, color: AppColors.heartBar2),
    (height: 24.0, color: AppColors.heartBar1),
  ];

  const _Sparkline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < _bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Container(
              width: 4,
              height: _bars[i].height,
              decoration: BoxDecoration(
                color: _bars[i].color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  final double fraction;
  final String label;

  const _MiniProgressBar({required this.fraction, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTextStyles.statProgress),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 6,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(9999)),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9999)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget leading;
  final String label;
  final Widget valueRow;
  final Widget trailing;

  const _StatCard({required this.leading, required this.label, required this.valueRow, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.statLabel),
                  const SizedBox(height: 2),
                  valueRow,
                ],
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}

class _StatIconTile extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _StatIconTile({required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatValueRow extends StatelessWidget {
  final String value;
  final String? unit;

  const _StatValueRow({required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: AppTextStyles.statValue),
        if (unit != null) ...[const SizedBox(width: 4), Text(unit!.toUpperCase(), style: AppTextStyles.statUnit)],
      ],
    );
  }
}

class HeartRateCard extends StatelessWidget {
  final String value;
  const HeartRateCard({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      leading: const _StatIconTile(icon: Icons.favorite_rounded, bg: AppColors.heartBg, color: AppColors.heartIcon),
      label: 'Heart Rate',
      valueRow: _StatValueRow(value: value, unit: 'BPM'),
      trailing: const _Sparkline(),
    );
  }
}

class StepsCard extends StatelessWidget {
  final String value;
  final double fraction;
  final String progressLabel;

  const StepsCard({super.key, required this.value, required this.fraction, required this.progressLabel});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      leading: const _StatIconTile(
        icon: Icons.directions_walk_rounded,
        bg: AppColors.primaryLight,
        color: AppColors.primary,
      ),
      label: 'Steps',
      valueRow: _StatValueRow(value: value, unit: 'steps'),
      trailing: _MiniProgressBar(fraction: fraction, label: progressLabel),
    );
  }
}

class SleepCard extends StatelessWidget {
  final String value;
  final String badgeText;

  const SleepCard({super.key, required this.value, required this.badgeText});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      leading: const _StatIconTile(icon: Icons.bedtime_rounded, bg: AppColors.sleepBg, color: AppColors.sleepIcon),
      label: 'Sleep',
      valueRow: _StatValueRow(value: value),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.sleepBg, borderRadius: BorderRadius.circular(8)),
        child: Text(badgeText.toUpperCase(), style: AppTextStyles.sleepBadge),
      ),
    );
  }
}

class BloodOxygenCard extends StatelessWidget {
  final String value;
  final String badgeText; // e.g. "Normal", "Low", "Critical"

  const BloodOxygenCard({super.key, required this.value, required this.badgeText});

  Color get _badgeColor {
    switch (badgeText.toLowerCase()) {
      case 'normal':
        return const Color(0xFF22C55E);
      case 'low':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      leading: const _StatIconTile(
        icon: Icons.water_drop_rounded,
        bg: AppColors.primaryLight,
        color: AppColors.primary,
      ),
      label: 'Blood Oxygen',
      valueRow: _StatValueRow(value: value, unit: '%'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _badgeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _badgeColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          badgeText.toUpperCase(),
          style: TextStyle(color: _badgeColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final List<Widget> cards;
  const StatsGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(height: 16), cards[i]],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Action Button
// ─────────────────────────────────────────────

class SyncActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SyncActionButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(color: AppColors.syncBtn, borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.center,
          child: Text(label, style: AppTextStyles.syncBtnLabel),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

class WatchSyncNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const WatchSyncNavBar({super.key, required this.items, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => onTap?.call(i),
              behavior: HitTestBehavior.opaque,
              child: _NavItemView(item: items[i], selected: i == selectedIndex),
            ),
        ],
      ),
    );
  }
}

class _NavItemView extends StatelessWidget {
  final NavItem item;
  final bool selected;

  const _NavItemView({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          item.label.toUpperCase(),
          style: AppTextStyles.navLabel.copyWith(color: color, letterSpacing: selected ? 0 : -0.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// No Device State
// ─────────────────────────────────────────────

/// Shown in place of the SyncHub when no device is connected yet.
class _NoDeviceHub extends StatelessWidget {
  final VoidCallback onConnect;

  const _NoDeviceHub({required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 8),
            color: AppColors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.watch_off_rounded, color: AppColors.textMuted, size: 36),
              const SizedBox(height: 8),
              Text(
                'No Device',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('No Watch Connected', textAlign: TextAlign.center, style: AppTextStyles.syncTitle),
        const SizedBox(height: 4),
        Text(
          'Tap "Connect a Watch" to scan for nearby devices.',
          textAlign: TextAlign.center,
          style: AppTextStyles.syncSubtitle,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  /// Navigates to the scan screen and waits; on return the provider
  /// will already hold the newly connected service if the user connected.
  Future<void> _goToScan() async {
    Routes.watchScan.push(context);
  }

  /// Opens the health data screen for the currently connected device.
  void _viewHealth() {
    Routes.healthDataResult.push(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, hp, _) {
        final service = hp.healthService;

        // Determine connection state reactively when a service exists
        return service != null
            ? StreamBuilder<BluetoothConnectionState>(
                stream: service.connectionState,
                builder: (_, connSnap) {
                  final connected = connSnap.data == BluetoothConnectionState.connected;
                  return _buildBody(hp, service, connected);
                },
              )
            : _buildBody(hp, null, false);
      },
    );
  }

  Widget _buildBody(HealthProvider hp, dynamic service, bool connected) {
    final deviceName = hp.currDeviceName ?? 'Smart Watch';
    final snapshot = hp.latestSnapshot;

    // Derived display values
    final hrValue = snapshot?.heartRate != null ? '${snapshot!.heartRate}' : '--';
    final batteryValue = snapshot?.battery;

    // Steps / sleep are not provided by the BLE health service currently,
    // so we keep them as placeholder until that data source is integrated.
    const stepsValue = '--';
    const stepsFraction = 0.0;
    const stepsLabel = '0% done';

    return Column(
      children: [
        TopPadding(),
        // ── Header ────────────────────────────────────────────
        WatchSyncHeader(
          title: 'Sync',
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            onPressed: service != null ? _viewHealth : null,
          ),
        ),

        // ── Connection badge ───────────────────────────────────
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: service == null
              ? const ConnectionBadge(label: 'Not Connected', connected: false)
              : ConnectionBadge(label: connected ? 'Connected' : 'Disconnected', connected: connected),
        ),

        // ── Scrollable body ────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Hub — real device or empty state
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: service == null
                      ? _NoDeviceHub(onConnect: _goToScan)
                      : SyncHub(
                          valueLabel: batteryValue != null ? '$batteryValue%' : '--',
                          title: deviceName,
                          subtitle: connected ? 'Smart Watch is connected' : 'Reconnecting…',
                        ),
                ),

                // Stats grid — always shown; "--" when no data yet
                StatsGrid(
                  cards: [
                    HeartRateCard(value: hrValue),
                    BloodOxygenCard(
                      value: snapshot?.spo2 != null ? snapshot!.spo2!.toStringAsFixed(1) : '--',
                      badgeText: _spo2Badge(snapshot?.spo2),
                    ),
                    const StepsCard(value: stepsValue, fraction: stepsFraction, progressLabel: stepsLabel),
                  ],
                ),

                // Action button — context-aware label & destination
                SyncActionButton(
                  label: service == null ? 'Connect a Watch' : 'View Health Data',
                  onTap: service == null ? _goToScan : _viewHealth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _spo2Badge(double? spo2) {
  if (spo2 == null) return 'No Data';
  if (spo2 >= 95) return 'Normal';
  if (spo2 >= 90) return 'Low';
  return 'Critical';
}
