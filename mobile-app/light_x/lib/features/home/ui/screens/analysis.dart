import 'package:flutter/material.dart';
import 'package:light_x/core/utils/nav_utils.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:remixicon/remixicon.dart';

class Analysis extends StatelessWidget {
  const Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: const SizedBox(width: 48),
      title: AppTexts.pageAppBarTitleText("Analysis Results"),
      trailing: BuildIconButton(onPressed: () {}, icon: Icon(RemixIcons.information_2_fill)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Timestamp
            const TimestampLabel(text: 'Today · 9:41 AM'),
            const SizedBox(height: 40),

            // Risk gauge
            RiskGauge(data: _gaugeData),
            const SizedBox(height: 32),

            // Metrics grid
            const MetricsGrid(metrics: _metrics),
            const SizedBox(height: 16),

            // Premium locked card
            PremiumLockedCard(data: _premiumData),
            const SizedBox(height: 16),

            // Lifestyle tip
            const LifestyleTipCard(
              title: 'Pro Tip: Sodium Intake',
              body:
                  'Reducing your daily sodium intake by just 1,000mg could '
                  'lower your systolic BP by up to 5 points.',
            ),
          ],
        ),
      ),
    );
  }
}

const _gaugeData = RiskGaugeData(
  score: 72,
  label: '/ 100',
  badgeText: 'Moderate',
  description:
      'Your cardiovascular risk is moderately elevated. Focus on blood '
      'pressure management and reducing sodium intake.',
  arcColor: AppColors.amber,
  fraction: 0.72,
);

const _metrics = [
  MetricCardData(
    icon: Icons.water_drop_rounded,
    iconColor: AppColors.primary,
    label: 'Blood Pressure',
    value: '135/85',
    status: 'High Normal',
    statusColor: AppColors.amberText,
  ),
  MetricCardData(
    icon: Icons.favorite_rounded,
    iconColor: AppColors.red,
    label: 'Heart Rate',
    value: '72',
    unit: 'bpm',
    status: 'Normal',
    statusColor: AppColors.green,
  ),
];

final _premiumData = PremiumLockedData(
  title: '5 Year Risk Prediction.',
  description:
      'See how your hypertension risk might evolve over the next 5 years '
      'based on current trends.',
  ctaLabel: 'Unlock Premium',
  onTap: () {
    NavUtils.withContext((context) {
      Routes.pricing.push(context);
    });
  },
);

// ─────────────────────────────────────────────
// Health Dashboard Widgets
// ─────────────────────────────────────────────

/// Uppercase spaced timestamp label, e.g. "TODAY · 9:41 AM".
class TimestampLabel extends StatelessWidget {
  final String text;
  const TimestampLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), textAlign: TextAlign.center, style: AppTextStyles.timestamp);
  }
}

/// Data model for the risk gauge.
class RiskGaugeData {
  final int score;
  final String label; // e.g. "/ 100"
  final String badgeText; // e.g. "MODERATE"
  final String description;
  final Color arcColor;

  /// 0.0 – 1.0 fraction of the semicircle filled.
  final double fraction;

  const RiskGaugeData({
    required this.score,
    required this.label,
    required this.badgeText,
    required this.description,
    required this.arcColor,
    required this.fraction,
  });
}

/// Custom painter that draws a circular gauge (track + filled arc).
class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  // ignore: unused_element_parameter
  _GaugePainter({required this.fraction, required this.trackColor, required this.arcColor, this.strokeWidth = 13});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -200 * (3.14159265 / 180); // -200° (bottom-left)
    const sweepTotal = 220 * (3.14159265 / 180); // 220° sweep

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 2; // slightly thicker, matches Figma 14px vs 12px

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepTotal * fraction, false, arcPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.arcColor != arcColor || old.trackColor != trackColor;
}

/// Semicircular risk gauge with score, label, badge, and description.
class RiskGauge extends StatelessWidget {
  final RiskGaugeData data;
  const RiskGauge({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gauge circle
        SizedBox(
          width: 256,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(256, 256),
                painter: _GaugePainter(
                  fraction: data.fraction,
                  trackColor: AppColors.gaugeTrack,
                  arcColor: data.arcColor,
                ),
              ),
              // Score content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${data.score}', style: AppTextStyles.gaugeScore),
                  Text(data.label, style: AppTextStyles.gaugeLabel),
                  const SizedBox(height: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amberLight,
                      border: Border.all(color: AppColors.amberBorder),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(data.badgeText.toUpperCase(), style: AppTextStyles.gaugeBadge),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Description text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.25),
          child: Text(data.description, textAlign: TextAlign.center, style: AppTextStyles.gaugeDescription),
        ),
      ],
    );
  }
}

/// Data model for a metric card.
class MetricCardData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit; // optional suffix shown in muted colour
  final String status;
  final Color statusColor;

  const MetricCardData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
    required this.status,
    required this.statusColor,
  });
}

/// A single compact metric card (blood pressure, heart rate, etc.).
class MetricCard extends StatelessWidget {
  final MetricCardData data;
  const MetricCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + label row
          Row(
            children: [
              Icon(data.icon, color: data.iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label.toUpperCase(),
                  style: AppTextStyles.metricCardLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(data.value, style: AppTextStyles.metricCardValue),
              if (data.unit != null) ...[
                const SizedBox(width: 2),
                Text(data.unit!, style: AppTextStyles.metricCardUnit),
              ],
            ],
          ),
          const SizedBox(height: 2),
          // Status label
          Text(data.status.toUpperCase(), style: AppTextStyles.metricCardStatus.copyWith(color: data.statusColor)),
        ],
      ),
    );
  }
}

/// Row of equally sized metric cards.
class MetricsGrid extends StatelessWidget {
  final List<MetricCardData> metrics;
  const MetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < metrics.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: MetricCard(data: metrics[i])),
        ],
      ],
    );
  }
}

/// Dashed-border lifestyle tip card.
class LifestyleTipCard extends StatelessWidget {
  final String title;
  final String body;

  const LifestyleTipCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dashedBorder, style: BorderStyle.solid, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.tipTitle),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.tipBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for the premium locked section.
class PremiumLockedData {
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback? onTap;

  const PremiumLockedData({required this.title, required this.description, required this.ctaLabel, this.onTap});
}

/// Blue premium upsell card with a gradient mask overlay.
class PremiumLockedCard extends StatelessWidget {
  final PremiumLockedData data;
  const PremiumLockedCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Solid blue background
          Container(
            decoration: BoxDecoration(
              color: AppColors.premiumBg,
              border: Border.all(color: AppColors.premiumBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data.title, style: AppTextStyles.premiumTitle),
                    const Icon(Icons.lock_rounded, color: AppColors.white, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(data.description, textAlign: TextAlign.center, style: AppTextStyles.premiumBody),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: data.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(9999)),
                    child: Text(data.ctaLabel, style: AppTextStyles.chipLabel),
                  ),
                ),
              ],
            ),
          ),
          // Top gradient mask (black→transparent, simulating blur/fade from Figma)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [Color(0x66000000), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
