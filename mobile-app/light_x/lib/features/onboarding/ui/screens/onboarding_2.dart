import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/inputs/app_text_form_field.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class _MetricInput extends StatelessWidget {
  final String label;
  final String unit;
  final String hint;

  const _MetricInput({required this.label, required this.unit, required this.hint});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      titleText: label,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintText: hint,
      suffix: SizedBox(
        width: 40,
        child: Center(child: AppText(unit, fontSize: 16, color: AppColors.lightGray)),
      ),
    );
  }
}

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  bool isMale = true;
  bool isSmoking = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      leading: AppBackButton(),
      title: Center(child: AppTexts.pageAppBarTitleText("WELCOME", fontWeight: FontWeight.bold)),
      trailing: const SizedBox(width: 48),
      appBarPadding: (p) => p.copyWith(left: 16, right: 16),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(textTheme),
            36.inColumn,
            _buildGenderSelection(),
            36.inColumn,
            _buildBodyMetrics(),
            36.inColumn,
            _buildLifestyleSection(),
            36.inColumn,
            AppButton(
              label: "Continue",
              trailing: Icon(Icons.arrow_right_alt, color: Colors.white, size: 20),
              onPressed: () {},
              size: const Size(double.infinity, 56),
            ),

            40.inColumn,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          "Let’s get to\nmeet you.",
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        const AppText(
          "Please enter your details for a personalized experience.",
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 12),
        const AppText("Step 2 of 3", fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C58D9)),
        12.inColumn,
        // Progress Bar
        AppLinearProgressIndicator.regular(progress: 0.4),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          "GENDER SELECTION",
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xCC1C58D9),
          letterSpacing: 1.4,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                label: "Male",
                assetSvgPath: Assets.svgs.maleIcon,
                isSelected: isMale,
                onTap: () => setState(() => isMale = true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GenderCard(
                label: "Female",
                assetSvgPath: Assets.svgs.femaleIcon,
                isSelected: !isMale,
                onTap: () => setState(() => isMale = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              "BODY METRICS",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xCC1C58D9),
              letterSpacing: 1.4,
            ),
            TextButton(
              onPressed: () {},
              child: const AppText("Unit Settings", fontSize: 12, color: Color(0xFF1C58D9)),
            ),
          ],
        ),
        const _MetricInput(label: "Age", hint: "24", unit: "yrs"),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _MetricInput(label: "Weight", hint: "65", unit: "kg"),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MetricInput(label: "Height", hint: "175", unit: "cm"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0D1C58D9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1A1C58D9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0x1A1C58D9), borderRadius: BorderRadius.circular(16)),
              child: SvgPicture.asset(
                Assets.svgs.smokingIcon,
                colorFilter: ColorFilter.mode(Color(0xFF1C58D9), BlendMode.srcIn),
                width: 20,
                height: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText("Smoking Status", fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                  AppText("Do you currently smoke?", fontSize: 12, color: Color(0xFF64748B)),
                ],
              ),
            ),
            Switch(
              value: isSmoking,
              thumbColor: WidgetStatePropertyAll(Colors.white),
              trackColor: WidgetStatePropertyAll(Color(0xFFCBD5E1)),
              trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
              onChanged: (val) => setState(() => isSmoking = val),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String assetSvgPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({required this.label, required this.assetSvgPath, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 84,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x0D1C58D9) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF1C58D9) : const Color(0xFFE2E8F0), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetSvgPath,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF1C58D9) : const Color(0xFF94A3B8),
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(height: 8),
            AppText(label, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ],
        ),
      ),
    );
  }
}
