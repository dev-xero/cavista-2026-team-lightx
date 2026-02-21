import 'package:flutter/material.dart';
import 'package:light_x/features/home/ui/screens/home.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const SizedBox(),
      appBarPadding: (_) => EdgeInsets.zero,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Routes.aiChat.push(context);
        },
        backgroundColor: AppColors.primary,
        shape: CircleBorder(),
        child: Icon(RemixIcons.ai_generate_text),
      ),
      body: Home(),
    );
  }
}
