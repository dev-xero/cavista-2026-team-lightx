import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';

class AppBackButton extends StatelessWidget {
  final void Function()? onPressed;
  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BuildIconButton(
      useNormalPadding: true,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.pop(context);
        }
      },
      icon: SvgPicture.asset(Assets.svgs.leftArrow),
    );
  }
}
