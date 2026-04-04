part of '../../screens/onboarding_2.dart';

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
        duration: 300.inMs,
        curve: Curves.decelerate,
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
