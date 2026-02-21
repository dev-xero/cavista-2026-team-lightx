import 'package:flutter/material.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';

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
      await Future.delayed(400.inMs);
      if (mounted) Routes.onboarding1.go(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: Center());
  }
}
