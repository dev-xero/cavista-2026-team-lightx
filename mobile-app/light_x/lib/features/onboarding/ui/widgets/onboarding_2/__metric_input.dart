part of '../../screens/onboarding_2.dart';

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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      suffix: SizedBox(
        width: 60,
        child: Center(child: AppText(unit, fontSize: 16, color: AppColors.lightGray)),
      ),
    );
  }
}
