// ─────────────────────────────────────────────
// Face Scanner Widgets
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

/// Instructional heading + subtitle shown at the top of the scanner.
class ScannerHeader extends StatelessWidget {
  final String heading;
  final String subtitle;

  const ScannerHeader({super.key, required this.heading, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(heading, textAlign: TextAlign.center, style: AppTextStyles.scannerHeading),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.scannerSubtitle),
      ],
    );
  }
}

/// Animated circular viewfinder with a progress arc and a face placeholder.
class ScanningViewfinder extends StatefulWidget {
  /// Scan completion fraction 0.0–1.0.
  final double fraction;

  /// Optional widget drawn in the centre (e.g. a camera preview or image).
  final Widget? centerContent;

  const ScanningViewfinder({super.key, this.fraction = 0.65, this.centerContent});

  @override
  State<ScanningViewfinder> createState() => _ScanningViewfinderState();
}

class _ScanningViewfinderState extends State<ScanningViewfinder> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        children: [
          SizedBox.square(
            dimension: 320,
            child: Center(child: Image.asset(Assets.images.faceRecognition, width: 300, height: 300)),
          ),

          Positioned.fill(child: SvgPicture.asset(Assets.svgs.scanningViewfinder, width: 320, height: 320)),
        ],
      ),
    );
  }
}

// ── Status indicator cards ────────────────────

/// Data model for a real-time status indicator.
class StatusIndicatorData {
  final String label;
  final String value;

  const StatusIndicatorData({required this.label, required this.value});
}

/// A single white card showing a labelled status value.
class StatusIndicatorCard extends StatelessWidget {
  final StatusIndicatorData data;

  const StatusIndicatorCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.label.toUpperCase(), style: AppTextStyles.statusIndicatorLabel, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(data.value, style: AppTextStyles.statusIndicatorValue, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Evenly spaced row of [StatusIndicatorCard]s.
class StatusIndicatorsRow extends StatelessWidget {
  final List<StatusIndicatorData> indicators;

  const StatusIndicatorsRow({super.key, required this.indicators});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < indicators.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: StatusIndicatorCard(data: indicators[i])),
        ],
      ],
    );
  }
}

// ── Progress bar section ──────────────────────

/// Data for the scan progress bar.
class ScanProgressData {
  final String stepLabel; // e.g. "STEP 2 OF 3"
  final String percentLabel; // e.g. "65%"
  final double fraction; // 0.0 – 1.0
  final String caption; // e.g. "Hold still, almost done…"

  const ScanProgressData({
    required this.stepLabel,
    required this.percentLabel,
    required this.fraction,
    required this.caption,
  });
}

/// Labelled linear progress bar with step label, percentage, and caption.
class ScanProgressBar extends StatelessWidget {
  final ScanProgressData data;

  const ScanProgressBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Step label + percentage row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(data.stepLabel.toUpperCase(), style: AppTextStyles.progressStepLabel),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(data.percentLabel, style: AppTextStyles.progressPercent),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Track + fill
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Track
                Container(
                  height: 8,
                  decoration: BoxDecoration(color: AppColors.progressTrack, borderRadius: BorderRadius.circular(9999)),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: data.fraction,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9999)),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Caption
        Text(data.caption, textAlign: TextAlign.center, style: AppTextStyles.progressCaption),
      ],
    );
  }
}

class ScannerFooter extends StatelessWidget {
  final String privacyText;
  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback? onPrimary;

  const ScannerFooter({
    super.key,
    this.privacyText = 'Your data is encrypted and never shared',
    required this.secondaryLabel,
    required this.primaryLabel,
    this.onSecondary,
    this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Privacy pill
          PrivacyPill(text: privacyText),

          const SizedBox(height: 16),

          // Button row
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: secondaryLabel,
                  color: AppColors.lightGray,
                  borderRadius: 24,
                  onPressed: onSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(label: primaryLabel, borderRadius: 24, color: AppColors.primary, onPressed: onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped privacy note: lock icon + short text.
class PrivacyPill extends StatelessWidget {
  final String text;

  const PrivacyPill({super.key, this.text = 'Your data is encrypted and never shared'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ← AppColors.inputBg
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon — swap for your SVG asset if needed
          const Icon(
            Icons.lock_outline_rounded,
            // ← AppColors.textMuted
            color: Color(0xFF94A3B8),
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(text, fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
