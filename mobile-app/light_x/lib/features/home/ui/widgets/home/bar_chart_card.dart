// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class BarChartItem {
  final String label;

  /// Fraction of the max bar height (0.0 – 1.0)
  final double value;
  final bool isActive;

  const BarChartItem({required this.label, required this.value, this.isActive = false});
}

class _BarColumn extends StatelessWidget {
  final BarChartItem item;

  /// Maximum pixel height the bar track can occupy
  final double maxHeight;

  const _BarColumn({required this.item, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    final trackHeight = maxHeight; // overlay is always full track height
    final fillHeight = maxHeight * item.value;

    final overlayDecoration = BoxDecoration(
      color: AppColors.barOverlay,
      border: item.isActive ? Border.all(color: AppColors.activeBarBorder, width: 2) : null,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Track + fill
        SizedBox(
          width: 29,
          height: trackHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Overlay (background track)
              Positioned.fill(child: Container(decoration: overlayDecoration)),
              // Solid fill bar
              Positioned(
                left: item.isActive ? 2 : 0,
                right: item.isActive ? 2 : 0,
                bottom: item.isActive ? 2 : 0,
                height: fillHeight - (item.isActive ? 2 : 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.isActive ? AppColors.activeBarFill : AppColors.barFill,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Day label
        Text(
          item.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 1.5,
            color: item.isActive ? AppColors.labelActive : AppColors.labelDefault,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Bar chart row
// ─────────────────────────────────────────────

class _BarChartRow extends StatelessWidget {
  final List<BarChartItem> items;
  final double barMaxHeight;

  const _BarChartRow({required this.items, required this.barMaxHeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) => _BarColumn(item: item, maxHeight: barMaxHeight)).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Footer row
// ─────────────────────────────────────────────

class _ChartFooter extends StatelessWidget {
  final String text;

  const _ChartFooter({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Teal circle icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: AppColors.footerIconBg, shape: BoxShape.circle),
          child: Center(child: Icon(Icons.trending_up, size: 16, color: AppColors.footerIcon)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.33, color: AppColors.footerText),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Public card widget
// ─────────────────────────────────────────────

class BarChartCard extends StatelessWidget {
  final List<BarChartItem> items;
  final String footerText;

  /// Height of the bar track area in logical pixels.
  /// Defaults to 80 (matches the CSS spec).
  final double barMaxHeight;

  const BarChartCard({super.key, required this.items, required this.footerText, this.barMaxHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar chart
          _BarChartRow(items: items, barMaxHeight: barMaxHeight),

          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: AppColors.divider),

          const SizedBox(height: 16),

          // Footer
          _ChartFooter(text: footerText),
        ],
      ),
    );
  }
}
