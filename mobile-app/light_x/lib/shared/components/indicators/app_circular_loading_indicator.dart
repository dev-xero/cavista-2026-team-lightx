import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class AppCircularLoadingIndicator extends StatelessWidget {
  const AppCircularLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColors.primary, strokeCap: StrokeCap.round);
  }
}
