import 'package:flutter/material.dart';
import 'package:light_x/features/home/providers/main_screen_provider.dart';
import 'package:light_x/features/home/ui/components/main_bottom_nav_bar.dart';
import 'package:light_x/features/home/ui/screens/analysis.dart';
import 'package:light_x/features/home/ui/screens/devices.dart';
import 'package:light_x/features/home/ui/screens/home.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

const tabs = [Home(), Analysis(), Devices()];

class MainScreen extends StatelessWidget {
  final int index;
  const MainScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final mainScreenProvider = context.watch<MainScreenProvider>();
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
      bottomNavigationBar: BottomNavBar(
        currIndex: mainScreenProvider.currentIndex,
        onTap: (index) {
          context.read<MainScreenProvider>().setCurrentIndex(index);
        },
      ),
      body: Home(),
    );
  }
}
