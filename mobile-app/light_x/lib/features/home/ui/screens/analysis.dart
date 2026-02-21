import 'package:flutter/material.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:remixicon/remixicon.dart';

class Analysis extends StatelessWidget {
  const Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppTexts.pageAppBarTitleText("Analysis Results"),
      trailing: BuildIconButton(onPressed: () {}, icon: Icon(RemixIcons.share_2_line)),
      body: CustomScrollView(),
    );
  }
}
