import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:light_x/core/assets/assets.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:remixicon/remixicon.dart';

class RiskDashboard extends StatelessWidget {
  const RiskDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          const AppText("HYPERTENSION RISK SCORE", fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    SvgPicture.asset(Assets.svgs.semiCircle, width: 240, height: 120),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      top: 0,
                      right: 50,
                      child: SvgPicture.asset(
                        Assets.svgs.needle,
                        colorFilter: ColorFilter.mode(Colors.black.withAlpha(40), BlendMode.srcATop),
                      ),
                    ),
                  ],
                ),
                8.inColumn,
                AppText("12%", fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
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
