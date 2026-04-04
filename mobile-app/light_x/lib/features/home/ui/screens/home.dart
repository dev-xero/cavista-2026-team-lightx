import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:light_x/core/assets/assets.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/features/home/ui/entities/bar_chart_item.dart';
import 'package:light_x/features/home/ui/entities/health_tip_item.dart';
import 'package:light_x/features/home/ui/widgets/home/bar_chart_card.dart';
import 'package:light_x/features/home/ui/widgets/home/daily_analysis_card.dart';
import 'package:light_x/features/home/ui/widgets/home/health_tips_section.dart';
import 'package:light_x/features/home/ui/widgets/home/home_app_bar.dart';
import 'package:light_x/features/home/ui/widgets/home/risk_dashboard.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        PinnedHeaderSliver(child: HomeAppBar()),

        // Hypertension Risk Card
        SliverToBoxAdapter(child: RiskDashboard()),

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

        SliverToBoxAdapter(child: DailyAnalysisCard()),

        24.inSliverColumn,

        SliverToBoxAdapter(child: BarChartCardTitle()),

        16.inSliverColumn,
        SliverToBoxAdapter(
          child: BarChartCard(items: BarChartItem.samples, footerText: 'Your activity is 12% higher than last week'),
        ),

        24.inSliverColumn,

        SliverToBoxAdapter(child: HealthTipsSection(tips: HealthTipItem.items)),

        88.inSliverColumn,
      ],
    );
  }
}
