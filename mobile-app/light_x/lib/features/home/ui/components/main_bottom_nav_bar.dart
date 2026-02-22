import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

class BottomNavBar extends StatelessWidget {
  final int currIndex;
  final void Function(int index) onTap;
  const BottomNavBar({super.key, required this.currIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,

      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currIndex,
        unselectedItemColor: AppColors.lightGray,
        selectedItemColor: AppColors.primary,
        onTap: (index) => onTap(index),
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.lightGray),
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        items: const [
          BottomNavigationBarItem(icon: Icon(RemixIcons.home_2_line), label: "HOME", tooltip: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "TRENDS", tooltip: "Your health trends"),
          BottomNavigationBarItem(icon: Icon(Icons.watch), label: "DEVICES", tooltip: "your connected devices"),
          // BottomNavigationBarItem(icon: Icon(RemixIcons.user_2_line), label: "PROFILE", tooltip: "Your profile"),
        ],
      ),
    );
  }
}
