import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:light_x/core/assets/assets.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: const TopPadding()),
        // Header Section
        SliverToBoxAdapter(
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
                  child: BuildIconButton(onPressed: () {}, icon: const Icon(RemixIcons.notification_2_line, size: 20)),
                ),
              ],
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
              onPressed: () {},
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

        100.inSliverColumn, // Bottom spacer
      ],
    );
  }

  // --- Helper Build Methods ---

  Widget _buildChartBar(String label, double heightPercent, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 80 * heightPercent,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C58D9) : const Color(0xFF1C58D9).withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        8.inColumn,
        AppText(label, fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
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

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required double progress,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                16.inRow,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(title, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      AppText("$value $unit", fontSize: 12, color: const Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
            16.inColumn,
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
