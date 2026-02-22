import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:light_x/core/assets/assets.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/features/home/ui/widgets/home/bar_chart_card.dart';
import 'package:light_x/features/home/ui/widgets/home/health_tips_section.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

const items = [
  BarChartItem(label: 'Mo', value: 48 / 80),
  BarChartItem(label: 'Tu', value: 64 / 80),
  BarChartItem(label: 'We', value: 56 / 80),
  BarChartItem(label: 'Th', value: 40 / 80),
  BarChartItem(label: 'Fr', value: 48 / 80, isActive: true),
  BarChartItem(label: 'Sa', value: 32 / 80),
  BarChartItem(label: 'Su', value: 44 / 80),
];

const tips = [
  HealthTipItem(
    title: 'Stay Hydrated',
    description: 'Drink at least 8 glasses of water daily to keep your body functioning optimally.',
    icon: Icons.local_fire_department_outlined,
    iconColor: AppColors.orange,
  ),
  HealthTipItem(
    title: 'Move More',
    description: 'Aim for 30 minutes of moderate activity each day to boost your energy and mood.',
    icon: Icons.directions_walk_outlined,
    iconColor: AppColors.blue,
  ),
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header Section
        PinnedHeaderSliver(
          child: ColoredBox(
            color: AppColors.lightScaffoldBg,
            child: TopPadding(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    12.inRow,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            "Good Morning",
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          AppText("Tuesday, Oct 24", fontSize: 12, color: AppColors.neutralBlack200),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 36,
                      child: BuildIconButton(
                        onPressed: () {},
                        icon: const Icon(RemixIcons.notification_2_line, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Hypertension Risk Card
        SliverToBoxAdapter(
          child: Container(
            height: 260,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                const AppText(
                  "HYPERTENSION RISK SCORE",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText("12%", fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black),
                      AppText("Low Risk", fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF14B8A6)),
                    ],
                  ),
                ),

                24.inColumn,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricSummary("BP Status", "120/80", "mmHg", RemixIcons.pulse_line),
                    _buildMetricSummary("Risk Level", "LOW", "Risk", RemixIcons.shield_check_line),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Action Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: AppButton(
              label: "TAKE A SCAN",
              onPressed: () {
                Routes.faceScan.push(context);
              },
              leading: SvgPicture.asset(
                Assets.svgs.newScan,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 20,
                height: 20,
              ),
              color: const Color(0xFF1C58D9),
              borderRadius: 24,
              size: const Size(double.infinity, 68),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: Column(
              spacing: 12,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        "Daily Analysis Remaining",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    AppText("2 / 3", fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ],
                ),

                AppLinearProgressIndicator.regular(progress: 0.7),

                AppText(
                  "You have 1 high-precision scan remaining for today.",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightGray,
                ),
              ],
            ),
          ),
        ),

        24.inSliverColumn,

        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText("Weekly Trends", fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              AppText("Full History", fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1C58D9)),
            ],
          ),
        ),

        16.inSliverColumn,
        SliverToBoxAdapter(
          child: BarChartCard(items: items, footerText: 'Your activity is 12% higher than last week'),
        ),

        24.inSliverColumn,

        SliverToBoxAdapter(child: HealthTipsSection(tips: tips)),

        100.inSliverColumn, // Bottom spacer
      ],
    );
  }

  Widget _buildMetricSummary(String label, String val, String unit, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF14B8A6)),
        8.inRow,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, fontSize: 10, color: const Color(0xFF64748B)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AppText(val, fontSize: 16, fontWeight: FontWeight.w700),
                4.inRow,
                AppText(unit, fontSize: 10, color: const Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
