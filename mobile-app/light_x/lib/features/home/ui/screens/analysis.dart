import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:light_x/core/storage/shared_prefs/shared_prefs.dart';
import 'package:light_x/core/utils/nav_utils.dart';
import 'package:light_x/data/models/health_model.dart';
import 'package:light_x/features/home/providers/analysis_provider.dart';
import 'package:light_x/features/scan/providers/health_provider.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  @override
  void initState() {
    super.initState();
    // Kick off analysis as soon as the screen mounts, pulling live vitals
    // from HealthProvider (set by the BLE watch connection).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _runAnalysis();
      } catch (e) {
        log(" Error running analysis: $e");
      }
    });
  }

  void _runAnalysis() {
    final hp = context.read<HealthProvider>();
    final snap = hp.latestSnapshot;

    final prev = SharedPrefs.prefs.get(SharedPrefKeys.onboardingData.name) as String?;

    final request = prev == null
        ? HealthModel.empty()
        : HealthModel.fromJson(jsonDecode(prev)).copyWith(
            // ── Live watch data ────────────────────────────────────────────────────
            systolicBp: snap?.bloodPressure?.systolic ?? 120,
            diastolicBp: snap?.bloodPressure?.diastolic ?? 80,
            heartRate: snap?.heartRate ?? 72,
            spo2: snap?.spo2?.toInt() ?? 98,

            hrv: 18,
            totalCholesterol: 240,
            hdlCholesterol: 35,
            fastingGlucose: 118,
            creatinine: 1,
          );

    context.read<AnalysisProvider>().analyse(request);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        return AppScaffold(
          leading: const SizedBox(width: 48),
          title: AppTexts.pageAppBarTitleText("Analysis Results"),
          viewPadding: EdgeInsets.zero,
          trailing: BuildIconButton(onPressed: () {}, icon: const Icon(RemixIcons.information_2_fill)),
          body: switch (provider.state) {
            AnalysisState.loading || AnalysisState.idle => const _LoadingBody(),
            AnalysisState.error => _ErrorBody(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: provider.retry,
            ),
            AnalysisState.success => _SuccessBody(result: provider.result!),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          const SizedBox(height: 20),
          Text('Running analysis…', style: AppTextStyles.scannerSubtitle),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 16),
            Text('Analysis Failed', style: AppTextStyles.scannerHeading, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.scannerSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Success — original design, real data
// ─────────────────────────────────────────────

class _SuccessBody extends StatelessWidget {
  final AnalysisResult result;

  const _SuccessBody({required this.result});

  @override
  Widget build(BuildContext context) {
    final gaugeData = RiskGaugeData(
      score: result.riskScore,
      label: '/ 100',
      badgeText: result.riskBadgeText,
      description: result.rawResponse.length > 240
          ? '${jsonDecode(result.rawResponse)['data']['advice']}…'
          : result.rawResponse,
      arcColor: result.riskArcColor,
      fraction: result.riskFraction,
    );

    final metrics = [
      MetricCardData(
        icon: Icons.water_drop_rounded,
        iconColor: AppColors.primary,
        label: 'Blood Pressure',
        value: result.bpDisplay,
        status: result.bpStatus,
        statusColor: result.bpStatusColor,
      ),
      MetricCardData(
        icon: Icons.favorite_rounded,
        iconColor: AppColors.red,
        label: 'Heart Rate',
        value: result.hrDisplay,
        unit: 'bpm',
        status: result.hrStatus,
        statusColor: result.hrStatusColor,
      ),
      MetricCardData(
        icon: Icons.water_drop_outlined,
        iconColor: AppColors.primary,
        label: 'SpO₂',
        value: result.spo2Display,
        unit: '%',
        status: result.spo2Status,
        statusColor: result.spo2StatusColor,
      ),
    ];

    final premiumData = PremiumLockedData(
      title: '5 Year Risk Prediction.',
      description:
          'See how your cardiovascular risk might evolve over the next 5 years '
          'based on current trends.',
      ctaLabel: 'Unlock Premium',
      onTap: () => NavUtils.withContext((ctx) => Routes.pricing.push(ctx)),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          const TimestampLabel(text: 'Today · Just now'),
          const SizedBox(height: 40),

          RiskGauge(data: gaugeData),
          const SizedBox(height: 32),

          MetricsGrid(metrics: metrics),
          const SizedBox(height: 16),

          PremiumLockedCard(data: premiumData),
          const SizedBox(height: 16),

          LifestyleTipCard(title: 'Recommendation', body: result.lifestyleTip),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// All original widgets below — zero changes
// ─────────────────────────────────────────────

class TimestampLabel extends StatelessWidget {
  final String text;
  const TimestampLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), textAlign: TextAlign.center, style: AppTextStyles.timestamp);
  }
}

class RiskGaugeData {
  final int score;
  final String label;
  final String badgeText;
  final String description;
  final Color arcColor;
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

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  _GaugePainter({required this.fraction, required this.trackColor, required this.arcColor, this.strokeWidth = 13});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -200 * (3.14159265 / 180);
    const sweepTotal = 220 * (3.14159265 / 180);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepTotal * fraction, false, arcPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.arcColor != arcColor || old.trackColor != trackColor;
}

class RiskGauge extends StatelessWidget {
  final RiskGaugeData data;
  const RiskGauge({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${data.score}', style: AppTextStyles.gaugeScore),
                  Text(data.label, style: AppTextStyles.gaugeLabel),
                  const SizedBox(height: 8),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.25),
          child: Text(
            data.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.gaugeDescription,
          ),
        ),
      ],
    );
  }
}

class MetricCardData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;
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
          Row(
            children: [
              Icon(data.icon, color: data.iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  data.label.toUpperCase(),
                  // style: AppTextStyles.metricCardLabel,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(data.value, style: AppTextStyles.metricCardValue)),
              if (data.unit != null) ...[
                const SizedBox(width: 2),
                Text(data.unit!, style: AppTextStyles.metricCardUnit),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(data.status.toUpperCase(), style: AppTextStyles.metricCardStatus.copyWith(color: data.statusColor)),
        ],
      ),
    );
  }
}

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

class PremiumLockedData {
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback? onTap;

  const PremiumLockedData({required this.title, required this.description, required this.ctaLabel, this.onTap});
}

class PremiumLockedCard extends StatelessWidget {
  final PremiumLockedData data;
  const PremiumLockedCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: const DecoratedBox(
              decoration: BoxDecoration(
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
