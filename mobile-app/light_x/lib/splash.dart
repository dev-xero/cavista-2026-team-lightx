import 'package:flutter/material.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.delayed(1.inSeconds);
      if (mounted) Routes.onboarding1.go(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primary,
      leading: const SizedBox(),
      appBarPadding: (_) => EdgeInsets.zero,
      body: Center(child: Image.asset(Assets.logo.splashLogo)),
    );
  }
}
