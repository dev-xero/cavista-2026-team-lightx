part of '../../screens/onboarding_1.dart';

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.inMs,
        curve: Curves.decelerate,
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
