part of '../../screens/onboarding_1.dart';

class _HeaderProgressBar extends StatelessWidget {
  const _HeaderProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText("ONBOARDING PROGRESS", fontSize: 14, letterSpacing: 0.7),
              AppText("Step 1 of 3", color: AppColors.primary, fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 12),
          AppLinearProgressIndicator.regular(progress: progress),
        ],
      ),
    );
  }
}
