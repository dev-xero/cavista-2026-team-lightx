import 'package:flutter/material.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/features/onboarding/providers/onboarding_provider.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:provider/provider.dart';

class SymptomOption {
  final String title;
  final String subtitle;

  const SymptomOption({required this.title, required this.subtitle});
}

const List<SymptomOption> symptomOptions = [
  SymptomOption(title: 'Very Little', subtitle: '3hrs - 4hrs'),
  SymptomOption(title: 'A Little', subtitle: '5hrs - 6hrs'),
  SymptomOption(title: 'Good', subtitle: '7hrs - 8hrs'),
  SymptomOption(title: 'Excellent', subtitle: '8hrs - 10hrs'),
];

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    return AppScaffold(
      leading: AppBackButton(),
      title: Center(child: AppTexts.pageAppBarTitleText("WELCOME", fontWeight: FontWeight.bold)),
      trailing: const SizedBox(width: 48),
      appBarPadding: (p) => p.copyWith(left: 16, right: 16),
      body: Column(
        children: [
          _buildProgressBar(0.2),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: AppTexts.pageAppBarTitleText(
                      "How many hours do you sleep per day?",
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ...List.generate(symptomOptions.length, (index) {
                    final option = symptomOptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OptionCard(
                        title: option.title,
                        subtitle: option.subtitle,
                        isSelected: provider.sleepTimeIndex == index,
                        onTap: () => provider.setCurrentIndex(index),
                      ),
                    );
                  }),

                  AppButton(label: "Continue", onPressed: () {}),
                  8.inColumn,
                  SizedBox(
                    height: 56,
                    child: Center(child: AppText("Skip for now", color: AppColors.blackGray)),
                  ),

                  40.inColumn,
                  BottomPadding(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText("ONBOARDING PROGRESS"),
              AppText("Step 1 of 3", color: const Color(0xFF1C58D9), fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 12),
          AppLinearProgressIndicator.regular(progress: progress),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF1C58D9) : const Color(0xFFE2E8F0), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.neutralBlack900),
                    AppText(subtitle, fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildRadioIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? const Color(0xFF1C58D9) : const Color(0x661C58D9), width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: isSelected
          ? const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF1C58D9), shape: BoxShape.circle),
            )
          : null,
    );
  }
}
