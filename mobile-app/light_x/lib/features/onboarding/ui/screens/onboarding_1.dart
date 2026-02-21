import 'package:flutter/material.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/components/layout/app_text.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: AppBackButton(),
      title: AppTexts.pageAppBarTitleText("Welcome to Pulse8"),

      body: const SizedBox.expand(),
    );
  }
}
