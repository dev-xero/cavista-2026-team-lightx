import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

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
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 28 / 20,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Connection Badge
// ─────────────────────────────────────────────

/// Animated pulsing dot + "Connected" label pill.
class ConnectionBadge extends StatefulWidget {
  final String label;
  const ConnectionBadge({super.key, this.label = 'Connected'});

  @override
  State<ConnectionBadge> createState() => AppColorsonnectionBadgeState();
}

class AppColorsonnectionBadgeState extends State<ConnectionBadge> with SingleTickerProviderStateMixin {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.connectedBg, borderRadius: BorderRadius.circular(9999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing glow ring + solid dot
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
                      decoration: BoxDecoration(color: AppColors.connectedGlow, shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.connectedDot, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.label.toUpperCase(), style: AppTextStyles.connBadge),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sync Hub (dashed ring + central icon + label)
// ─────────────────────────────────────────────

/// Painter: static grey track ring + rotating dashed blue ring.
class _SyncRingPainter extends CustomPainter {
  final double rotation;

  _SyncRingPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 4.17% inset on each side
    final inset = size.width * 0.0417;
    final radius = size.width / 2 - inset - 4; // 4 = half stroke

    // Track ring
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    // Dashed ring
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

/// Animated sync hub: spinning dashed ring, central watch icon, title + subtitle.
class SyncHub extends StatefulWidget {
  final String valueLabel; // e.g. "98%"
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
        // Ring + icon
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

        // Title + subtitle
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

/// Mini bar-chart sparkline for heart rate.
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

/// Mini horizontal progress bar used in the Steps card.
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

/// Base card layout shared by all stat cards.
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

/// Icon tile used as the leading element in every stat card.
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

/// Value + unit inline (e.g. "72  BPM").
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

/// Heart rate card with sparkline.
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

/// Steps card with mini progress bar.
class StepsCard extends StatelessWidget {
  final String value;
  final double fraction;
  final String progressLabel; // e.g. "84% done"

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

/// Sleep card with a coloured badge.
class SleepCard extends StatelessWidget {
  final String value; // e.g. "7h 42m"
  final String badgeText; // e.g. "Deep Sleep"

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

/// Vertical stack of stat cards with 16px gaps.
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

/// Full-width navy sync action button.
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

/// Data model for a single nav item.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// Custom bottom nav bar matching the Figma spec.
class WatchSyncNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const WatchSyncNavBar({super.key, required this.items, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
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
// Screen
// ─────────────────────────────────────────────

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            WatchSyncHeader(
              title: 'Sync',
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ),

            // Connection badge
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerLeft, child: ConnectionBadge()),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Sync hub
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: SyncHub(valueLabel: '98%', title: 'Apple Watch', subtitle: 'Smart Watch is connecting...'),
                    ),

                    // Stats grid
                    StatsGrid(
                      cards: const [
                        HeartRateCard(value: '72'),
                        StepsCard(value: '8,431', fraction: 0.84, progressLabel: '84% done'),
                        SleepCard(value: '7h 42m', badgeText: 'Deep Sleep'),
                      ],
                    ),

                    // Action button
                    SyncActionButton(label: 'Sync Now', onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
