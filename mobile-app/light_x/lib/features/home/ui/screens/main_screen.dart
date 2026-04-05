import 'package:flutter/material.dart';
import 'package:light_x/core/base/src/absorber.dart';
import 'package:light_x/features/home/providers/main_providers.dart';
import 'package:light_x/features/home/ui/widgets/main/main_bottom_nav_bar.dart';
import 'package:light_x/features/home/ui/screens/analysis.dart';
import 'package:light_x/features/home/ui/screens/devices.dart';
import 'package:light_x/features/home/ui/screens/home.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

const tabs = [Home(), Analysis(), Devices()];

class MainScreen extends StatelessWidget {
  final int index;
  const MainScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return AbsorberRead(
      listenable: MainProviders.asPro,
      builder: (_, mainProvider, _, _) {
        return AppScaffold(
          canPop: false,
          appBar: const SizedBox(),
          appBarPadding: (_) => EdgeInsets.zero,
          viewPadding: EdgeInsets.symmetric(horizontal: 24),
          floatingActionButton: AbsorberSelect(
            listenable: mainProvider.state,
            selector: (p) => p.currentIndex,
            builder: (_, currentIndex, ref, _) {
              if (currentIndex != 0) return const SizedBox();
              return FloatingActionButton.extended(
                onPressed: () {
                  Routes.aiChat.push(context);
                },
                backgroundColor: AppColors.primary,
                // shape: CircleBorder(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                icon: Icon(RemixIcons.ai_generate_text),
                label: AppText("Pulse AI", color: Colors.white, fontWeight: FontWeight.w600),
              );
            },
          ),
          bottomNavigationBar: AbsorberSelect(
            listenable: mainProvider.state,
            selector: (p) => p.currentIndex,
            builder: (_, currentIndex, ref, _) {
              return BottomNavBar(
                currIndex: currentIndex,
                onTap: (index) {
                  mainProvider.state.self(ref).setCurrentIndex(index);
                },
              );
            },
          ),
          body: AbsorberSelect(
            listenable: mainProvider.state,
            selector: (p) => p.currentIndex,
            builder: (_, currentIndex, ref, _) => tabs[currentIndex],
          ),
        );
      },
    );
  }
}
