import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class DailyAnalysisCard extends StatelessWidget {
  const DailyAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
