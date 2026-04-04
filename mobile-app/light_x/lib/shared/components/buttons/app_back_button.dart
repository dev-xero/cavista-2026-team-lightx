import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';

class AppBackButton extends StatelessWidget {
  final void Function()? onPressed;
  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BuildIconButton(
      useNormalPadding: true,
      onPressed: () => onPressed != null ? onPressed!() : context.pop(),
      icon: SvgPicture.asset(Assets.svgs.leftArrow),
    );
  }
}
