part of '../../screens/onboarding_2.dart';

Widget _buildHeader(TextTheme textTheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText("Let’s get to\nmeet you.", fontSize: 30, fontWeight: FontWeight.w700, height: 1.25, color: Colors.black),
      const SizedBox(height: 12),
      const AppText("Please enter your details for a personalized experience.", fontSize: 14, color: Color(0xFF64748B)),
      const SizedBox(height: 12),
      const AppText("Step 2 of 3", fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C58D9)),
      12.inColumn,
      // Progress Bar
      AppLinearProgressIndicator.regular(progress: 0.4),
    ],
  );
}

Widget _buildGenderSelection(OnboardingProviders p) {
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
      AbsorberSelect(
        listenable: p.onboarding2,
        selector: (p0) => p0.isMale,
        builder: (context, isMale, ref, _) {
          return Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: "Male",
                  assetSvgPath: Assets.svgs.maleIcon,
                  isSelected: isMale == true,
                  onTap: () => p.onboarding2.self(ref).setIsMale(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  label: "Female",
                  assetSvgPath: Assets.svgs.femaleIcon,
                  isSelected: isMale == false,
                  onTap: () => p.onboarding2.self(ref).setIsMale(false),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

Widget _buildBodyMetrics() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppText(
        "BODY METRICS",
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xCC1C58D9),
        letterSpacing: 1.4,
      ),
      16.inColumn,
      const _MetricInput(label: "Age", hint: "24", unit: "years"),
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

Widget _buildLifestyleSection(OnboardingProviders p) {
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
          AbsorberSelect(
            listenable: p.onboarding2,
            selector: (p0) => p0.isSmoking,
            builder: (context, isSmoking, ref, _) {
              return Switch(
                value: isSmoking,
                thumbColor: WidgetStatePropertyAll(Colors.white),
                trackColor: WidgetStatePropertyAll(Color(0xFFCBD5E1)),
                trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                onChanged: (val) => p.onboarding2.self(ref).setIsSmoking(val),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _DiabeticToggleRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DiabeticToggleRow({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 352,
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Diabetic?',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4), // Balancing the 52px total height
                const Text(
                  'Have you been diagnosed for diabetes before?',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 16 / 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right side: Custom Toggle Switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                // Using your Figma Background color
                color: value ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: value ? 28 : 4, // Aligned to your 4px top/left spec
                    top: 4,
                    child: Container(
                      width: 24, // Your spec: 24px
                      height: 20, // Your spec: 20px
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
